import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/financial_account.dart';
import '../models/notification_item.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import 'app_store.dart';
import 'seed_data.dart';

/// Offline Hive CE store (M7A1 "How my app saves data").
///
/// Used by the tests and whenever the app runs without Supabase keys
/// (see `SupabaseConfig`). Each record is stored as a plain Map using its
/// model's toMap/fromMap, so no generated TypeAdapters are needed. On the
/// web, Hive keeps the boxes in the browser's IndexedDB.
///
/// Sign-in here is simulated: passwords are only validated, never stored.
class LocalStorage implements AppStore {
  static const _profileBox = 'user_profile';
  static const _accountsBox = 'financial_accounts';
  static const _transactionsBox = 'transactions';
  static const _transfersBox = 'transfers';
  static const _paymentsBox = 'payments';
  static const _notificationsBox = 'notifications';
  static const _preferencesBox = 'user_preferences';
  static const _sessionBox = 'app_session';

  /// Boxes that hold user data (everything except the session flags).
  static const _dataBoxes = [
    _profileBox,
    _accountsBox,
    _transactionsBox,
    _transfersBox,
    _paymentsBox,
    _notificationsBox,
    _preferencesBox,
  ];

  /// [testPath] lets unit tests store boxes in a temporary folder.
  Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    for (final name in [..._dataBoxes, _sessionBox]) {
      await Hive.openBox(name);
    }
  }

  Box _box(String name) => Hive.box(name);

  @override
  bool get isRemote => false;

  // Simulated authentication -------------------------------------------
  UserProfile get _savedProfile => _readProfile() ?? SeedData.profile();

  @override
  bool get isSignedIn => _box(_sessionBox).get('signedIn', defaultValue: false) as bool;

  @override
  String? get demoAccountEmail => _savedProfile.email;

  @override
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await saveProfile(UserProfile(
      id: _savedProfile.id,
      fullName: fullName.trim(),
      email: email.trim(),
    ));
    await _box(_sessionBox).put('signedIn', true);
    return null;
  }

  @override
  Future<String?> logIn({required String email, required String password}) async {
    final saved = _savedProfile.email;
    if (email.trim().toLowerCase() != saved.toLowerCase()) {
      return 'No PeraFolio account uses this email. Try $saved or sign up.';
    }
    await _box(_sessionBox).put('signedIn', true);
    return null;
  }

  @override
  Future<String?> sendPasswordReset(String email) async =>
      'Password reset is simulated offline. Log in with $demoAccountEmail '
      'and any password of 6+ characters.';

  @override
  Future<void> signOut() => _box(_sessionBox).put('signedIn', false);

  // Data ------------------------------------------------------------------
  @override
  Future<bool> hasAccounts() async => _box(_accountsBox).isNotEmpty;

  @override
  Future<void> clearUserData() async {
    for (final name in _dataBoxes) {
      await _box(name).clear();
    }
  }

  UserProfile? _readProfile() {
    final map = _box(_profileBox).get('profile');
    return map == null ? null : UserProfile.fromMap(map as Map);
  }

  @override
  Future<UserProfile?> loadProfile() async => _readProfile();

  @override
  Future<void> saveProfile(UserProfile profile) =>
      _box(_profileBox).put('profile', profile.toMap());

  @override
  Future<bool> loadOnboarded() async =>
      _box(_sessionBox).get('onboarded', defaultValue: false) as bool;

  @override
  Future<void> saveOnboarded(bool onboarded) =>
      _box(_sessionBox).put('onboarded', onboarded);

  @override
  Future<UserPreferences> loadPreferences() async {
    final map = _box(_preferencesBox).get('preferences');
    return map == null ? UserPreferences() : UserPreferences.fromMap(map as Map);
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) =>
      _box(_preferencesBox).put('preferences', prefs.toMap());

  @override
  Future<List<FinancialAccount>> loadAccounts() async => _box(_accountsBox)
      .values
      .map((v) => FinancialAccount.fromMap(v as Map))
      .toList();

  @override
  Future<void> saveAccounts(List<FinancialAccount> accounts) =>
      _box(_accountsBox).putAll({for (final a in accounts) a.id: a.toMap()});

  @override
  Future<List<Transaction>> loadTransactions() async => _box(_transactionsBox)
      .values
      .map((v) => Transaction.fromMap(v as Map))
      .toList();

  @override
  Future<void> saveTransactions(List<Transaction> transactions) =>
      _box(_transactionsBox).putAll({for (final t in transactions) t.id: t.toMap()});

  @override
  Future<void> saveTransfer(Transfer transfer) =>
      _box(_transfersBox).put(transfer.id, transfer.toMap());

  @override
  Future<void> savePayment(Payment payment) =>
      _box(_paymentsBox).put(payment.id, payment.toMap());

  @override
  Future<List<NotificationItem>> loadNotifications() async => _box(_notificationsBox)
      .values
      .map((v) => NotificationItem.fromMap(v as Map))
      .toList();

  @override
  Future<void> saveNotifications(List<NotificationItem> items) =>
      _box(_notificationsBox).putAll({for (final n in items) n.id: n.toMap()});
}
