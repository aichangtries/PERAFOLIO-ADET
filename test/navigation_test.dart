import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perafolio/app.dart';
import 'package:perafolio/data/local_storage.dart';
import 'package:perafolio/screens/home/dashboard_screen.dart';
import 'package:perafolio/state/app_state.dart';
import 'package:perafolio/widgets/buttons/secondary_button.dart';

/// Walks every main flow at iPhone 16 size (393×852). Any RenderFlex
/// overflow or broken navigation makes this test fail.
void main() {
  late Directory dir;

  // Hive boxes stay open here (closing them under the widget tester's fake
  // clock never completes); app_state_test.dart covers close + reopen.
  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold the box files; the OS temp folder is fine.
    }
  });

  testWidgets('every core flow is reachable and functional', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    late AppState state;
    await tester.runAsync(() async {
      dir = await Directory.systemTemp.createTemp('perafolio_nav');
      final storage = LocalStorage();
      await storage.init(testPath: dir.path);
      state = AppState(storage);
      await state.load();
    });

    // Lets Hive finish real disk writes, then advances animations.
    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    // Keeps letting Hive write until [finder] appears (several writes in a row).
    Future<void> pumpUntil(Finder finder) async {
      for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await settle();
    }

    await tester.pumpWidget(PeraFolioApp(state: state));
    await settle();

    // --- Landing → Sign up with validation ----------------------------
    expect(find.text('All your money.\nOne place.'), findsOneWidget);
    await tap(find.text('Get started'));
    expect(find.text('Create your account'), findsOneWidget);
    await tap(find.text('Create account'));
    expect(find.text('Enter your full name.'), findsWidgets);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Test Student');
    await tester.enterText(fields.at(1), 'not-an-email');
    await tester.enterText(fields.at(2), 'secret123');
    await tap(find.text('Create account'));
    expect(find.text('Enter a valid email address.'), findsWidgets);
    await tester.enterText(fields.at(1), 'test@example.com');
    await tap(find.text('Create account'));
    await pumpUntil(find.text('Continue with 3 accounts'));

    // --- Connect accounts + verify ------------------------------------
    expect(find.text('Continue with 3 accounts'), findsOneWidget);
    await tap(find.text('Connect').first);
    expect(find.text('Verify BPI'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '002125');
    await tap(find.text('Verify and connect'));
    await pumpUntil(find.text('Continue with 4 accounts'));
    expect(find.text('Continue with 4 accounts'), findsOneWidget);
    await tap(find.text('Continue with 4 accounts'));

    // --- Dashboard ----------------------------------------------------
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget); // first name greeting
    await tap(find.text('Transportation'));
    expect(find.text('Angkas'), findsOneWidget);
    expect(find.text('Coffee Bean'), findsNothing);
    await tap(find.text('All').first);

    // --- Transfer with insufficient balance, then a valid one ----------
    await tap(find.widgetWithText(SecondaryButton, 'Transfer'));
    await tester.enterText(find.byType(TextField).first, '99000');
    await settle();
    expect(find.text('Exceeds your GCash balance'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '2000');
    await settle();
    await tap(find.text('Review transfer'));
    expect(find.text('Balance after: ₱10,435.00'), findsOneWidget);
    await tap(find.text('Confirm transfer'));
    await pumpUntil(find.text('Transfer complete'));
    expect(find.text('Transfer complete'), findsOneWidget);
    await tap(find.text('View in activity'));

    // --- Activity search + empty state --------------------------------
    expect(find.text('Transfer to Maya'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await settle();
    expect(find.text('Nothing matches "zzz".'), findsOneWidget);
    await tap(find.text('Clear filters'));

    // --- Accounts tab + account details --------------------------------
    await tap(find.text('Accounts').last);
    expect(find.text('Available to connect'), findsOneWidget);
    await tap(find.text('GCash').first);
    expect(find.text('Sync now'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // dismiss sheet
    await settle();

    // --- Pay: scan QR → review → success --------------------------------
    await tap(find.text('Pay').last);
    expect(find.text('Simulate scan'), findsOneWidget);
    await tap(find.text('Enter details'));
    await tap(find.text('Continue'));
    expect(find.text('Enter a merchant name or mobile number.'), findsOneWidget);
    await tap(find.text('Scan QR'));
    await tap(find.text('Simulate scan'));
    expect(find.text('Confirm payment'), findsOneWidget);
    await tap(find.text('Confirm payment'));
    await pumpUntil(find.text('Payment sent'));
    expect(find.text('Payment sent'), findsOneWidget);
    await tap(find.text('Done'));
    expect(state.homeTab, 0);
    expect(find.byType(DashboardScreen), findsOneWidget);

    // --- Notifications (scroll the dashboard back to the top first) -----
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await settle();
    await tap(find.byTooltip('Notifications'));
    expect(find.text('Payment sent'), findsOneWidget);
    await tap(find.text('Mark all as read'));
    expect(state.unreadCount, 0);
    await tap(find.byTooltip('Back'));

    // --- Profile and settings ------------------------------------------
    await tap(find.byTooltip('Open profile').first);
    await tap(find.text('Personal details'));
    await tap(find.text('Save changes'));
    expect(find.text('Changes saved'), findsOneWidget);
    await tap(find.byTooltip('Back'));
    await tap(find.text('Notifications'));
    await tap(find.text('SMS alerts'));
    expect(state.preferences.smsAlerts, isTrue);
    await tap(find.byTooltip('Back'));
    await tap(find.text('Security & privacy'));
    await tap(find.text('Change PIN'));
    expect(find.text('Update PIN'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await settle();
    await tap(find.byTooltip('Back'));

    // --- Sign out returns to Landing --------------------------------
    await tap(find.text('Sign out').first);
    await tap(find.text('Sign out').last);
    expect(find.text('Get started'), findsOneWidget);
    expect(state.isSignedIn, isFalse);
  });
}
