-- PeraFolio database schema for Supabase (Postgres).
--
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- It is safe to re-run: tables, policies and the trigger are recreated.
--
-- Every table is owned by a Supabase Auth user and protected by Row Level
-- Security, so a signed-in user can only read and write their own rows.
-- Balances and transactions are still simulated demo data.

-- ---------------------------------------------------------------------------
-- Profiles (one row per auth user)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id             uuid primary key references auth.users (id) on delete cascade,
  full_name      text not null default '',
  email          text not null default '',
  mobile_number  text not null default '',
  home_address   text not null default '',
  date_of_birth  date,
  onboarded      boolean not null default false,
  created_at     timestamptz not null default now()
);

-- Creates the profile as soon as someone signs up, using the full name the
-- app sends as user metadata. Works even when email confirmation is on.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.email, '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Preferences (one row per user)
-- ---------------------------------------------------------------------------
create table if not exists public.user_preferences (
  user_id                    uuid primary key default auth.uid()
                               references auth.users (id) on delete cascade,
  push_notifications         boolean not null default true,
  email_notifications        boolean not null default true,
  sms_alerts                 boolean not null default false,
  promotions                 boolean not null default false,
  biometric_login            boolean not null default true,
  two_factor_authentication  boolean not null default false
);

-- ---------------------------------------------------------------------------
-- Financial data. Ids are the app's own ids ('gcash', 'tx-…'), unique per
-- user, so the primary key is (user_id, id).
-- ---------------------------------------------------------------------------
create table if not exists public.financial_accounts (
  user_id            uuid not null default auth.uid()
                       references auth.users (id) on delete cascade,
  id                 text not null,
  provider           text not null,
  account_type       text not null,
  balance            numeric(14, 2) not null default 0,
  connection_status  text not null check (connection_status in ('connected', 'available')),
  last_sync          timestamptz,
  primary key (user_id, id)
);

create table if not exists public.transactions (
  user_id                  uuid not null default auth.uid()
                             references auth.users (id) on delete cascade,
  id                       text not null,
  account_id               text not null,
  type                     text not null check (type in ('moneyIn', 'moneyOut')),
  amount                   numeric(14, 2) not null check (amount >= 0),
  merchant_or_description  text not null,
  category                 text not null,
  date_time                timestamptz not null,
  status                   text not null default 'Completed',
  primary key (user_id, id)
);
create index if not exists transactions_user_date_idx
  on public.transactions (user_id, date_time desc);

create table if not exists public.transfers (
  user_id                 uuid not null default auth.uid()
                            references auth.users (id) on delete cascade,
  id                      text not null,
  source_account_id       text not null,
  destination_account_id  text not null,
  amount                  numeric(14, 2) not null check (amount > 0),
  fee                     numeric(14, 2) not null default 0,
  status                  text not null default 'Completed',
  date_time               timestamptz not null,
  reference               text not null,
  note                    text not null default '',
  primary key (user_id, id)
);

create table if not exists public.payments (
  user_id            uuid not null default auth.uid()
                       references auth.users (id) on delete cascade,
  id                 text not null,
  merchant           text not null,
  amount             numeric(14, 2) not null check (amount > 0),
  source_account_id  text not null,
  fee                numeric(14, 2) not null default 0,
  status             text not null default 'Completed',
  date_time          timestamptz not null,
  reference          text not null,
  primary key (user_id, id)
);

create table if not exists public.notifications (
  user_id    uuid not null default auth.uid()
               references auth.users (id) on delete cascade,
  id         text not null,
  title      text not null,
  message    text not null,
  date_time  timestamptz not null,
  is_read    boolean not null default false,
  type       text not null check (type in ('transfer', 'payment', 'security', 'account', 'bill')),
  primary key (user_id, id)
);

-- ---------------------------------------------------------------------------
-- Row Level Security: each user sees and changes only their own rows.
-- ---------------------------------------------------------------------------
alter table public.profiles           enable row level security;
alter table public.user_preferences   enable row level security;
alter table public.financial_accounts enable row level security;
alter table public.transactions       enable row level security;
alter table public.transfers          enable row level security;
alter table public.payments           enable row level security;
alter table public.notifications      enable row level security;

drop policy if exists "Own profile" on public.profiles;
create policy "Own profile" on public.profiles
  for all to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

do $$
declare
  t text;
begin
  foreach t in array array[
    'user_preferences', 'financial_accounts', 'transactions',
    'transfers', 'payments', 'notifications'
  ] loop
    execute format('drop policy if exists "Own rows" on public.%I', t);
    execute format(
      'create policy "Own rows" on public.%I for all to authenticated '
      'using ((select auth.uid()) = user_id) '
      'with check ((select auth.uid()) = user_id)',
      t
    );
  end loop;
end;
$$;
