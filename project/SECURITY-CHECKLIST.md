# Security checklist

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | I searched `lib/` and the Flutter `lib/` directory; the files contain only application code and invented mock finance data, with no API keys, tokens or passwords. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | N/A | The project has no private configuration, `--dart-define` values, backend, or real API integration; `project/documentation.md` describes it as a local prototype. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | I searched the tracked files and Flutter directory; no keystore, `key.properties`, signing credential, or Android signing files are present. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | I searched `git log -p --all` and commit subjects for password, secret, API key, and token; no credential values were found. |
| 5 | Any credential that was ever committed has been rotated | N/A | No credential was found in the current files or git history, so there is nothing to rotate. |

## GitHub Actions

No GitHub Actions workflows are present in the repository, so rows 6-12 are N/A.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | N/A | No `.github/workflows` directory or workflow YAML file exists. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | N/A | No GitHub Actions workflows exist. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | N/A | No GitHub Actions workflows or workflow runs exist for this repository. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The repository has no signed APK workflow and no signing configuration. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | N/A | No GitHub Actions artifact workflow exists. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | N/A | No GitHub Actions workflows exist. |
| 12 | Secret scanning and push protection are enabled on the repository | N/A | No GitHub Actions or repository security configuration is included in this workspace; this must be checked in GitHub repository settings before making the repository public. |

## Backend and security rules

The app uses Supabase (Auth + Postgres) as its backend when built with keys, and falls back to local Hive CE storage without them. It does not use Firebase, Firestore or Storage.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | No Firebase, Firestore or Storage is used. The Supabase equivalent is row 15: every policy in `supabase/schema.sql` is granted `to authenticated` only. |
| 14 | Rules restrict a user to their own documents where that makes sense | Yes | Every policy in `supabase/schema.sql` checks `auth.uid() = user_id` (or `= id` for `profiles`) for both reads (`using`) and writes (`with check`). |
| 15 | If Supabase: Row Level Security is on for every table | Yes | `supabase/schema.sql` runs `enable row level security` on all 7 tables. Confirm in Supabase → Table Editor that no table shows "RLS disabled". |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The project does not use Firebase or Google API keys. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | To verify | Needs a manual check against the live project: signed out, a REST request with only the publishable key must return no rows from any table, and a second account must not see the first account's data. |
| 18 | Seed and sample data is invented, not real people's data | Yes | `lib/data/seed_data.dart` uses fictional balances, merchants, accounts, transaction IDs, and demo profile information; no real banking data is used. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | `AppState.validateTransfer` / `validatePayment` re-check amount, accounts and balance before any Hive write, and `confirmTransfer` / `confirmPayment` refuse invalid input; sign-up, login, personal-details, PIN and verification forms validate in `lib/utils/validators.dart`. Covered by `test/app_state_test.dart`. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | Only the Supabase URL and publishable key are compiled in (via `--dart-define-from-file=supabase.json`, which is gitignored). Both are public by design; data is protected by RLS, and no secret / `service_role` key is ever used by the app. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | I searched the repository and commit subjects; no student number, phone number, home address, or real personal email was found. The visible `alessandra@perafolio.app` value is fictional demo profile data. |
| 22 | No classmate's personal data in the repository | Yes | The repository contains only invented profile, account, merchant, and transaction data; no classmate data was found in files or commit subjects. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | `pubspec.yaml` at the repository root uses only pub.dev packages (device_preview, hive_ce, hive_ce_flutter, fl_chart, intl); `.gitignore` contains `/build/` and `.dart_tool/`. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | The old template placeholder images were removed with the Next.js scaffold. The PeraFolio logo is drawn in code (`lib/widgets/brand/perafolio_logo.dart`); the only images are Flutter's default web icons in `web/icons/`. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | No | The `origin` remote points to GitHub, but repository visibility was not independently verified in GitHub after the last push. |

## Anything I found and fixed

This checklist caught that `.gitignore` did not cover Flutter's `build/` and `.dart_tool/`, that transfer validation was incomplete, and that the repository held placeholder assets with no attribution. All three were fixed when the project was restructured into a single Flutter project (rows 19, 23 and 24).
