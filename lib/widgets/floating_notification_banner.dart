// lib/widgets/floating_notification_banner.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_repository.dart';
import '../screens/notifications_screen.dart';
import 'app_toast.dart';

/// Host global untuk menampilkan banner notifikasi melayang di atas layar
/// mana pun sedang dibuka. Dipasang lewat navigatorKey di MaterialApp.
///
/// Presentation reuses [AnimatedToastFrame] (the same frame behind
/// [showAppToast]) so this banner slides/fades in and out identically to
/// every other transient surface in the app instead of appearing/
/// disappearing instantly.
class NotificationBannerHost {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void show(AppNotification notification) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedToastFrame(
        accentColor: notification.type.color,
        duration: const Duration(seconds: 5),
        showCloseButton: true,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
        onTap: () {
          NotificationRepository.instance.markAsRead(notification.id);
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(notification.type.icon,
                  color: notification.type.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(notification.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }
}
