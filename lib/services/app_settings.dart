// lib/services/app_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { id, en }

/// Pengaturan aplikasi yang persist antar sesi (tema, ukuran teks, kontras,
/// bahasa). ChangeNotifier supaya MaterialApp bisa rebuild otomatis saat
/// pengaturan berubah dari layar mana pun.
///
/// CATATAN CAKUPAN: infrastruktur ini sudah lengkap dan diterapkan di
/// main.dart + layar-layar pengaturan. Namun karena banyak layar existing
/// menghardcode warna (Colors.white, Color(0xFFF7F8FA), dst) alih-alih
/// memakai Theme.of(context), tampilan dark mode penuh di SEMUA layar
/// perlu migrasi bertahap: ganti warna hardcode dengan
/// Theme.of(context).colorScheme / Theme.of(context).scaffoldBackgroundColor
/// di tiap file. main.dart, ThemeSettingsScreen, dan komponen baru pada
/// jawaban ini sudah theme-aware sebagai contoh polanya.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  ThemeMode themeMode = ThemeMode.light;
  double textScale = 1.0; // 0.9 - 1.4
  bool highContrast = false;
  AppLanguage language = AppLanguage.id;

  static const _kTheme = 'settings_theme_mode';
  static const _kTextScale = 'settings_text_scale';
  static const _kHighContrast = 'settings_high_contrast';
  static const _kLanguage = 'settings_language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_kTheme);
    themeMode = themeStr == 'dark'
        ? ThemeMode.dark
        : (themeStr == 'system' ? ThemeMode.system : ThemeMode.light);
    textScale = prefs.getDouble(_kTextScale) ?? 1.0;
    highContrast = prefs.getBool(_kHighContrast) ?? false;
    final langStr = prefs.getString(_kLanguage);
    language = langStr == 'en' ? AppLanguage.en : AppLanguage.id;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kTheme,
        mode == ThemeMode.dark
            ? 'dark'
            : (mode == ThemeMode.system ? 'system' : 'light'));
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
/// Perluas map ini untuk menerjemahkan layar lain secara bertahap.
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
    'search_title': 'Solusi Parkir Inap\nBandara yang ',
    'search_cta': 'Cari Slot Parkir',
    'settings_theme': 'Tampilan',
    'settings_accessibility': 'Aksesibilitas',
    'settings_language': 'Bahasa',
  };

  static const _en = {
    'nav_search': 'Search',
    'nav_bookings': 'Bookings',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',
    'search_title': 'Airport Overnight\nParking Made ',
    'search_cta': 'Find Parking Slot',
    'settings_theme': 'Appearance',
    'settings_accessibility': 'Accessibility',
    'settings_language': 'Language',
  };
}
