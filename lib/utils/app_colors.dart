// lib/utils/app_colors.dart
import 'package:flutter/material.dart';
import '../services/app_settings.dart';

/// Pengganti pola `static const Color primaryBlue = Color(0xFF1E5EFF);`
/// yang selama ini hardcode di tiap layar. Dengan helper ini, warna
/// brand ikut berubah saat toggle Kontras Tinggi diaktifkan, tanpa
/// perlu context (karena AppSettings singleton ChangeNotifier).
class AppColors {
  static Color get primary => AppSettings.instance.highContrast
      ? const Color(0xFF0033CC)
      : const Color(0xFF1E5EFF);

  static Color get primaryLight => primary.withOpacity(0.1);
}
