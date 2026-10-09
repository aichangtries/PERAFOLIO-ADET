import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/app_store.dart';
import '../data/seed_data.dart';
import '../models/financial_account.dart';
import '../models/notification_item.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../utils/formatters.dart';

/// Single source of truth for the app. Screens read from it and call its
/// methods; every change is written to the [AppStore] (Supabase, or Hive
/// offline) and then [notifyListeners] rebuilds the widgets that depend on it.
class AppState extends ChangeNotifier {
  AppState(this._storage);

  final AppStore _storage;
  final _random = Random();

  static const double transferFee = 15;

  UserProfile _profile = UserProfile(id: '', fullName: '', email: '');
  UserPreferences _preferences = UserPreferences();
  List<FinancialAccount> _accounts = [];
  List<Transaction> _transactions = [];
  List<NotificationItem> _notifications = [];
  bool _signedIn = false;
  bool _onboarded = false;
  int _homeTab = 0;

  // ---------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------

  /// Restores the saved session and, when signed in, the user's data.
  Future<void> load() async {
    _signedIn = _storage.isSignedIn;
    if (_signedIn) await _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!await _storage.hasAccounts()) await _seed();
    _profile = await _storage.loadProfile() ?? SeedData.profile();
    _preferences = await _storage.loadPreferences();
    _accounts = await _storage.loadAccounts();
    _transactions = await _storage.loadTransactions();
    _notifications = await _storage.loadNotifications();
    _onboarded = await _storage.loadOnboarded();
    _sort();
  }

  /// Gives a new user the fictional demo accounts and activity.
  Future<void> _seed() async {
    final now = DateTime.now();
    // Keep a profile created at sign-up; only the offline store starts empty.
    if (await _storage.loadProfile() == null) {
      await _storage.saveProfile(SeedData.profile());
    }
    await _storage.savePreferences(SeedData.preferences());
    await _storage.saveAccounts(SeedData.accounts(now));
    await _storage.saveTransactions(SeedData.transactions(now));
    await _storage.saveNotifications(SeedData.notifications(now));
  }

  void _sort() {
    // Storage order is not guaranteed; keep the mockup's account order.
    final order = SeedData.accountOrder;
    int rank(FinancialAccount a) {
      final i = order.indexOf(a.id);
      return i == -1 ? order.length : i;
    }
    _accounts.sort((a, b) => rank(a).compareTo(rank(b)));
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _notifications.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Deletes the user's financial data and restores the original demo data.
  Future<void> resetDemoData() async {
    await _storage.clearUserData();
    await _loadUserData();
    _onboarded = true;
    await _storage.saveOnboarded(true);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------

  UserProfile get profile => _profile;
  UserPreferences get preferences => _preferences;
  bool get isSignedIn => _signedIn;
  bool get isOnboarded => _onboarded;
  int get homeTab => _homeTab;

  /// True when data is saved to Supabase rather than this device.
  bool get usesRemoteDatabase => _storage.isRemote;

  /// Email of the offline demo account; null when using Supabase.
  String? get demoAccountEmail => _storage.demoAccountEmail;

  List<FinancialAccount> get accounts => List.unmodifiable(_accounts);
  List<FinancialAccount> get connectedAccounts =>
      _accounts.where((a) => a.isConnected).toList();
  List<FinancialAccount> get availableAccounts =>
      _accounts.where((a) => !a.isConnected).toList();

  /// Activity only shows records from connected accounts.
  List<Transaction> get transactions {
    final connectedIds = connectedAccounts.map((a) => a.id).toSet();
    return _transactions.where((t) => connectedIds.contains(t.accountId)).toList();
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  double get totalBalance =>
      connectedAccounts.fold(0, (sum, a) => sum + a.balance);

  FinancialAccount? accountById(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  String accountName(String id) => accountById(id)?.provider ?? 'Unknown';

  // ---------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------

  void setHomeTab(int index) {
    _homeTab = index;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------

  /// Creates an account. Returns null on success, otherwise a message to
  /// show; check [isSignedIn] to tell an error from "confirm your email".
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final message = await _storage.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
    if (!_storage.isSignedIn) return message;
    await _startSession(onboarded: false);
    return null;
  }

  /// Returns an error message, or null when the login succeeds.
  Future<String?> logIn({required String email, required String password}) async {
    final error = await _storage.logIn(email: email, password: password);
    if (error != null) return error;
    await _startSession();
    return null;
  }

  /// Returns an error message, or null when the reset email was sent.
  Future<String?> sendPasswordReset(String email) =>
      _storage.sendPasswordReset(email);

  /// Loads the user's data. [onboarded] overrides the saved flag (a brand
  /// new account always starts with Connect Accounts).
  Future<void> _startSession({bool? onboarded}) async {
    await _loadUserData();
    if (onboarded != null) {
      _onboarded = onboarded;
      await _storage.saveOnboarded(onboarded);
    }
    _signedIn = true;
    _homeTab = 0;
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    _onboarded = true;
    await _storage.saveOnboarded(true);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _storage.signOut();
    _signedIn = false;
    _onboarded = false;
    _homeTab = 0;
    _accounts = [];
    _transactions = [];
    _notifications = [];
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Accounts
  // ---------------------------------------------------------------------

  Future<void> connectAccount(String id) async {
    final account = accountById(id);
    if (account == null) return;
    account
      ..connectionStatus = ConnectionStatus.connected
      ..lastSync = DateTime.now();
    await _storage.saveAccounts([account]);
    await _notify(
      title: '${account.provider} connected',
      message: 'Your simulated ${account.provider} account is now linked to PeraFolio.',
      type: NotificationType.account,
    );
    notifyListeners();
  }

  Future<void> disconnectAccount(String id) async {
    final account = accountById(id);
    if (account == null) return;
    account
      ..connectionStatus = ConnectionStatus.available
      ..lastSync = null;
    await _storage.saveAccounts([account]);
    notifyListeners();
  }

  Future<void> syncAccount(String id) async {
    final account = accountById(id);
    if (account == null) return;
    account.lastSync = DateTime.now();
    await _storage.saveAccounts([account]);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Transfers & payments
  // ---------------------------------------------------------------------

  /// Returns an error message, or null when the transfer is allowed.
  String? validateTransfer({
    required String sourceId,
    required String destinationId,
    required double amount,
  }) {
    final source = accountById(sourceId);
    if (source == null || accountById(destinationId) == null) {
      return 'Choose two connected accounts';
    }
    if (sourceId == destinationId) return 'Choose a different destination';
    if (amount <= 0) return 'Enter an amount greater than ₱0';
    if (amount + transferFee > source.balance) {
      return 'Exceeds your ${source.provider} balance';
    }
    return null;
  }

  Future<Transfer> confirmTransfer({
    required String sourceId,
    required String destinationId,
    required double amount,
    String note = '',
  }) async {
    final error = validateTransfer(
      sourceId: sourceId,
      destinationId: destinationId,
      amount: amount,
    );
    if (error != null) throw StateError(error);

    final source = accountById(sourceId)!;
    final destination = accountById(destinationId)!;
    final now = DateTime.now();
    final transfer = Transfer(
      id: _newId('tr'),
      sourceAccountId: sourceId,
      destinationAccountId: destinationId,
      amount: amount,
      fee: transferFee,
      dateTime: now,
      reference: _newReference(),
      note: note.trim(),
    );

    source.balance -= transfer.total;
    destination.balance += amount;
    await _storage.saveAccounts([source, destination]);
    await _storage.saveTransfer(transfer);

    await _addTransaction(Transaction(
      id: _newId('tx'),
      accountId: sourceId,
      type: TransactionType.moneyOut,
      amount: transfer.total,
      merchantOrDescription: 'Transfer to ${destination.provider}',
      category: 'Transfer',
      dateTime: now,
    ));
    await _addTransaction(Transaction(
      id: _newId('tx'),
      accountId: destinationId,
      type: TransactionType.moneyIn,
      amount: amount,
      merchantOrDescription: 'Transfer from ${source.provider}',
      category: 'Transfer',
      dateTime: now,
    ));
    await _notify(
      title: 'Transfer successful',
      message: 'You sent ${formatMoney(amount)} to ${destination.provider}.',
      type: NotificationType.transfer,
    );
    notifyListeners();
    return transfer;
  }

  String? validatePayment(PaymentDraft draft) {
    final source = accountById(draft.sourceAccountId);
    if (source == null) return 'Choose an account to pay with';
    if (draft.merchant.trim().isEmpty) return 'Enter a merchant or mobile number';
    if (draft.amount <= 0) return 'Enter an amount greater than ₱0';
    if (draft.total > source.balance) {
      return 'Exceeds your ${source.provider} balance';
    }
    return null;
  }

  Future<Payment> confirmPayment(PaymentDraft draft) async {
    final error = validatePayment(draft);
    if (error != null) throw StateError(error);

    final source = accountById(draft.sourceAccountId)!;
    final now = DateTime.now();
    final payment = Payment(
      id: _newId('pay'),
      merchant: draft.merchant,
      amount: draft.amount,
      sourceAccountId: source.id,
      fee: draft.fee,
      dateTime: now,
      reference: _newReference(),
    );

    source.balance -= payment.total;
    await _storage.saveAccounts([source]);
    await _storage.savePayment(payment);
    await _addTransaction(Transaction(
      id: _newId('tx'),
      accountId: source.id,
      type: TransactionType.moneyOut,
      amount: payment.total,
      merchantOrDescription: draft.merchant,
      category: draft.category,
      dateTime: now,
    ));
    await _notify(
      title: 'Payment sent',
      message: 'You paid ${formatMoney(draft.amount)} to ${draft.merchant} from ${source.provider}.',
      type: NotificationType.payment,
    );
    notifyListeners();
    return payment;
  }

  Future<void> _addTransaction(Transaction tx) async {
    _transactions.add(tx);
    _sort();
    await _storage.saveTransactions([tx]);
  }

  // ---------------------------------------------------------------------
  // Profile, preferences, notifications
  // ---------------------------------------------------------------------

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String homeAddress,
    DateTime? dateOfBirth,
  }) async {
    _profile
      ..fullName = fullName.trim()
      ..email = email.trim()
      ..mobileNumber = mobileNumber.trim()
      ..homeAddress = homeAddress.trim()
      ..dateOfBirth = dateOfBirth;
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> updatePreferences(void Function(UserPreferences p) change) async {
    change(_preferences);
    await _storage.savePreferences(_preferences);
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    for (final n in _notifications) {
      if (n.id == id && !n.isRead) {
        n.isRead = true;
        await _storage.saveNotifications([n]);
      }
    }
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      n.isRead = true;
    }
    await _storage.saveNotifications(unread);
    notifyListeners();
  }

  Future<void> _notify({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final item = NotificationItem(
      id: _newId('n'),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
    );
    _notifications.add(item);
    _sort();
    await _storage.saveNotifications([item]);
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';

  String _newReference() =>
      'TXN-${(10000000 + _random.nextInt(89999999)).toString()}';

}

/// Makes [AppState] available to the whole widget tree. Widgets that call
/// [AppScope.of] rebuild whenever the state calls notifyListeners().
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without subscribing (for callbacks).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
