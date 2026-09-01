import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'notification_preferences.dart';
import '../widgets/floating_notification_banner.dart';

class NotificationRepository extends ChangeNotifier {
  NotificationRepository._();
  static final NotificationRepository instance = NotificationRepository._();

  static const _prefsKey = 'notifications_data_v1';

  List<AppNotification> _notifications = [];
  bool _isLoaded = false;

  List<AppNotification> get all {
    final list = List<AppNotification>.from(_notifications);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<AppNotification> get visible {
    final prefs = NotificationPreferences.instance;
    return all.where((n) => prefs.isCategoryEnabled(n.type.category)).toList();
  }

  int get unreadCount => visible.where((n) => !n.isRead).length;

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      _notifications = _seedMockData();
      await _persist();
    } else {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _notifications = list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _notifications = _seedMockData();
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void add(AppNotification notification) {
    _notifications.add(notification);
    notifyListeners();
    _persist();

    final prefs = NotificationPreferences.instance;
    final allowed = prefs.pushEnabled &&
        prefs.isCategoryEnabled(notification.type.category);
    if (allowed) {
      NotificationBannerHost.show(notification);
    }
  }

  void markAsRead(String id) {
    final n = _notifications.where((e) => e.id == id);
    if (n.isEmpty) return;
    n.first.isRead = true;
    notifyListeners();
    _persist();
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    _persist();
  }

  void markMultipleAsRead(Set<String> ids) {
    for (final n in _notifications) {
      if (ids.contains(n.id)) n.isRead = true;
    }
    notifyListeners();
    _persist();
  }

  void remove(String id) {
    _notifications.removeWhere((e) => e.id == id);
    notifyListeners();
    _persist();
  }

  void removeMultiple(Set<String> ids) {
    _notifications.removeWhere((e) => ids.contains(e.id));
    notifyListeners();
    _persist();
  }

  static List<AppNotification> _seedMockData() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'seed1',
        type: NotificationType.shuttleArriving,
        title: 'Shuttle Tersedia di Halte Terdekat',
        description:
            'Shuttle sudah standby di Halte A, siap mengantar Anda ke terminal.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        actionLabel: 'Lacak Shuttle',
        bookingCode: 'PKR-88213',
        isRead: false,
      ),
      AppNotification(
        id: 'seed2',
        type: NotificationType.checkinReminder,
        title: 'Check-in Besok',
        description:
            'Booking Anda di Soekarno-Hatta Park & Fly dimulai besok pukul 08.00.',
        timestamp: now.subtract(const Duration(hours: 3)),
        actionLabel: 'Lihat Booking',
        bookingCode: 'PKR-88213',
        isRead: false,
      ),
      AppNotification(
        id: 'seed3',
        type: NotificationType.checkoutConfirmation,
        title: 'Kendaraan Berhasil Diambil',
        description:
            'Kendaraan Anda (B 1234 CD) telah berhasil check-out. Terima kasih telah menggunakan ParkirIn!',
        timestamp: now.subtract(const Duration(days: 2)),
        actionLabel: 'Lihat Invoice',
        bookingCode: 'PKR-88099',
        isRead: true,
      ),
      AppNotification(
        id: 'seed4',
        type: NotificationType.bookingConfirmation,
        title: 'Booking Berhasil Dikonfirmasi',
        description:
            'Slot parkir Anda telah dikonfirmasi. Kode booking: PKR-86112.',
        timestamp: now.subtract(const Duration(days: 8)),
        actionLabel: 'Lihat QR Code',
        bookingCode: 'PKR-86112',
        isRead: true,
      ),
    ];
  }
}
