import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// PeraFolio wordmark: a "P" with peso bars, followed by "eraFolio".
/// Drawn in code so the app needs no image assets.
class PeraFolioLogo extends StatelessWidget {
  const PeraFolioLogo({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'PeraFolio',
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomPaint(
              size: Size(height * 0.72, height),
              painter: _PesoPPainter(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height * 0.02),
              child: Text(
                'eraFolio',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: height * 0.42,
                  height: 1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PesoPPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stem = w * 0.2;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.secondary, AppColors.primary],
      ).createShader(Offset.zero & size);

    // Vertical stem of the P.
    canvas.drawRect(Rect.fromLTWH(0, 0, stem, h), paint);

    // Bowl of the P: a thick stroke from the stem, around a half circle, back.
    final bowlHeight = h * 0.58;
    final stroke = stem * 0.9;
    final radius = (bowlHeight - stroke) / 2;
    final straight = w * 0.62 - radius;
    final bowl = Path()
      ..moveTo(stem / 2, stroke / 2)
      ..lineTo(straight, stroke / 2)
      ..arcToPoint(Offset(straight, bowlHeight - stroke / 2), radius: Radius.circular(radius))
      ..lineTo(stem / 2, bowlHeight - stroke / 2);
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = paint.shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // The two peso bars across the bowl, sticking out on the right.
    final bar = Paint()..color = const Color(0xFFB66BEA);
    final barHeight = bowlHeight * 0.13;
    canvas.drawRect(Rect.fromLTWH(stem * 0.5, bowlHeight * 0.3, w - stem * 0.5, barHeight), bar);
    canvas.drawRect(Rect.fromLTWH(stem * 0.5, bowlHeight * 0.57, w - stem * 0.5, barHeight), bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
