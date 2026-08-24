import 'package:flutter/material.dart';

enum NotificationType {
  bookingConfirmation,
  checkinReminder,
  shuttleArriving,
  checkoutConfirmation,
  overstayWarning,
  flightStatusChange,
}

enum AlertCategory { all, reminder, shuttle, booking, flight }

extension NotificationTypeX on NotificationType {
  AlertCategory get category {
    switch (this) {
      case NotificationType.checkinReminder:
        return AlertCategory.reminder;
      case NotificationType.shuttleArriving:
        return AlertCategory.shuttle;
      case NotificationType.bookingConfirmation:
      case NotificationType.checkoutConfirmation:
      case NotificationType.overstayWarning:
        return AlertCategory.booking;
      case NotificationType.flightStatusChange:
        return AlertCategory.flight;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.bookingConfirmation:
        return 'BOOKING';
      case NotificationType.checkinReminder:
        return 'REMINDER';
      case NotificationType.shuttleArriving:
        return 'SHUTTLE UPDATE';
      case NotificationType.checkoutConfirmation:
        return 'CHECK-OUT';
      case NotificationType.overstayWarning:
        return 'OVERSTAY WARNING';
      case NotificationType.flightStatusChange:
        return 'FLIGHT UPDATE';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.bookingConfirmation:
        return Icons.qr_code_2;
      case NotificationType.checkinReminder:
        return Icons.event_available;
      case NotificationType.shuttleArriving:
        return Icons.directions_bus_filled;
      case NotificationType.checkoutConfirmation:
        return Icons.verified_outlined;
      case NotificationType.overstayWarning:
        return Icons.warning_amber_rounded;
      case NotificationType.flightStatusChange:
        return Icons.flight_takeoff;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.bookingConfirmation:
        return const Color(0xFF1E5EFF);
      case NotificationType.checkinReminder:
        return const Color(0xFF1E5EFF);
      case NotificationType.shuttleArriving:
        return Colors.orange;
      case NotificationType.checkoutConfirmation:
        return Colors.teal;
      case NotificationType.overstayWarning:
        return Colors.redAccent;
      case NotificationType.flightStatusChange:
        return Colors.purple;
    }
  }

  bool get isPhase2 => this == NotificationType.flightStatusChange;
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? actionLabel;
  final String? bookingCode;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.actionLabel,
    this.bookingCode,
    this.isRead = false,
  });

  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
