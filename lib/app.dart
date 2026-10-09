import 'package:flutter/material.dart';

import 'screens/home/home_shell.dart';
import 'screens/onboarding/connect_accounts_screen.dart';
import 'screens/onboarding/landing_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class PeraFolioApp extends StatelessWidget {
  const PeraFolioApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'PeraFolio',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        darkTheme: appTheme,
        themeMode: ThemeMode.dark,
        home: const AppGate(),
      ),
    );
  }
}

/// Chooses the first screen from the saved session:
/// signed out → Landing, signed in but not onboarded → Connect Accounts,
/// otherwise → the main app with bottom navigation.
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final Widget screen;
    if (!state.isSignedIn) {
      screen = const LandingScreen(key: ValueKey('landing'));
    } else if (!state.isOnboarded) {
      screen = const ConnectAccountsScreen(key: ValueKey('connect'));
    } else {
      screen = const HomeShell(key: ValueKey('home'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: screen,
    );
  }
}
