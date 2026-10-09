import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/filter_chip_group.dart';
import '../../widgets/inputs/app_search_field.dart';
import '../../widgets/transaction_row.dart';
import 'tab_header.dart';
import 'transaction_details_sheet.dart';

/// Screen 8 — Activity: search + filter + day-grouped feed, with a
/// no-results state.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const _filters = ['All', 'Money in', 'Money out'];
  String _query = '';
  String _filter = 'All';

  List<Transaction> _visible(AppState state) {
    final q = _query.trim().toLowerCase();
    return state.transactions.where((t) {
      if (_filter == 'Money in' && !t.isIncome) return false;
      if (_filter == 'Money out' && t.isIncome) return false;
      if (q.isEmpty) return true;
      return t.merchantOrDescription.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          state.accountName(t.accountId).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = _visible(state);
    final text = Theme.of(context).textTheme;

    // Build "TODAY" / "YESTERDAY" / date headers between rows.
    final children = <Widget>[];
    String? lastHeader;
    for (final t in items) {
      final header = formatDayHeader(t.dateTime);
      if (header != lastHeader) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
          child: Text(
            header,
            style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2),
          ),
        ));
        lastHeader = header;
      }
      children.add(TransactionRow(
        transaction: t,
        onTap: () => showTransactionDetails(context, t),
      ));
    }

    return Column(
      children: [
        const TabHeader(title: 'Activity'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              AppSearchField(
                hintText: 'Search merchant or account',
                query: _query,
                onChanged: (q) => setState(() => _query = q),
              ),
              const SizedBox(height: AppSpacing.md - 4),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChipGroup(
                  options: _filters,
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    EmptyState(
                      icon: Icons.search_off,
                      message: _query.trim().isNotEmpty
                          ? 'Nothing matches "${_query.trim()}".'
                          : 'No ${_filter == 'All' ? '' : '${_filter.toLowerCase()} '}activity yet.',
                      actionLabel: _query.isNotEmpty || _filter != 'All' ? 'Clear filters' : null,
                      onAction: () => setState(() {
                        _query = '';
                        _filter = 'All';
                      }),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  children: children,
                ),
        ),
      ],
    );
  }
}
