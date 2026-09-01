import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

class BookingRepository extends ChangeNotifier {
  BookingRepository._();
  static final BookingRepository instance = BookingRepository._();

  static const _prefsKey = 'bookings_data_v1';

  List<BookingModel> _bookings = [];
  bool _isLoaded = false;

  List<BookingModel> get all => List.unmodifiable(_bookings);

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
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
