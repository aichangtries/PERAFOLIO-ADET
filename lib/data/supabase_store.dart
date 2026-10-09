import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/financial_account.dart';
import '../models/notification_item.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import 'app_store.dart';

/// Real backend: Supabase Auth + Postgres.
///
/// Tables are created by `supabase/schema.sql`. Every table has a `user_id`
/// column and Row Level Security, so a signed-in user can only ever read or
/// write their own rows. Models keep their camelCase `toMap` keys; rows use
/// snake_case and are converted in [_toRow] / [_fromRow].
class SupabaseStore implements AppStore {
  SupabaseStore(this._client);

  final SupabaseClient _client;

  static const _profiles = 'profiles';
  static const _preferences = 'user_preferences';
  static const _accounts = 'financial_accounts';
  static const _transactions = 'transactions';
  static const _transfers = 'transfers';
  static const _payments = 'payments';
  static const _notifications = 'notifications';

  /// Keys holding a timestamp. Models write local ISO strings without an
  /// offset, so they are converted to UTC before they reach `timestamptz`.
  static const _timestampKeys = {'dateTime', 'lastSync'};

  GoTrueClient get _auth => _client.auth;
  String get _uid => _auth.currentUser!.id;

  @override
  bool get isRemote => true;

  // Authentication ------------------------------------------------------
  @override
  bool get isSignedIn => _auth.currentSession != null;

  @override
  String? get demoAccountEmail => null;

  @override
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // The `handle_new_user` trigger creates the profiles row from this
      // metadata, so it works even when email confirmation is required.
      final res = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
      if (res.session == null) {
        return 'Check ${email.trim()} for a confirmation link, then log in.';
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return _networkError;
    }
  }

  @override
  Future<String?> logIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(email: email.trim(), password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return _networkError;
    }
  }

  @override
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return _networkError;
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static const _networkError =
      'Could not reach the server. Check your connection and try again.';

  // Row mapping -----------------------------------------------------------
  Map<String, dynamic> _toRow(Map<String, dynamic> map) => {
        'user_id': _uid,
        for (final e in map.entries)
          _snake(e.key): _timestampKeys.contains(e.key) && e.value != null
              ? DateTime.parse(e.value as String).toUtc().toIso8601String()
              : e.value,
      };

  static Map<String, dynamic> _fromRow(Map<String, dynamic> row) => {
        for (final e in row.entries)
          if (e.key != 'user_id') _camel(e.key): e.value,
      };

  static String _snake(String key) =>
      key.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  static String _camel(String key) =>
      key.replaceAllMapped(RegExp('_([a-z])'), (m) => m[1]!.toUpperCase());

  Future<List<Map<String, dynamic>>> _select(String table) async {
    final rows = await _client.from(table).select().eq('user_id', _uid);
    return rows.map(_fromRow).toList();
  }

  Future<void> _upsert(String table, List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) return;
    await _client
        .from(table)
        .upsert(maps.map(_toRow).toList(), onConflict: 'user_id,id');
  }

  // Data ------------------------------------------------------------------
  @override
  Future<bool> hasAccounts() async {
    final rows = await _client
        .from(_accounts)
        .select('id')
        .eq('user_id', _uid)
        .limit(1);
    return rows.isNotEmpty;
  }

  @override
  Future<void> clearUserData() async {
    // The profile is the user's real identity, so it is kept.
    for (final table in [
      _transactions,
      _transfers,
      _payments,
      _notifications,
      _accounts,
      _preferences,
    ]) {
      await _client.from(table).delete().eq('user_id', _uid);
    }
  }

  @override
  Future<UserProfile?> loadProfile() async {
    final row = await _client.from(_profiles).select().eq('id', _uid).maybeSingle();
    if (row == null) return null;
    return UserProfile.fromMap({
      'id': row['id'],
      'fullName': row['full_name'] ?? '',
      'email': row['email'] ?? _auth.currentUser?.email ?? '',
      'mobileNumber': row['mobile_number'],
      'homeAddress': row['home_address'],
      'dateOfBirth': row['date_of_birth'],
    });
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final dob = profile.dateOfBirth;
    await _client.from(_profiles).upsert({
      'id': _uid,
      'full_name': profile.fullName,
      'email': profile.email,
      'mobile_number': profile.mobileNumber,
      'home_address': profile.homeAddress,
      'date_of_birth': dob == null
          ? null
          : '${dob.year.toString().padLeft(4, '0')}-'
              '${dob.month.toString().padLeft(2, '0')}-'
              '${dob.day.toString().padLeft(2, '0')}',
    });
  }

  @override
  Future<bool> loadOnboarded() async {
    final row = await _client
        .from(_profiles)
        .select('onboarded')
        .eq('id', _uid)
        .maybeSingle();
    return row?['onboarded'] as bool? ?? false;
  }

  @override
  Future<void> saveOnboarded(bool onboarded) async {
    await _client.from(_profiles).update({'onboarded': onboarded}).eq('id', _uid);
  }

  @override
  Future<UserPreferences> loadPreferences() async {
    final rows = await _select(_preferences);
    return rows.isEmpty ? UserPreferences() : UserPreferences.fromMap(rows.first);
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    await _client.from(_preferences).upsert(_toRow(prefs.toMap()));
  }

  @override
  Future<List<FinancialAccount>> loadAccounts() async =>
      (await _select(_accounts)).map(FinancialAccount.fromMap).toList();

  @override
  Future<void> saveAccounts(List<FinancialAccount> accounts) =>
      _upsert(_accounts, [for (final a in accounts) a.toMap()]);

  @override
  Future<List<Transaction>> loadTransactions() async =>
      (await _select(_transactions)).map(Transaction.fromMap).toList();

  @override
  Future<void> saveTransactions(List<Transaction> transactions) =>
      _upsert(_transactions, [for (final t in transactions) t.toMap()]);

  @override
  Future<void> saveTransfer(Transfer transfer) =>
      _upsert(_transfers, [transfer.toMap()]);

  @override
  Future<void> savePayment(Payment payment) =>
      _upsert(_payments, [payment.toMap()]);

  @override
  Future<List<NotificationItem>> loadNotifications() async =>
      (await _select(_notifications)).map(NotificationItem.fromMap).toList();

  @override
  Future<void> saveNotifications(List<NotificationItem> items) =>
      _upsert(_notifications, [for (final n in items) n.toMap()]);
}
