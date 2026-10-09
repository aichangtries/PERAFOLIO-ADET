import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/account_selector.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/segmented_tabs.dart';
import 'review_payment_screen.dart';

/// Fictional merchants returned by the simulated QR scan.
const _sampleMerchants = [
  PaymentDraft(merchant: 'Kape Coffee Shop', merchantDetail: 'Merchant ID · CS-98213', amount: 500, sourceAccountId: '', category: 'Food & Dining'),
  PaymentDraft(merchant: 'Corner Mart', merchantDetail: 'Merchant ID · CM-20417', amount: 235, sourceAccountId: '', category: 'Groceries'),
  PaymentDraft(merchant: 'Pampanga Pharmacy', merchantDetail: 'Merchant ID · PP-55102', amount: 612.50, sourceAccountId: '', category: 'Shopping'),
];

/// Screens 18 & 19 — Pay: Scan QR and Pay: Enter Details.
class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  int _tab = 0; // 0 = Scan QR, 1 = Enter details
  String? _sourceId;
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  bool _submitted = false;
  final _random = Random();

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _review(PaymentDraft draft) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReviewPaymentScreen(draft: draft),
    ));
  }

  void _simulateScan(String sourceId) {
    final sample = _sampleMerchants[_random.nextInt(_sampleMerchants.length)];
    _review(PaymentDraft(
      merchant: sample.merchant,
      merchantDetail: sample.merchantDetail,
      amount: sample.amount,
      sourceAccountId: sourceId,
      category: sample.category,
    ));
  }

  String? get _merchantError =>
      _submitted && _merchant.text.trim().isEmpty ? 'Enter a merchant name or mobile number.' : null;
  String? get _amountError =>
      _submitted && parseAmount(_amount.text) <= 0 ? 'Enter an amount greater than ₱0.' : null;

  void _continue(String sourceId) {
    setState(() => _submitted = true);
    if (_merchantError != null || _amountError != null) return;
    final merchant = _merchant.text.trim();
    final isNumber = RegExp(r'^[+\d\s-]+$').hasMatch(merchant);
    _review(PaymentDraft(
      merchant: merchant,
      merchantDetail: isNumber ? 'Mobile number' : 'Entered manually',
      amount: parseAmount(_amount.text),
      sourceAccountId: sourceId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final accounts = state.connectedAccounts;
    final text = Theme.of(context).textTheme;

    if (accounts.isEmpty) {
      return Scaffold(
        appBar: AppTopBar(title: 'Pay', onBack: () => Navigator.of(context).pop()),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: 'Connect an account before making a payment.',
            actionLabel: 'Go to Accounts',
            onAction: () {
              state.setHomeTab(2);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ),
      );
    }

    // Keep the selection valid if an account was disconnected.
    final sourceId = accounts.any((a) => a.id == _sourceId) ? _sourceId! : accounts.first.id;

    final payWith = <Widget>[
      Text('Pay with', style: text.titleMedium),
      const SizedBox(height: AppSpacing.md - 4),
      for (final a in accounts) ...[
        AccountSelector(
          account: a,
          label: 'Pay with',
          selected: a.id == sourceId,
          onTap: () => setState(() => _sourceId = a.id),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    ];

    return Scaffold(
      appBar: AppTopBar(title: 'Pay', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SegmentedTabs(
              labels: const ['Scan QR', 'Enter details'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_tab == 0) ...[
              const _QrFrame(),
              const SizedBox(height: AppSpacing.lg),
              ...payWith,
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(label: 'Simulate scan', onPressed: () => _simulateScan(sourceId)),
            ] else ...[
              AppTextField(
                label: 'Merchant or mobile number',
                hintText: 'e.g. 0917 123 4567',
                controller: _merchant,
                errorText: _merchantError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Amount (₱)',
                hintText: '0.00',
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: _amountError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...payWith,
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(label: 'Continue', onPressed: () => _continue(sourceId)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simulated camera viewfinder with corner brackets and a moving scan line.
/// No camera is used, so this works in any browser.
class _QrFrame extends StatefulWidget {
  const _QrFrame();

  @override
  State<_QrFrame> createState() => _QrFrameState();
}

class _QrFrameState extends State<_QrFrame> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0B),
          borderRadius: BorderRadius.circular(AppSpacing.radius + 6),
          border: Border.all(color: AppColors.outline),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Align(
                alignment: Alignment(0, -0.8 + 1.6 * _controller.value),
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.9),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Align the QR code within the frame\n(camera is simulated on web)',
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    final w = size.width;
    final h = size.height;
    for (final (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (w, 0.0, -1.0, 1.0), (0.0, h, 1.0, -1.0), (w, h, -1.0, -1.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
