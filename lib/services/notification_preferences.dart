import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationPreferences extends ChangeNotifier {
  NotificationPreferences._();
  static final NotificationPreferences instance = NotificationPreferences._();

  bool pushEnabled = true;
  bool emailEnabled = true;
  bool reminderEnabled = true;
  bool shuttleEnabled = true;
  bool bookingEnabled = true;
  bool flightEnabled = false;

  static const _prefix = 'notif_pref_';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    pushEnabled = prefs.getBool('${_prefix}push') ?? true;
    emailEnabled = prefs.getBool('${_prefix}email') ?? true;
    reminderEnabled = prefs.getBool('${_prefix}reminder') ?? true;
    shuttleEnabled = prefs.getBool('${_prefix}shuttle') ?? true;
    bookingEnabled = prefs.getBool('${_prefix}booking') ?? true;
    flightEnabled = prefs.getBool('${_prefix}flight') ?? false;
    notifyListeners();
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', value);
  }

  Future<void> setPush(bool v) async {
    pushEnabled = v;
    notifyListeners();
    await _set('push', v);
  }

  Future<void> setEmail(bool v) async {
    emailEnabled = v;
    notifyListeners();
    await _set('email', v);
  }

  Future<void> setReminder(bool v) async {
    reminderEnabled = v;
    notifyListeners();
    await _set('reminder', v);
  }

  Future<void> setShuttle(bool v) async {
    shuttleEnabled = v;
    notifyListeners();
    await _set('shuttle', v);
  }

  Future<void> setBooking(bool v) async {
    bookingEnabled = v;
    notifyListeners();
    await _set('booking', v);
  }

  Future<void> setFlight(bool v) async {
    flightEnabled = v;
    notifyListeners();
    await _set('flight', v);
  }

  bool isCategoryEnabled(AlertCategory category) {
    switch (category) {
      case AlertCategory.reminder:
        return reminderEnabled;
      case AlertCategory.shuttle:
        return shuttleEnabled;
      case AlertCategory.booking:
        return bookingEnabled;
      case AlertCategory.flight:
        return flightEnabled;
      case AlertCategory.all:
        return true;
    }
  }
}
