PeraFolio

1. Overview

PeraFolio is a Flutter-based personal finance prototype for students, young professionals, and users who manage multiple bank and e-wallet accounts. It brings simulated balances, transactions, transfers, and payments into one interface. It does not connect to real banks, move real money, or store real banking credentials.

2. Setup and installation

Requirements

Flutter SDK: 3.47.4
Dart SDK: 3.13.3
Git
Chrome for the web build


Clone and install:
git clone https://github.com/aichangtries/PERAFOLIO-ADET.git
cd PERAFOLIO-ADET
flutter pub get

PeraFolio stores its data in a Supabase database (Supabase Auth for sign-in, Postgres with Row Level Security for the data). Without Supabase keys it falls back to local Hive CE storage.

Supabase setup (once):
1. Create a project at https://supabase.com.
2. SQL Editor → New query → paste supabase/schema.sql → Run.
3. Copy supabase.example.json to supabase.json and fill in the Project URL and publishable key from Project Settings → API Keys. supabase.json is gitignored; never put a secret or service_role key in it.

3. How to run it

flutter run -d chrome --dart-define-from-file=supabase.json

With Supabase, create an account with Get started; each new account receives fictional demo balances.

Offline (no keys): flutter run -d web-server, then log in with alessandra@perafolio.app and any password of 6+ characters.

When working correctly, the app should open on the PeraFolio landing screen and allow the user to continue through the simulated onboarding flow.

4. Features and usage

Landing - Choose Sign Up or Log In.
Sign Up / Log In - Enter simulated user information with validation feedback.
Connect Accounts - Select simulated banks/e-wallets.
Verify Account - Complete simulated verification.
Dashboard - View total balance, income, spending, savings, spending activity, recent transactions, and Transfer/Pay shortcuts.
Activity - Search/filter combined transaction history, including an empty state.
Accounts - Review connected accounts, balances, and available providers.
Transfer Money - Choose accounts, enter amount/note, review, validate balance, and complete a simulated transfer.
Pay - Use simulated QR or manual details, review, and complete a simulated payment.
Profile and Settings - Manage simulated personal details, notifications, and privacy/security preferences.


5. Project structure

```text
PERAFOLIO-ADET/
├── lib/
│   ├── main.dart            (DevicePreview.enable, Hive init)
│   ├── app.dart             (MaterialApp + AppGate)
│   ├── theme/               (app_theme.dart, app_spacing.dart)
│   ├── models/              (UserProfile, FinancialAccount, Transaction, Transfer, Payment, NotificationItem, UserPreferences)
│   ├── data/                (local_storage.dart - Hive CE, seed_data.dart)
│   ├── state/               (app_state.dart)
│   ├── utils/               (formatters.dart, validators.dart)
│   ├── widgets/             (M7A3 reusable components)
│   └── screens/             (onboarding, home, notifications, profile, transfer, pay)
├── test/                    (app_state_test.dart, navigation_test.dart)
├── web/
├── project/                 (documentation, report, journals, AI usage, security checklist)
├── pubspec.yaml
└── README.md
```

6. Screenshots
Refer to this link: https://github.com/HAU-6ADET/student-6ADET-2125-alessandradagdag/blob/main/project/M7A2-compressed.pdf

7. Known issues and next steps

-Real bank integration and real-money movement are outside the project scope.
-QR/camera scanning is simulated on web ("Simulate scan").
-Sign-in is simulated: passwords are validated but never stored.
-device_preview 3.x only shows the phone frame in debug/profile builds (flutter run); release builds render full-screen.
-Screenshots in this document still need to be captured from the running Flutter app.

AI usage
AI is used for explanation, debugging, code assistance, and documentation support. Detailed usage is recorded in AI-USAGE.md.