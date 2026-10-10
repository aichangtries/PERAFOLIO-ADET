# AI-USAGE.md

## How I Use AI in PeraFolio

I use AI as a support tool while working on PeraFolio, especially when I need help organizing my ideas, understanding Flutter code, fixing problems, or keeping track of changes. I do not want to use AI just to generate the whole project because I still need to understand and explain my own code during the final presentation.

One of the biggest ways I use AI is for planning and documentation. I tend to change my project a lot while I am working on it. Even when I think a screen or feature is finished, I usually notice something I want to revise later. During M7A1 and M7A3, I used AI to help summarize and organize all of those changes because it became difficult to track them manually. I still provided the actual decisions and explained why I kept, changed, or removed each feature.

I also use AI for Flutter troubleshooting, especially with layout. Spacing, padding, placement, and overflow are some of the things I struggle with the most. I use AI to help explain why a layout is behaving a certain way or when widgets such as `Expanded` and `Flexible` make more sense.

If AI gives me code that works but I do not understand, I try to go through it and understand what each part is doing before keeping it in my project.

For the final project, I kept updating this file as I worked so my AI usage was documented while it happened instead of trying to remember everything during Week 3.

## What AI Has Helped Me With So Far

### M7A1 - Revised Proposal

AI helped me organize my revised scope, feature changes, storage decision, risks, and change log into the required format.

The actual decisions came from me. I decided which PeraFolio features I wanted to keep, change, simulate, or remove, and I provided the reasons behind those decisions. To be clear, AI was used only to format the document for clarity.

### M7A3 - Design System

AI helped me organize my revised design system and summarize the changes between my PRELIM wireframes and M7A2 high-fidelity mockup. Again, AI was only used for organization.

The visual direction of PeraFolio, its screens, components, colors, spacing, and the changes I made to the design came from my own project work.

### Finals Planning and Documentation

AI helped me organize the finals requirements and prepare my README, weekly report, reflection journal, security checklist, and AI usage documentation based on my existing PeraFolio project. The number of documents I had to check and complete became overwhelming while I also had an app to fix, so I used AI to create a checklist of what I needed to accomplish.

I then wrote the content myself. When I had no time left to polish it and check the grammar, I gave my current version to AI to polish.

### Final Presentation

AI helped me prepare the final presentation. I explain this in the AI Usage Log below (October 9, 2026).

## How I Plan to Use AI During Development

I expect to use AI mainly for:

- Explaining Flutter or Dart code and errors that I do not understand
- Debugging layout, spacing, placement, and overflow problems
- Helping me understand state, navigation, validation, and Hive CE
- Reviewing code and suggesting possible fixes
- Helping organize documentation based on the work I actually completed
- Checking whether my implementation still matches my PeraFolio mockup and revised plan

I will not treat AI-generated code as automatically correct. If I use AI-generated or AI-assisted code, I still need to test it, change it when necessary, and understand what it is doing.

## Code I Wrote Myself

At least 20% of my final project needs to be code that I wrote myself and can identify and explain. I wrote the foundational code for all of the screens. Some of them were later polished by AI (see the October 9 log entry), so the entries below describe the logic I wrote and can explain, not formatting or styling changes.


### Entry 1

**File or feature:**  
`lib/screens/home/dashboard_screen.dart` - the Dashboard

**What I wrote myself:**  
The whole home screen: the greeting, total balance, Income / Spending / Net cards, Transfer and Pay shortcuts, the spending chart with its period picker, and the recent activity list with category filter chips. I also wrote the calculation behind the cards and the chart (`_Summary.compute`).

**What I can explain:**  
- The screen reads `AppScope.of(context)`, so it rebuilds by itself after a transfer or payment changes the state. The total balance comes from `state.totalBalance` and is never typed in.
- The greeting uses `greetingFor(DateTime.now())`, which returns "Good morning", "Good afternoon" or "Good evening" depending on the hour.
- `_period` and `_category` are local state in `_DashboardScreenState`, because only this screen needs them. Changing either one calls `setState()`, which recalculates the summary and the recent list.
- For "This week", the period starts on Sunday (`today.weekday % 7` days back) and has 7 day buckets labelled Sun to Sat. For "This month", it groups the days into week buckets, Wk 1 to Wk 5.
- Transfers between my own accounts are skipped (`isInternalTransfer`), because moving money from GCash to Maya is not income or spending. Income never appears in the spending chart, and the category filter only affects spending.
- Each spending transaction is added to its bucket with `bucketOf()`, and the bucket index is checked against the list length before adding.
- Net is a getter, `income - spending`, so it never has to be stored. The Net card turns red when it is negative.
- The recent list shows the newest 5 transactions that match the category. When there are none, it shows an empty state such as "No groceries activity yet."
- `FittedBox` with `BoxFit.scaleDown` shrinks the total balance instead of overflowing when the number is long.

