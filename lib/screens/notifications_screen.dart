import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'shuttle_tracking_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  AlertCategory _selected = AlertCategory.all;
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    // In production, replace with a stream/future from the backend or
    // push-notification listener (see PRD section 9: Push Notification
    // Service). Sorted newest-first.
    _notifications = NotificationService.getMockNotifications()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AppNotification> get _filtered {
    if (_selected == AlertCategory.all) return _notifications;
    return _notifications.where((n) => n.type.category == _selected).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(AppNotification n) {
    if (n.isRead) return;
    setState(() => n.isRead = true);
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _dismiss(AppNotification n) {
    setState(() => _notifications.removeWhere((e) => e.id == n.id));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: RefreshIndicator(
          onRefresh: () async {
            // In production: re-fetch notifications from backend/push queue.
            await Future.delayed(const Duration(milliseconds: 600));
            setState(() {
              _notifications = NotificationService.getMockNotifications()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            });
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildTopBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildHeader(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: _buildFilterChips(),
                ),
              ),
              if (_filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: _buildDismissBackground(),
                            onDismissed: (_) => _dismiss(item),
                            child: _NotificationCard(
                              item: item,
                              onTap: () => _markAsRead(item),
                            ),
                          ),
                        );
                      },
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on_outlined, color: primaryBlue),
            SizedBox(width: 6),
            Text(
              'ParkirIn',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEDEDED),
          child: Icon(Icons.person, color: Colors.grey, size: 18),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_unreadCount baru',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Stay updated on your upcoming trips and shuttle status.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tandai semua dibaca',
              style: TextStyle(
                  fontSize: 12,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    Widget chip(String label, AlertCategory value) {
      final bool selected = _selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _selected = value),
          selectedColor: primaryBlue,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: selected ? primaryBlue : Colors.grey.shade300),
          ),
          showCheckmark: false,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Semua', AlertCategory.all),
          chip('Reminder', AlertCategory.reminder),
          chip('Shuttle', AlertCategory.shuttle),
          chip('Booking', AlertCategory.booking),
          chip('Penerbangan', AlertCategory.flight),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Update booking, shuttle, dan penerbangan Anda\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = item.type;
    final bool highlight = type == NotificationType.shuttleArriving ||
        type == NotificationType.overstayWarning;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: highlight
              ? Border(left: BorderSide(color: type.color, width: 4))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: type.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: type.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (type.isPhase2) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Fase 2',
                            style: TextStyle(
                                fontSize: 8, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        item.relativeTime,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black38),
                      ),
                      const Spacer(),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          item.isRead ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                  if (item.bookingCode != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Kode booking: ${item.bookingCode}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                  if (item.actionLabel != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          if (item.type == NotificationType.shuttleArriving) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShuttleTrackingScreen(
                                  bookingCode: item.bookingCode ?? '-',
                                  pickupPointName:
                                      'Titik Jemput A - Lahan Parkir',
                                  destinationName: 'Terminal 3, CGK',
                                ),
                              ),
                            );
                          }
                          // handle actionLabel lain di sini kalau perlu (Lihat Booking, dll)
                        },
                        child: Text(
                          item.actionLabel!,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
