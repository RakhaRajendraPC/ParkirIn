import 'package:flutter/material.dart';

enum NotificationType {
  bookingConfirmation,
  checkinReminder,
  checkinConfirmation,
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
      case NotificationType.checkinConfirmation:
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
      case NotificationType.checkinConfirmation:
        return 'CHECK-IN';
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
      case NotificationType.checkinConfirmation:
        return Icons.login;
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
      case NotificationType.checkinConfirmation:
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

  /// The backend has no actionLabel column — every real notification's
  /// action is a fixed label per type, so it's derived here the same way
  /// label/icon/color already are, rather than being stored server-side.
  String? get defaultActionLabel {
    switch (this) {
      case NotificationType.bookingConfirmation:
      case NotificationType.checkinConfirmation:
      case NotificationType.checkoutConfirmation:
      case NotificationType.overstayWarning:
        return 'Lihat Booking';
      case NotificationType.shuttleArriving:
        return 'Lacak Shuttle';
      case NotificationType.checkinReminder:
      case NotificationType.flightStatusChange:
        return null;
    }
  }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'actionLabel': actionLabel,
        'bookingCode': bookingCode,
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.bookingConfirmation,
        ),
        title: json['title'] as String,
        description: json['description'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        actionLabel: json['actionLabel'] as String?,
        bookingCode: json['bookingCode'] as String?,
        isRead: json['isRead'] as bool? ?? false,
      );

  /// Maps a `GET /notifications` row to this model. `category` isn't
  /// read — it's always derived from `type` via [NotificationTypeX.category]
  /// on the client, so the backend's stored value is redundant here.
  /// `actionLabel` likewise has no backend field, see
  /// [NotificationTypeX.defaultActionLabel].
  factory AppNotification.fromApi(Map<String, dynamic> json) {
    final type = NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.bookingConfirmation,
    );
    final booking = json['booking'] as Map<String, dynamic>?;
    return AppNotification(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['createdAt'] as String),
      actionLabel: type.defaultActionLabel,
      bookingCode: booking?['bookingCode'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
