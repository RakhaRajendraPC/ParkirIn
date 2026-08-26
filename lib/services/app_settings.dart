// lib/services/app_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { id, en }

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  double textScale = 1.0;
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

class AppStrings {
  static String t(String key) {
    final lang = AppSettings.instance.language;
    final map = lang == AppLanguage.en ? _en : _id;
    return map[key] ?? key;
  }

  static const _id = {
    // Bottom nav
    'nav_search': 'Search',
    'nav_bookings': 'Bookings',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',

    // Search screen
    'search_appbar_title': 'ParkirIn',
    'search_hero_badge': 'PARK & FLY',
    'search_title_1': 'Solusi Parkir Inap\nBandara yang ',
    'search_title_2': 'Aman & Mudah',
    'search_pilih_bandara': 'PILIH BANDARA',
    'search_masuk': 'MASUK',
    'search_keluar': 'KELUAR',
    'search_cta': 'Cari Slot Parkir',
    'search_promo_badge': 'PROMO PENGGUNA BARU',
    'search_promo_title': 'Diskon 20%',
    'search_promo_code_label': 'Gunakan kode: ',
    'search_ground_transport_title': 'Transportasi Lanjutan',
    'search_ground_transport_sub':
        'Taksi, bus, travel, kereta bandara, dan lainnya.',
    'search_why_title': 'Kenapa Pilih ParkirIn?',
    'search_feature_slot_title': 'Slot Terjamin',
    'search_feature_slot_sub': 'Pasti dapat tempat, fasilitas aman 24/7.',
    'search_feature_biaya_title': 'Biaya Transparan',
    'search_feature_biaya_sub': 'Tanpa biaya tersembunyi saat checkout.',
    'search_shuttle_title': 'Lacak Shuttle Real-time',
    'search_shuttle_sub':
        'Pantau posisi bus jemputan langsung dari HP anda menuju terminal.',
    'search_active_booking_parked': 'Kendaraan Sedang Parkir',
    'search_active_booking_waiting': 'Booking Aktif Menunggu Check-in',
    'search_malam': 'malam',

    // Bookings screen
    'bookings_appbar_title': 'My Bookings',
    'bookings_tab_aktif': 'Aktif',
    'bookings_tab_selesai': 'Selesai',
    'bookings_tab_dibatalkan': 'Dibatalkan',
    'bookings_tab_kedaluwarsa': 'Kedaluwarsa',
    'bookings_empty': 'Belum ada booking',
    'bookings_slot_label': 'Slot',
    'bookings_checkin_btn': 'Check-in',
    'bookings_checkout_btn': 'Check-out',
    'bookings_qr_btn': 'Lihat QR Code',
    'bookings_expired_note':
        'Dibatalkan otomatis karena tidak check-in sesuai batas waktu',

    // Profile screen
    'profile_appbar_title': 'Profile',
    'profile_gold_member': 'Gold Member',
    'profile_my_details_title': 'My Details',
    'profile_my_details_sub': 'Personal info, ID, password',
    'profile_payment_title': 'Payment Methods',
    'profile_payment_sub': 'Cards, e-wallets, bank transfer',
    'profile_help_title': 'Help Center',
    'profile_help_sub': 'FAQs, contact support',
    'profile_favorites_title': 'Favorit Saya',
    'profile_favorites_sub': 'Lokasi parkir yang Anda simpan',
    'profile_notif_settings_title': 'Pengaturan Notifikasi',
    'profile_notif_settings_sub': 'Atur jenis notifikasi yang diterima',
    'profile_vehicles_title': 'Kendaraan Saya',
    'profile_vehicles_sub': 'Kelola plat nomor tersimpan',
    'profile_invoice_title': 'Riwayat Invoice',
    'profile_invoice_sub': 'Unduh struk transaksi Anda',
    'profile_loyalty_title': 'Loyalty & Membership',
    'profile_referral_title': 'Undang Teman',
    'profile_referral_sub': 'Dapatkan Rp 25.000 per referral',
    'profile_terms_title': 'Syarat & Ketentuan',
    'profile_terms_sub': 'Kebijakan layanan & privasi',
    'profile_accessibility_title': 'Aksesibilitas',
    'profile_accessibility_sub': 'Ukuran teks & kontras tinggi',
    'profile_language_title': 'Bahasa',
    'profile_language_sub': 'Indonesia / English',
    'profile_delete_account_title': 'Hapus Akun & Data',
    'profile_delete_account_sub': 'Kelola atau hapus data pribadi Anda',
    'profile_logout': 'Logout',
    'profile_logout_confirm_title': 'Logout',
    'profile_logout_confirm_msg': 'Apakah anda yakin ingin keluar?',
    'profile_cancel': 'Batal',

    // Notifications screen
    'notif_title': 'Notifications',
    'notif_subtitle': 'Stay updated on your upcoming trips and shuttle status.',
    'notif_mark_all_read': 'Tandai semua dibaca',
    'notif_pilih': 'Pilih',
    'notif_batal': 'Batal',
    'notif_filter_semua': 'Semua',
    'notif_filter_reminder': 'Reminder',
    'notif_filter_shuttle': 'Shuttle',
    'notif_filter_booking': 'Booking',
    'notif_filter_flight': 'Penerbangan',
    'notif_group_today': 'Hari Ini',
    'notif_group_yesterday': 'Kemarin',
    'notif_group_week': 'Minggu Ini',
    'notif_group_older': 'Lebih Lama',
    'notif_empty_title': 'Belum ada notifikasi',
    'notif_empty_sub':
        'Update booking, shuttle, dan penerbangan Anda\nakan muncul di sini.',
    'notif_mark_read_btn': 'Tandai Dibaca',
    'notif_delete_btn': 'Hapus',
  };

