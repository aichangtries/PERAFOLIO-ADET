import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
final _moneyWhole = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

/// ₱12,450.00
String formatMoney(double value) => _money.format(value);

/// ₱12,450 (for compact summary cards)
String formatMoneyWhole(double value) => _moneyWhole.format(value);

/// +₱30,000.00 / −₱180.00
String formatSignedMoney(double value, {required bool positive}) =>
    '${positive ? '+' : '−'}${formatMoney(value)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// TODAY / YESTERDAY / SEP 16, 2026 — headers for grouped activity.
String formatDayHeader(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  if (isSameDay(date, today)) return 'TODAY';
  if (isSameDay(date, today.subtract(const Duration(days: 1)))) {
    return 'YESTERDAY';
  }
  return DateFormat('MMM d, y').format(date).toUpperCase();
}

/// 8:16 AM
String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

/// 20 Oct 2026, 2:30 PM
String formatDateTime(DateTime date) =>
    DateFormat('d MMM y, h:mm a').format(date);

/// 14 Mar 1996
String formatDate(DateTime date) => DateFormat('d MMM y').format(date);

/// 2m ago / 1h ago / Yesterday / 3 days ago
String formatRelative(DateTime date, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays} days ago';
}

String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning,';
  if (time.hour < 18) return 'Good afternoon,';
  return 'Good evening,';
}
