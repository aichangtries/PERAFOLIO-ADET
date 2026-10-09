# PeraFolio

PeraFolio is a Flutter Web personal-finance prototype for people who keep money in several banks and e-wallets. It shows simulated balances, combined activity, transfers between accounts and payments in one app.

> **Balances are simulated.** PeraFolio does not connect to real banks or move real money. Accounts, balances and merchants are fictional demo data, saved per user in a real Supabase database.

## Requirements

- Flutter SDK 3.47.x (Dart 3.13)
- Chrome (or any browser for `web-server`)

## Connect Supabase (once)

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor → New query**, paste [`supabase/schema.sql`](supabase/schema.sql) and click **Run**. It creates the tables, Row Level Security policies and a trigger that creates a profile on sign-up.
3. Copy `supabase.example.json` to `supabase.json` and fill in the **Project URL** and **publishable key** from **Project Settings → API Keys** (the legacy `anon` key also works). `supabase.json` is gitignored. Never use a secret / `service_role` key in the app.
4. Optional, for quicker testing: **Authentication → Sign In / Providers → Email**, turn off *Confirm email*. Otherwise new users must click the emailed link before logging in.

## Run it

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=supabase.json
# or
flutter run -d web-server --dart-define-from-file=supabase.json
```

The app opens on the PeraFolio landing screen inside a simulated **iPhone 16** frame. Use **Get started** to create an account; each new account is seeded with fictional demo balances and activity.

**Offline mode:** run without `--dart-define-from-file` and the app stores everything locally in Hive. Log in with `alessandra@perafolio.app` and any password of 6+ characters.

### Device preview (phone frame)

The project uses `device_preview` **3.x**, which works differently from the 1.x/2.x tutorials:

- It is enabled with one line in `lib/main.dart`: `DevicePreview.enable();`. There is no `DevicePreview(builder: ...)` wrapper, and `MaterialApp` must **not** set `useInheritedMediaQuery`, `locale: DevicePreview.locale(context)` or `builder: DevicePreview.appBuilder`. Those APIs were removed in 3.0, which is why the old setup did not work.
- The app applies the iPhone 16 preset at startup, so the phone frame appears without any extra tools.
- To switch devices, rotate, raise the keyboard or change text size, open **Flutter DevTools** (the link `flutter run` prints) and use the **device_preview** tab. The in-app toolbar from 1.x no longer exists.
- Simulation runs in debug and profile builds (`flutter run`). Release builds (`flutter build web`) switch it off and render the app full-screen.

## Features (M7A1 MVP)

| Area | What works |
| --- | --- |
| Onboarding | Landing → Sign up / Log in sheet with inline validation → Connect accounts → Verify account (any 6-digit code, e.g. `002125`) |
| Dashboard | Total balance, income/spending/net, spending chart (fl_chart) for *This week* / *This month*, category chips with empty state, Transfer and Pay shortcuts, notification bell with unread dot, profile |
| Activity | Search by merchant/account/category, All / Money in / Money out filter, grouped by day, no-results state, tap a row for details |
| Accounts | Total, connected accounts (tap → sync, transfer from, disconnect), accounts available to connect |
| Transfer | From/To pickers, swap, amount with insufficient-balance validation, note, ₱15 fee → Review → Transfer complete (balance updated, reference number) |
| Pay | Scan QR (simulated camera, *Simulate scan*) or Enter details → Review payment → Payment sent |
| Profile | Personal details (editable + saved), Notification settings, Security & privacy (toggles, Change PIN, Active sessions, Data & privacy → **Reset demo data**), Sign out |
| Notifications | Unread/read states, tap to mark read, Mark all as read |

## How data is saved

`AppState` talks to an `AppStore` (`lib/data/app_store.dart`) with two implementations:

- **`SupabaseStore`** (used when keys are provided): Supabase Auth handles sign-up, log-in and password reset; data lives in Postgres. Every table has a `user_id` column and Row Level Security, so users can only read and write their own rows.
- **`LocalStorage`** (offline fallback and tests): Hive CE boxes in IndexedDB.

| Supabase table / Hive box | Contents |
| --- | --- |
| `profiles` / `user_profile` | `UserProfile` (+ onboarded flag in Supabase) |
| `financial_accounts` | `FinancialAccount` |
| `transactions` | `Transaction` |
| `transfers` | `Transfer` |
| `payments` | `Payment` |
| `notifications` | `NotificationItem` |
| `user_preferences` | `UserPreferences` |
| — / `app_session` | signed-in / onboarded flags (Supabase keeps its own session) |

## Bank colors

Each provider has a brand color (`BankColors` in `lib/theme/app_theme.dart`) used on its badge everywhere it appears:

| Provider | Color |
| --- | --- |
| GCash | `#007DFE` |
| GoTyme | `#00F1FB` |
| MariBank | `#ED5F00` |
| Maya | `#22F99F` |
| BPI | `#940005` |

To start over, use **Profile → Security & privacy → Data & privacy → Reset demo data**.

## Project structure

```text
lib/
├── main.dart                 # DevicePreview.enable(), Supabase or Hive init, runApp
├── app.dart                  # MaterialApp + AppGate (Landing / Connect / Home)
├── theme/                    # app_theme.dart (M7A3 ColorScheme + TextTheme), app_spacing.dart
├── models/                   # UserProfile, FinancialAccount, Transaction, Transfer, Payment, NotificationItem, UserPreferences
├── data/                     # app_store.dart (interface), supabase_store.dart, supabase_config.dart, local_storage.dart (Hive CE), seed_data.dart
├── state/app_state.dart      # ChangeNotifier holding all app data + AppScope
├── utils/                    # formatters.dart, validators.dart
├── widgets/                  # M7A3 reusable components (buttons, navigation, cards, inputs, settings, feedback, overlays, …)
└── screens/
    ├── onboarding/           # landing, auth sheet, connect accounts, verify account
    ├── home/                 # home shell, dashboard, activity, accounts
    ├── notifications/
    ├── profile/              # profile, personal details, notification settings, security & privacy
    ├── transfer/             # transfer, review, complete
    └── pay/                  # pay (scan / enter details), review, success
test/
├── app_state_test.dart       # balances, validation, transfer/payment math, Hive persistence after restart
└── navigation_test.dart      # taps through every flow at iPhone 16 size (fails on overflow)
project/                      # course documentation (report, journals, AI usage, security checklist)
```

## Tests

```bash
flutter analyze
flutter test
```

## AI usage

AI was used for explanations, debugging, code assistance and documentation support. Details are in [project/AI-USAGE.md](project/AI-USAGE.md).
