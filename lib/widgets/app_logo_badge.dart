// lib/widgets/app_logo_badge.dart
import 'package:flutter/material.dart';

/// Badge logo brand untuk header. Logo sudah berwarna (bukan versi putih
/// polos), jadi ditampilkan langsung tanpa background pill supaya lebih
/// bersih dan proporsinya lebih besar/jelas terlihat.
class AppLogoBadge extends StatelessWidget {
  final double height;

  const AppLogoBadge({super.key, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/logo_inapandara_color.png',
      height: height,
      fit: BoxFit.cover,
      alignment: Alignment.centerLeft,
    );
  }
}
