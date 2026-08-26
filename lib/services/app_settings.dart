// lib/services/app_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { id, en }

/// Pengaturan aplikasi yang persist antar sesi (ukuran teks, kontras,
/// bahasa). Dark mode SENGAJA tidak ada di sini — app hanya pakai 1 tema
/// tetap (terang).
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  double textScale = 1.0; // 0.9 - 1.4
  bool highContrast = false;
  AppLanguage language = AppLanguage.id;

  static const _kTextScale = 'settings_text_scale';
  static const _kHighContrast = 'settings_high_contrast';
  static const _kLanguage = 'settings_language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    textScale = prefs.getDouble(_kTextScale) ?? 1.0;
    highContrast = prefs.getBool(_kHighContrast) ?? false;
    final langStr = prefs.getString(_kLanguage);
    language = langStr == 'en' ? AppLanguage.en : AppLanguage.id;
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    textScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScale, scale);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrast, value);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang == AppLanguage.en ? 'en' : 'id');
    notifyListeners();
  }
}

/// Kamus string ringkas untuk elemen UI inti (bottom nav, judul umum).
class AppStrings {
  static String t(String key) {
    final lang = AppSettings.instance.language;
    final map = lang == AppLanguage.en ? _en : _id;
    return map[key] ?? key;
  }

  static const _id = {
    'nav_search': 'Search',
    'nav_bookings': 'Bookings',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',
  };

  static const _en = {
    'nav_search': 'Search',
    'nav_bookings': 'Bookings',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',
  };
}
