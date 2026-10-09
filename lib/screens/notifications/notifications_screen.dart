import 'package:flutter/material.dart';

import '../../models/notification_item.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards/account_badge.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/navigation/app_top_bar.dart';

/// Screen 14 — Notifications (unread / read states). Tap one to mark it read.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.notifications;
    return Scaffold(
      appBar: AppTopBar(title: 'Notifications', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: state.unreadCount == 0 ? null : state.markAllNotificationsRead,
                child: const Text('Mark all as read'),
              ),
            ),
            if (items.isEmpty)
              const EmptyState(icon: Icons.notifications_none, message: "You're all caught up."),
            for (final n in items) ...[
              _NotificationCard(item: n, onTap: () => state.markNotificationRead(n.id)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  IconData get _icon => switch (item.type) {
        NotificationType.transfer => Icons.check,
        NotificationType.payment => Icons.qr_code_2,
        NotificationType.security => Icons.shield_outlined,
        NotificationType.account => Icons.account_balance_wallet_outlined,
        NotificationType.bill => Icons.notifications_none,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unread = !item.isRead;
    return Semantics(
      label: unread ? 'Unread' : null,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md - 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: unread ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outline,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountBadge(label: '', icon: _icon, highlighted: unread, size: 36),
                const SizedBox(width: AppSpacing.md - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.message, style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatRelative(item.dateTime),
                        style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, left: AppSpacing.sm),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
