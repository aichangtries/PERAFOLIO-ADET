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

PeraFolio is planned as a fully local prototype using Hive CE for structured local data. It currently requires no Firebase/Supabase backend or real API keys. If private configuration is added later, real values must remain gitignored and only placeholders should appear here.

3. How to run it

flutter run -d chrome

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

## Project Structure

```text
PERAFOLIO-ADET/
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
│
├── components/
│   └── ui/
│       └── button.tsx
│
├── flutter/
│   └── lib/
│       ├── core/
│       │   └── theme/
│       │       ├── app_colors.dart
│       │       └── app_theme.dart
│       ├── data/
│       │   └── mock_data.dart
│       ├── models/
│       │   └── bank.dart
│       └── main.dart
│
├── lib/
│   └── utils.ts
│
├── project/
│   ├── AI-USAGE.md
│   └── documentation.md
│
├── public/
│
├── .gitignore
├── components.json
├── next.config.mjs
├── package.json
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── postcss.config.mjs
└── tsconfig.json

Replace this map with the exact final lib/ structure before submission.

6. Screenshots
Refer to this link: https://github.com/HAU-6ADET/student-6ADET-2125-alessandradagdag/blob/main/project/M7A2-compressed.pdf

7. Known issues and next steps

Real bank integration and real-money movement are outside the project scope.
QR/camera scanning is simulated for the web MVP.
Hive CE persistence still needs to be implemented and verified in the final Flutter build.
Final navigation, validation, empty states, responsive layout, and overflow behavior must be tested end-to-end.
Screenshots and this README must be updated to match the finished application.
Possible future improvements include secure real-provider integration, cloud sync, transaction categorization, budgets/savings goals, and real QR scanning.

AI usage
AI is used for explanation, debugging, code assistance, and documentation support. Detailed usage is recorded in AI-USAGE.md.