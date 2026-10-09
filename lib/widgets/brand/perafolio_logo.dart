import 'package:flutter/material.dart';

/// PeraFolio wordmark: the peso "P" followed by "eraFolio".
class PeraFolioLogo extends StatelessWidget {
  const PeraFolioLogo({super.key, this.height = 64});

  static const asset = 'assets/brand/perafolio_logo.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'PeraFolio',
    );
  }
}

/// The peso "P" symbol on its own, for tight spaces such as app bars.
class PeraFolioMark extends StatelessWidget {
  const PeraFolioMark({super.key, this.size = 32});

  static const asset = 'assets/brand/perafolio_mark.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'PeraFolio',
    );
  }
}