### Entry 2

**File or feature:**  
`lib/screens/pay/pay_screen.dart` - Pay: Scan QR and Pay: Enter Details

**What I wrote myself:**  
The Pay screen with two tabs: a simulated QR scan, and a form for typing a merchant or mobile number with an amount. I also wrote the animated scanner frame (`_QrFrame` and `_CornerPainter`).

**What I can explain:**  
- `_tab` decides which tab is shown (0 = Scan QR, 1 = Enter details). The "Pay with" account list is built once as `payWith` and reused in both tabs.
- "Simulate scan" picks a random merchant from `_sampleMerchants`, because the camera is simulated on web. It then opens the review screen with a `PaymentDraft`.
- In Enter details, errors only show after the user taps Continue, because `_submitted` must be true first. That way the form doesn't show red errors before the user has typed anything.
- `_continue()` uses a regular expression to check whether the merchant field is a phone number, and labels it "Mobile number" or "Entered manually".
- If the chosen account was disconnected, `sourceId` falls back to the first connected account, so the selection is never invalid. If no accounts are connected, the screen shows an empty state with a button to the Accounts tab.
- `_QrFrame` uses an `AnimationController` that repeats back and forth to move the scan line, with `SingleTickerProviderStateMixin` as its `vsync`. The controller is disposed in `dispose()`.
- `_CornerPainter` is a `CustomPainter` that draws the four corner brackets. It loops over the four corners, using `dx` and `dy` to point each line inwards. `shouldRepaint` returns false because the corners never change.

### Entry 3

**File or feature:**  
`lib/screens/onboarding/auth_sheet.dart` - Log In and Sign Up

**What I wrote myself:**  
One bottom sheet that switches between Log in and Sign up, with validation, a show/hide password button, Forgot password, and error and info messages.

**What I can explain:**  
- `_mode` holds `AuthMode.logIn` or `AuthMode.signUp`. The Full name field only appears in sign-up mode.
- The error getters (`_nameError`, `_emailError`, `_passwordError`) only return a message after the first submit. They use my validators in `lib/utils/validators.dart`, for example a password must have at least 6 characters.
- `_submit()` stops early if any field is invalid. Otherwise it sets `_submitting` to show the loading state, then calls `signUp()` or `logIn()` on `AppState`. It checks `mounted` after the `await`, because the sheet could close while it waits.
- If Supabase asks the user to confirm their email first, the message starts with "Check ". The sheet then switches to Log in mode and shows the message in green instead of as an error.
- Forgot password behaves differently in each mode. Offline, it explains that the reset is simulated and shows the demo account. With Supabase, it first checks the email and then sends a real reset email.
- `_switchMode()` clears the old errors when switching tabs, so a sign-up error doesn't stay on the log-in form.
- `AutofillGroup` and `autofillHints` let the browser fill in the saved email and name.

### Entry 4

**File or feature:**  
`lib/screens/home/accounts_screen.dart` - Accounts and account details

**What I wrote myself:**  
The Accounts tab, which shows the total balance, connected accounts and accounts available to connect. I also wrote the details sheet for one account, with Transfer from, Sync now and Disconnect.

**What I can explain:**  
- `AccountsScreen` is a `StatelessWidget` because all its data comes from `AppState`. It splits the accounts into `connectedAccounts` and `availableAccounts`.
- The account count wording handles singular and plural ("1 connected account", "3 connected accounts").
- Tapping a connected account opens `_AccountDetails`. It takes only the account's id and looks the account up again from the state, so the balance it shows is always current.
- "Transfer from" is disabled when there are fewer than 2 connected accounts. When enabled, it closes the sheet and opens `TransferScreen` with `initialSourceId`, so the From account is already selected.
- Disconnect asks for confirmation with a `_confirmDisconnect` flag, showing "Keep" and "Disconnect" instead of a separate dialog.
- In the Disconnect button, I save `Navigator.of(context)` and `ScaffoldMessenger.of(context)` before the `await`, because using `context` after an async gap can fail if the widget is gone.

### Entry 5

**File or feature:**  
`lib/screens/transfer/transfer_screen.dart` - Transfer Money

**What I wrote myself:**  
The `TransferScreen` stateful widget: picking the From and To accounts, the swap button, the amount and note fields, the live fee breakdown, and the rule for when the Review button is enabled.

