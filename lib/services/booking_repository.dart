import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

/// Sumber data tunggal untuk seluruh booking milik user yang sedang login.
/// Data dipersist ke SharedPreferences dalam format JSON, jadi tetap ada
/// setelah app di-restart. Production: ganti dengan fetch dari backend API
/// (persistensi lokal tetap berguna sebagai cache offline-first).
class BookingRepository extends ChangeNotifier {
  BookingRepository._();
  static final BookingRepository instance = BookingRepository._();

  static const _prefsKey = 'bookings_data_v1';

  List<BookingModel> _bookings = [];
  bool _isLoaded = false;

  List<BookingModel> get all => List.unmodifiable(_bookings);

  /// Panggil sekali di main() sebelum runApp(), seperti AppSettings.load().
  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      // Belum pernah disimpan sebelumnya -> isi data contoh awal sekali saja.
      _bookings = BookingModel.mockList();
      await _persist();
    } else {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _bookings = list
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _bookings = BookingModel.mockList();
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void add(BookingModel booking) {
    _bookings.insert(0, booking);
    notifyListeners();
    _persist();
  }

  /// Panggil setelah memutasi field pada objek BookingModel yang sudah ada
  /// (mis. booking.status = BookingStatus.checkIn) supaya perubahan
  /// tersimpan dan listener tahu harus rebuild.
  void refresh() {
    notifyListeners();
    _persist();
  }

  BookingModel? findByCode(String code) {
    try {
      return _bookings.firstWhere((b) => b.bookingCode == code);
    } catch (_) {
      return null;
    }
  }
}
