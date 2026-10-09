import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:perafolio/data/local_storage.dart';
import 'package:perafolio/models/payment.dart';
import 'package:perafolio/state/app_state.dart';

void main() {
  late Directory dir;
  late AppState state;

  Future<AppState> openState({bool signIn = true}) async {
    final storage = LocalStorage();
    await storage.init(testPath: dir.path);
    final s = AppState(storage);
    await s.load();
    if (signIn && !s.isSignedIn) {
      await s.logIn(email: 'alessandra@perafolio.app', password: 'secret123');
    }
    return s;
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('perafolio_test');
    state = await openState();
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('first launch seeds the mockup balances', () {
    expect(state.connectedAccounts.map((a) => a.provider), ['GCash', 'Maya', 'MariBank']);
    expect(state.totalBalance, 45680);
    expect(state.availableAccounts.map((a) => a.provider), ['BPI', 'GoTyme']);
  });

  test('transfer validation catches insufficient balance and same account', () {
    expect(
      state.validateTransfer(sourceId: 'gcash', destinationId: 'maya', amount: 99000),
      'Exceeds your GCash balance',
    );
    expect(
      state.validateTransfer(sourceId: 'gcash', destinationId: 'gcash', amount: 10),
      isNotNull,
    );
    expect(state.validateTransfer(sourceId: 'gcash', destinationId: 'maya', amount: 0), isNotNull);
    expect(state.validateTransfer(sourceId: 'gcash', destinationId: 'maya', amount: 2000), isNull);
  });

  test('transfer moves money, charges the fee and records activity', () async {
    final before = state.transactions.length;
    final transfer = await state.confirmTransfer(sourceId: 'gcash', destinationId: 'maya', amount: 2000);

    expect(state.accountById('gcash')!.balance, 10435); // matches the mockup
    expect(state.accountById('maya')!.balance, 10230);
    expect(transfer.reference, startsWith('TXN-'));
    expect(state.transactions.length, before + 2);
    expect(state.notifications.first.title, 'Transfer successful');
  });

  test('payment deducts from the source account', () async {
    await state.confirmPayment(const PaymentDraft(
      merchant: 'Kape Coffee Shop',
      merchantDetail: 'Merchant ID · CS-98213',
      amount: 500,
      sourceAccountId: 'gcash',
    ));
    expect(state.accountById('gcash')!.balance, 11950); // matches the mockup
  });

  test('data survives an app restart (Hive persistence)', () async {
    await state.confirmTransfer(sourceId: 'gcash', destinationId: 'maya', amount: 1000);
    await state.connectAccount('bpi');
    await state.updateProfile(
      fullName: 'Test User',
      email: 'test@example.com',
      mobileNumber: '',
      homeAddress: '',
    );
    await state.updatePreferences((p) => p.smsAlerts = true);

    await Hive.close(); // simulate closing the app
    final reopened = await openState();

    expect(reopened.accountById('gcash')!.balance, 12450 - 1015);
    expect(reopened.accountById('bpi')!.isConnected, isTrue);
    expect(reopened.profile.fullName, 'Test User');
    expect(reopened.preferences.smsAlerts, isTrue);
  });

  test('simulated log in only accepts the saved account email', () async {
    await state.signOut();
    expect(state.isSignedIn, isFalse);
    expect(await state.logIn(email: 'someone@else.com', password: 'secret123'), isNotNull);
    expect(state.isSignedIn, isFalse);
    expect(await state.logIn(email: 'ALESSANDRA@perafolio.app', password: 'secret123'), isNull);
    expect(state.isSignedIn, isTrue);
    expect(state.isOnboarded, isFalse);
  });

  test('a session is restored on restart and sign-out clears it', () async {
    await state.finishOnboarding();
    await Hive.close();
    final reopened = await openState(signIn: false);
    expect(reopened.isSignedIn, isTrue);
    expect(reopened.isOnboarded, isTrue);

    await reopened.signOut();
    await Hive.close();
    final afterSignOut = await openState(signIn: false);
    expect(afterSignOut.isSignedIn, isFalse);
    expect(afterSignOut.accounts, isEmpty);
  });
}