**What I can explain:**  
- `didChangeDependencies()` sets the default accounts only once, when `_sourceId` is still null. It uses the first connected account as From and the first different account as To. It runs there instead of in `initState()` because it needs `AppScope`, which reads from the widget tree.
- `_pickAccount()` opens a bottom sheet listing the connected accounts, but it leaves out the account already chosen on the other side (`excluded`). That way the user can never pick the same account for both.
- `_swap()` exchanges `_sourceId` and `_destinationId` inside `setState()` so the screen redraws.
- If there are not two connected accounts, the screen shows an `EmptyState` with a button to the Accounts tab instead of the form. That prevents a crash when there is nothing to transfer between.
- The amount field calls `setState()` on every keystroke. Each rebuild parses the amount with `parseAmount()` and calls `validateTransfer()` from `AppState`, so an error such as "Exceeds your GCash balance" appears while typing. `canReview` is true only when the amount is above zero and there is no error, and the button is disabled (`onPressed: null`) otherwise.
- The two `TextEditingController`s are disposed in `dispose()` so they do not leak memory.

### Entry 6

**File or feature:**  
`lib/screens/onboarding/connect_accounts_screen.dart` and `lib/screens/onboarding/verify_account_sheet.dart` - Connect Accounts and Verify Account

**What I wrote myself:**  
The onboarding screen that lists every bank and e-wallet with its connection status, and the verification sheet that connects one account with a 6-digit code.

**What I can explain:**  
- The Connect Accounts screen reads `AppScope.of(context)`, so it rebuilds by itself after an account is connected. The button label counts the connected accounts ("Continue with 3 accounts"), and the button is disabled when none are connected. "Skip for now" still finishes onboarding.
- The back button calls `state.signOut`, because leaving onboarding should return the user to the Landing screen.
- In the verify sheet, the code field uses `FilteringTextInputFormatter.digitsOnly` and `maxLength: 6`, and "Verify and connect" is enabled only when exactly 6 digits are entered.
- `_verify()` sets `_busy` to show a loading state, waits briefly so the simulated "verifying" step is visible, then calls `connectAccount()`. It checks `mounted` after each `await`, because the user could close the sheet while it waits, and using `context` after that would cause an error.
- `showVerifyAccountSheet()` returns `true` when the account was connected and shows a SnackBar such as "GCash connected".

I only put code in this section that I actually wrote myself. I do not count something as my own just because I changed variable names, colors, spacing, or other small parts of AI-generated code.

## AI-Assisted Code

This section lists the parts of PeraFolio where AI substantially helped me generate, rewrite, debug, or understand the implementation.

### Entry 1

**File or feature:**  
Supabase data layer: `lib/data/app_store.dart`, `lib/data/supabase_store.dart`, `lib/data/supabase_config.dart`, `supabase/schema.sql`

**How AI helped:**  
AI helped me plan how to separate the data layer from Hive, write the `SupabaseStore` class and the database schema with Row Level Security, and keep the Supabase keys out of the repository with `--dart-define-from-file`.

**What I changed or learned:**  
I learned why `AppState` should depend on an interface (`AppStore`) instead of on Hive or Supabase directly. Now both stores can be swapped without changing any screen, and the tests still run offline on Hive. I also learned that the publishable key is meant to be public and that the real protection comes from the Row Level Security policies, which only let a user read rows where `user_id` matches `auth.uid()`. I fixed the time zone problem with AI's help after my activity times were eight hours off, because Postgres returns times in UTC.

### Entry 2

**File or feature:**  
Project restructure, `device_preview`, and tests: `pubspec.yaml`, `lib/main.dart`, `test/app_state_test.dart`, `test/navigation_test.dart`

**How AI helped:**  
AI moved the leftover Next.js/v0 files out of the repository, created the Flutter project at the repository root with `pubspec.yaml`, migrated `device_preview` to the 3.x API, and wrote the unit and widget tests.

**What I changed or learned:**  
I learned that my week 2 problem came from the project structure: Flutter needs `pubspec.yaml` at the project root. I also learned that `DevicePreview.enable()` has to run before Hive or Supabase start, because `device_preview` 3.x installs its own Flutter binding. I worked through the phone preview problems myself until the preview screens displayed correctly. The tests taught me how to check the transfer logic without clicking through the app, for example that GCash ends at exactly ₱10,435 after a ₱2,000 transfer with the ₱15 fee.

### Entry 3

**File or feature:**  
Polish across the screens, Hive CE persistence, and the `fl_chart` spending chart

**How AI helped:**  
AI polished my existing screen code, cross-checked it against the M7A3 components and theme, and helped me finish Hive CE saving for the M7A1 records and the spending chart.

**What I changed or learned:**  
The screens were built on my foundational code, so I reviewed each change against what I had written. I learned how Hive saves each record as a plain map with `toMap()` and `fromMap()`, so no generated adapters are needed, and that on the web Hive stores its boxes in the browser's IndexedDB.

## Where the AI Got It Wrong

### Case 1: The phone frame disappeared on the deployed app

**What the AI did:**  
When AI migrated `device_preview` to the 3.x API, it called `DevicePreview.enable()` with no arguments in `lib/main.dart`. Its comment said this was "active in debug/profile builds and switches itself off in release builds."

