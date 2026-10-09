import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/navigation/app_bottom_navigation.dart';
import '../pay/pay_screen.dart';
import 'accounts_screen.dart';
import 'activity_screen.dart';
import 'dashboard_screen.dart';

/// Hosts the three bottom-navigation tabs. An IndexedStack keeps each tab's
/// scroll position and filters when switching between them.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: state.homeTab,
          children: const [
            DashboardScreen(),
            ActivityScreen(),
            AccountsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: state.homeTab,
        onDestinationSelected: state.setHomeTab,
        onPay: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PayScreen()),
        ),
      ),
    );
  }
}
