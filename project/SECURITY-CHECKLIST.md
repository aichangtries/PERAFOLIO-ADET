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

This app is a fully local mock prototype with no Firebase, Supabase, Firestore, Storage, or other backend, so rows 13-17 are N/A.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | No Firebase, Firestore, Storage, or security-rules files exist; the app uses in-memory mock data. |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | There are no backend documents or user-specific persistence rules in this local prototype. |
| 15 | If Supabase: Row Level Security is on for every table | N/A | The project does not use Supabase and has no database tables. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The project does not use Firebase or Google API keys. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | There is no account system or backend authorization; all displayed data is local, simulated data. |
| 18 | Seed and sample data is invented, not real people's data | Yes | `flutter/lib/data/mock_data.dart` and `app/page.tsx` use fictional balances, merchants, accounts, transaction IDs, and demo profile information; no real banking data is used. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | No | The web UI sanitizes some fields and checks the verification-code length, but transfer confirmation does not validate amount limits, balance, or all input rules; the Flutter transfer flow can proceed without equivalent validation. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The source and tracked assets contain no credentials or private configuration; the app ships only mock account and transaction data. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | I searched the repository and commit subjects; no student number, phone number, home address, or real personal email was found. The visible `alessandra@perafolio.app` value is fictional demo profile data. |
| 22 | No classmate's personal data in the repository | Yes | The repository contains only invented profile, account, merchant, and transaction data; no classmate data was found in files or commit subjects. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | No | The Flutter directory has no `pubspec.yaml`, and the root `.gitignore` does not include Flutter `build/` or `.dart_tool/`; this needs correction before public release. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | No | The repository contains template/placeholder images in `public/`, but no license or attribution record was found for those assets. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | No | The `origin` remote points to GitHub, but repository visibility was not independently verified in GitHub after the last push. |

## Anything I found and fixed

This checklist caught that the root `.gitignore` does not currently cover Flutter's `build/` and `.dart_tool/` directories, and that transfer input validation is incomplete in the prototype. It also identified placeholder assets without an attribution record; these remain follow-up items before making the repository public.