**What went wrong:**  
The app looked correct when I ran it locally with `flutter run`, but GitHub Pages serves a release build. On the deployed app, the iPhone frame was gone and the screens stretched across the whole browser window, which did not match my mockup.

**How I fixed it:**  
I changed the call to `DevicePreview.enable(enabled: true)` so the frame stays on in every build mode, release included, and updated the comment to explain why (commit `7f12b97`). I learned that testing only in debug mode is not enough, because a release build can behave differently.

### Case 2: Bugs in the AI-generated web prototype

**What the AI did:**  
My early web prototype in `app/page.tsx` was generated with v0, an AI tool (the file's metadata says `generator: 'v0.app'`).

**What went wrong:**  
A code review found three bugs in it:

- The verification code field used `.replace(/\\D/g, '')`. The double backslash makes the pattern look for a literal backslash followed by "D", so letters were never removed from the code field.
- The Verify button turned on at 4 digits, but the verify function only accepted exactly 6. A 4- or 5-digit code did nothing and showed no message.
- Transactions used the merchant name as their React `key`, so two transfers to the same account produced duplicate keys.

**How I fixed it:**  
I did not carry the prototype code into the Flutter app, and the leftover Next.js/v0 files were moved out of the repository. In the Flutter version, the verify sheet uses `FilteringTextInputFormatter.digitsOnly` with `maxLength: 6`, and the button is enabled only when exactly 6 digits are entered, so the button and the check use the same rule.

### Case 3: Activity times were eight hours off with Supabase

**What the AI did:**  
AI helped me write the Supabase data layer (`lib/data/supabase_store.dart`). My models save dates with `toIso8601String()`, which writes local time without a time zone offset.

**What went wrong:**  
Postgres stores `timestamptz` values and returns them in UTC. Because the saved times had no offset, the activity times shown in the app were eight hours off from Philippine time.

**How I fixed it:**  
Times are now converted to UTC with `toUtc()` before they are saved (in `_toRow`, for the `dateTime` and `lastSync` keys), and converted back with `toLocal()` when each model is read in `fromMap()`. I learned that a database and an app can disagree about time zones even when both look correct on their own.

## AI Usage Log

### September 20, 2026

**Task:** M7A1 revised proposal

**AI assistance:**  
AI helped organize my revised project scope, feature decisions, persistence choice, risks, and change log.

**My contribution:**  
I provided the actual PeraFolio changes and explained why I kept, changed, simulated, or removed features.

### September 20, 2026

**Task:** M7A3 design system

**AI assistance:**  
AI helped organize the revised design system and summarize the differences between my PRELIM design and M7A2 high-fidelity mockup.

**My contribution:**  
I made the actual design decisions and revisions for PeraFolio.

### September 23, 2026

**Task:** Finals planning and documentation

**AI assistance:**  
AI helped organize the finals requirements into documentation for my PeraFolio project.

**My contribution:**  
I provided my project information, decisions, previous work, problems, and actual experience using AI.

### Week of October 4, 2026

**Task:** Supabase backend and bank brand colors

**AI assistance:**  
AI helped me plan the data layer, write the Supabase schema, and update the README, documentation and security checklist.

**My contribution:**  
I chose the brand color for each bank and e-wallet and replaced BDO with GoTyme in the demo data. I reviewed the sign-in, saving and security policy code until I could explain how each part works.

### October 9, 2026

**Task:** Project restructure, device_preview fix, and polishing the Flutter implementation of the M7A2 screens

**AI assistance:**  
Claude Code (AI) did the following:

- Moved the leftover Next.js/v0 files out of the repository into `../PERAFOLIO-legacy-backup`.
- Created the Flutter project at the repository root with `pubspec.yaml`.
- Migrated `device_preview` to the 3.x API (`DevicePreview.enable()`).
- Polished my existing code for the screens and states, cross-checked against the M7A3 components and theme, Hive CE persistence for the M7A1 records, and the fl_chart spending chart.
- Wrote unit and widget tests.

**My contribution:**  
I wrote the foundational code for all of the screens, which the AI then polished. I did the database setup that happens outside the code, and I troubleshot the phone preview screens until they displayed correctly. I reviewed the changes and tested the app myself.

### October 9, 2026

**Task:** Code review and fix guide

**AI assistance:**  
AI reviewed my repository, listed the errors it found, and wrote a step-by-step guide and a command list for fixing them in VS Code.

**My contribution:**  
I followed the guide on my own machine, ran the commands, and asked for help when I got stuck on a step.

### October 9, 2026

**Task:** Final presentation script and slides

**AI assistance:**  
I asked AI to list down questions I should include in my script.

**My contribution:**  
I reviewed the presentation requirements. The explanations in the video are my own understanding of the code, which I practiced before recording.