  static const _en = {
    'nav_search': 'Search',
    'nav_bookings': 'Bookings',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',
    'search_appbar_title': 'ParkirIn',
    'search_hero_badge': 'PARK & FLY',
    'search_title_1': 'Airport Overnight\nParking Made ',
    'search_title_2': 'Safe & Easy',
    'search_pilih_bandara': 'SELECT AIRPORT',
    'search_masuk': 'CHECK-IN',
    'search_keluar': 'CHECK-OUT',
    'search_cta': 'Find Parking Slot',
    'search_promo_badge': 'NEW USER PROMO',
    'search_promo_title': '20% Off',
    'search_promo_code_label': 'Use code: ',
    'search_ground_transport_title': 'Onward Transport',
    'search_ground_transport_sub':
        'Taxi, bus, shuttle, airport train, and more.',
    'search_why_title': 'Why Choose ParkirIn?',
    'search_feature_slot_title': 'Guaranteed Slot',
    'search_feature_slot_sub': 'Guaranteed space, secure 24/7 facilities.',
    'search_feature_biaya_title': 'Transparent Pricing',
    'search_feature_biaya_sub': 'No hidden fees at checkout.',
    'search_shuttle_title': 'Track Shuttle in Real-time',
    'search_shuttle_sub':
        'Monitor the shuttle bus location straight from your phone to the terminal.',
    'search_active_booking_parked': 'Vehicle Currently Parked',
    'search_active_booking_waiting': 'Active Booking Awaiting Check-in',
    'search_malam': 'nights',
    'bookings_appbar_title': 'My Bookings',
    'bookings_tab_aktif': 'Active',
    'bookings_tab_selesai': 'Completed',
    'bookings_tab_dibatalkan': 'Cancelled',
    'bookings_tab_kedaluwarsa': 'Expired',
    'bookings_empty': 'No bookings yet',
    'bookings_slot_label': 'Slot',
    'bookings_checkin_btn': 'Check-in',
    'bookings_checkout_btn': 'Check-out',
    'bookings_qr_btn': 'View QR Code',
    'bookings_expired_note':
        'Automatically cancelled due to missed check-in deadline',
    'profile_appbar_title': 'Profile',
    'profile_gold_member': 'Gold Member',
    'profile_my_details_title': 'My Details',
    'profile_my_details_sub': 'Personal info, ID, password',
    'profile_payment_title': 'Payment Methods',
    'profile_payment_sub': 'Cards, e-wallets, bank transfer',
    'profile_help_title': 'Help Center',
    'profile_help_sub': 'FAQs, contact support',
    'profile_favorites_title': 'My Favorites',
    'profile_favorites_sub': 'Parking locations you saved',
    'profile_notif_settings_title': 'Notification Settings',
    'profile_notif_settings_sub': 'Manage which notifications you receive',
    'profile_vehicles_title': 'My Vehicles',
    'profile_vehicles_sub': 'Manage saved license plates',
    'profile_invoice_title': 'Invoice History',
    'profile_invoice_sub': 'Download your transaction receipts',
    'profile_loyalty_title': 'Loyalty & Membership',
    'profile_referral_title': 'Invite Friends',
    'profile_referral_sub': 'Get Rp 25,000 per referral',
    'profile_terms_title': 'Terms & Conditions',
    'profile_terms_sub': 'Service policy & privacy',
    'profile_accessibility_title': 'Accessibility',
    'profile_accessibility_sub': 'Text size & high contrast',
    'profile_language_title': 'Language',
    'profile_language_sub': 'Indonesia / English',
    'profile_delete_account_title': 'Delete Account & Data',
    'profile_delete_account_sub': 'Manage or delete your personal data',
    'profile_logout': 'Logout',
    'profile_logout_confirm_title': 'Logout',
    'profile_logout_confirm_msg': 'Are you sure you want to log out?',
    'profile_cancel': 'Cancel',
    'notif_title': 'Notifications',
    'notif_subtitle': 'Stay updated on your upcoming trips and shuttle status.',
    'notif_mark_all_read': 'Mark all as read',
    'notif_pilih': 'Select',
    'notif_batal': 'Cancel',
    'notif_filter_semua': 'All',
    'notif_filter_reminder': 'Reminder',
    'notif_filter_shuttle': 'Shuttle',
    'notif_filter_booking': 'Booking',
    'notif_filter_flight': 'Flight',
    'notif_group_today': 'Today',
    'notif_group_yesterday': 'Yesterday',
    'notif_group_week': 'This Week',
    'notif_group_older': 'Older',
    'notif_empty_title': 'No notifications yet',
    'notif_empty_sub':
        'Updates on your bookings, shuttle, and flight\nwill appear here.',
    'notif_mark_read_btn': 'Mark as Read',
    'notif_delete_btn': 'Delete',
  };
}
