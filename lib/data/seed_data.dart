import '../models/financial_account.dart';
import '../models/notification_item.dart';
import '../models/transaction.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';

/// Fictional demo data written to Hive on first launch (or after
/// "Reset demo data"). Nothing here is a real person, bank balance or account.
abstract final class SeedData {
  static UserProfile profile() => UserProfile(
        id: 'user-1',
        fullName: 'Alessandra Dagdag',
        email: 'alessandra@perafolio.app',
        mobileNumber: '0917 123 4567',
        homeAddress: 'Angeles City, Pampanga',
        dateOfBirth: DateTime(1996, 3, 14),
      );

  static UserPreferences preferences() => UserPreferences();

  /// Display order of accounts (GCash, Maya, MariBank, BPI, GoTyme).
  static const accountOrder = ['gcash', 'maya', 'maribank', 'bpi', 'gotyme'];

  static List<FinancialAccount> accounts(DateTime now) => [
        FinancialAccount(
          id: 'gcash',
          provider: 'GCash',
          accountType: 'E-Wallet',
          balance: 12450,
          connectionStatus: ConnectionStatus.connected,
          lastSync: now,
        ),
        FinancialAccount(
          id: 'maya',
          provider: 'Maya',
          accountType: 'E-Wallet',
          balance: 8230,
          connectionStatus: ConnectionStatus.connected,
          lastSync: now,
        ),
        FinancialAccount(
          id: 'maribank',
          provider: 'MariBank',
          accountType: 'Savings Account',
          balance: 25000,
          connectionStatus: ConnectionStatus.connected,
          lastSync: now,
        ),
        FinancialAccount(
          id: 'bpi',
          provider: 'BPI',
          accountType: 'Bank',
          balance: 15200,
          connectionStatus: ConnectionStatus.available,
        ),
        FinancialAccount(
          id: 'gotyme',
          provider: 'GoTyme',
          accountType: 'Bank',
          balance: 9800,
          connectionStatus: ConnectionStatus.available,
        ),
      ];

  static List<Transaction> transactions(DateTime now) {
    DateTime at(int daysAgo, int hour, int minute) {
      final day = now.subtract(Duration(days: daysAgo));
      return DateTime(day.year, day.month, day.day, hour, minute);
    }

    Transaction out(String id, String account, String merchant,
            String category, double amount, DateTime when) =>
        Transaction(
          id: id,
          accountId: account,
          type: TransactionType.moneyOut,
          amount: amount,
          merchantOrDescription: merchant,
          category: category,
          dateTime: when,
        );

    // "Today" entries use an early time so they are never in the future.
    return [
      out('seed-1', 'maya', 'Coffee Bean', 'Food & Dining', 180, at(0, 0, 5)),
      Transaction(
        id: 'seed-2',
        accountId: 'maribank',
        type: TransactionType.moneyIn,
        amount: 30000,
        merchantOrDescription: 'Salary',
        category: 'Income',
        dateTime: at(1, 8, 16),
      ),
      out('seed-3', 'gcash', 'Supermarket', 'Groceries', 1250, at(1, 18, 40)),
      out('seed-4', 'gcash', 'Jollibee', 'Food & Dining', 465, at(2, 12, 30)),
      out('seed-5', 'gcash', 'PLDT Bill', 'Bills', 1899, at(3, 9, 10)),
      out('seed-6', 'maya', 'Uniqlo', 'Shopping', 2390, at(4, 15, 45)),
      out('seed-7', 'maribank', 'Shopee', 'Shopping', 1850, at(5, 20, 5)),
      out('seed-8', 'maya', 'SM Store', 'Shopping', 1520, at(6, 16, 20)),
      out('seed-9', 'gcash', 'Angkas', 'Transportation', 180, at(9, 7, 50)),
      out('seed-10', 'gcash', 'Meralco Bill', 'Bills', 2980, at(12, 10, 0)),
    ];
  }

  static List<NotificationItem> notifications(DateTime now) => [
        NotificationItem(
          id: 'seed-n1',
          title: 'New device sign-in',
          message: 'Your account was accessed from a new device in Angeles City.',
          dateTime: now.subtract(const Duration(hours: 1)),
          type: NotificationType.security,
        ),
        NotificationItem(
          id: 'seed-n2',
          title: 'Bill due soon',
          message: 'Your Meralco bill of ₱3,120.00 is due in 3 days.',
          dateTime: now.subtract(const Duration(days: 2)),
          type: NotificationType.bill,
        ),
        NotificationItem(
          id: 'seed-n3',
          title: 'Welcome to PeraFolio',
          message:
              'Every account, balance and transaction here is simulated demo data.',
          dateTime: now.subtract(const Duration(days: 3)),
          type: NotificationType.account,
          isRead: true,
        ),
      ];
}
