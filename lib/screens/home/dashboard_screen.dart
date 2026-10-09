import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/app_icon_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/financial_summary_card.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/filter_chip_group.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/transaction_row.dart';
import '../notifications/notifications_screen.dart';
import '../pay/pay_screen.dart';
import '../transfer/transfer_screen.dart';
import 'tab_header.dart';
import 'transaction_details_sheet.dart';

enum SpendingPeriod {
  week('This week'),
  month('This month');

  const SpendingPeriod(this.label);
  final String label;
}

const dashboardCategories = [
  'All',
  'Food & Dining',
  'Transportation',
  'Shopping',
  'Bills',
  'Groceries',
];

/// Screen 7 — Dashboard (with category-filter and empty-filter states).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SpendingPeriod _period = SpendingPeriod.week;
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final summary = _Summary.compute(state.transactions, _period, _category, DateTime.now());
    final recent = state.transactions
        .where((t) => _category == 'All' || t.category == _category)
        .take(5)
        .toList();
    final connected = state.connectedAccounts.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      children: [
        // Greeting + notification bell + profile avatar.
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingFor(DateTime.now()),
                    style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  Text(state.profile.firstName, style: text.headlineSmall),
                ],
              ),
            ),
            AppIconButton(
              icon: Icons.notifications_none,
              semanticLabel: 'Notifications',
              showBadge: state.unreadCount > 0,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
              ),
            ),
            ProfileAvatarButton(initial: state.profile.initial),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        Text(
          'TOTAL BALANCE',
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(formatMoney(state.totalBalance), style: text.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Across $connected connected account${connected == 1 ? '' : 's'}',
          style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: FinancialSummaryCard(label: 'Income', value: formatMoneyWhole(summary.income)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FinancialSummaryCard(label: 'Spending', value: formatMoneyWhole(summary.spending)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FinancialSummaryCard(
                label: 'Net',
                value: formatMoneyWhole(summary.net),
                valueColor: summary.net < 0 ? AppColors.error : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md - 4),

        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Transfer',
                icon: Icons.swap_horiz,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TransferScreen()),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SecondaryButton(
                label: 'Pay',
                icon: Icons.qr_code_2,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PayScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Spending chart + period picker.
        Row(
          children: [
            Expanded(
              child: Text(
                _category == 'All' ? 'Spending' : 'Spending · $_category',
                style: text.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<SpendingPeriod>(
              tooltip: 'Change period',
              initialValue: _period,
              onSelected: (p) => setState(() => _period = p),
              itemBuilder: (_) => [
                for (final p in SpendingPeriod.values) PopupMenuItem(value: p, child: Text(p.label)),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_period.label, style: text.bodySmall?.copyWith(color: AppColors.primary)),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md - 4),
        SpendingChart(values: summary.buckets, labels: summary.labels),
        const SizedBox(height: AppSpacing.lg),

        // Recent activity with category filter.
        Row(
          children: [
            Expanded(child: Text('Recent activity', style: text.titleMedium)),
            TextButton(onPressed: () => state.setHomeTab(1), child: const Text('See all')),
          ],
        ),
        FilterChipGroup(
          options: dashboardCategories,
          selected: _category,
          onSelected: (c) => setState(() => _category = c),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            message: _category == 'All'
                ? 'No activity yet.'
                : 'No ${_category.toLowerCase()} activity yet.',
          )
        else
          for (final t in recent)
            TransactionRow(
              transaction: t,
              onTap: () => showTransactionDetails(context, t),
            ),
      ],
    );
  }
}

/// Income / spending / net and chart buckets for the chosen period.
/// Transfers between the user's own accounts are not counted.
class _Summary {
  _Summary(this.income, this.spending, this.buckets, this.labels);

  final double income;
  final double spending;
  final List<double> buckets;
  final List<String> labels;

  double get net => income - spending;

  static _Summary compute(
    List<Transaction> all,
    SpendingPeriod period,
    String category,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    late final DateTime start;
    late final List<String> labels;
    late final int Function(DateTime) bucketOf;

    if (period == SpendingPeriod.week) {
      // Week runs Sunday → Saturday, like the mockup chart.
      start = today.subtract(Duration(days: today.weekday % 7));
      labels = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      bucketOf = (d) => DateTime(d.year, d.month, d.day).difference(start).inDays;
    } else {
      start = DateTime(now.year, now.month);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final weeks = (daysInMonth / 7).ceil();
      labels = [for (var i = 1; i <= weeks; i++) 'Wk $i'];
      bucketOf = (d) => (d.day - 1) ~/ 7;
    }
    final end = period == SpendingPeriod.week
        ? start.add(const Duration(days: 7))
        : DateTime(now.year, now.month + 1);

    var income = 0.0;
    var spending = 0.0;
    final buckets = List<double>.filled(labels.length, 0);
    for (final t in all) {
      if (t.isInternalTransfer) continue;
      if (t.dateTime.isBefore(start) || !t.dateTime.isBefore(end)) continue;
      if (t.isIncome) {
        income += t.amount;
        continue;
      }
      if (category != 'All' && t.category != category) continue;
      spending += t.amount;
      final b = bucketOf(t.dateTime);
      if (b >= 0 && b < buckets.length) buckets[b] += t.amount;
    }
    return _Summary(income, spending, buckets, labels);
  }
}
