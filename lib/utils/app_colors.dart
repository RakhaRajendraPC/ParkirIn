import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class AppColors {
  static Color get primary => AppSettings.instance.highContrast
      ? const Color(0xFF0033CC)
      : const Color(0xFF1E5EFF);

  static Color get primaryLight => primary.withOpacity(0.1);
}
