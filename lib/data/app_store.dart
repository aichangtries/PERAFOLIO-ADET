import '../models/financial_account.dart';
import '../models/notification_item.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';

/// Where [AppState] reads and writes everything.
///
/// - [SupabaseStore] is the real backend: Supabase Auth for sign-in and a
///   Postgres database (protected by Row Level Security) for the data.
/// - [LocalStorage] keeps everything in Hive on this device. It is used for
///   tests and when the app runs without Supabase keys.
///
/// Every data method works on the signed-in user's records only.
abstract class AppStore {
  /// True when data lives in a remote database (Supabase).
  bool get isRemote;

  // Authentication ------------------------------------------------------
  bool get isSignedIn;

  /// Email of the built-in demo account, or null when there is none.
  String? get demoAccountEmail;

  /// Creates an account. Returns null on success, otherwise a message.
  /// When the backend needs the email confirmed first, [isSignedIn] stays
  /// false and the message says so.
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Returns null on success, otherwise an error message.
  Future<String?> logIn({required String email, required String password});

  /// Sends a password-reset email. Returns null on success.
  Future<String?> sendPasswordReset(String email);

  Future<void> signOut();

  // Data ------------------------------------------------------------------
  Future<bool> hasAccounts();

  /// Deletes the user's financial data so it can be re-seeded.
  Future<void> clearUserData();

  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<bool> loadOnboarded();
  Future<void> saveOnboarded(bool onboarded);

  Future<UserPreferences> loadPreferences();
  Future<void> savePreferences(UserPreferences prefs);

  Future<List<FinancialAccount>> loadAccounts();
  Future<void> saveAccounts(List<FinancialAccount> accounts);

  Future<List<Transaction>> loadTransactions();
  Future<void> saveTransactions(List<Transaction> transactions);

  Future<void> saveTransfer(Transfer transfer);
  Future<void> savePayment(Payment payment);

  Future<List<NotificationItem>> loadNotifications();
  Future<void> saveNotifications(List<NotificationItem> items);
}
