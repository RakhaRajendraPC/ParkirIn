// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_repository.dart';
//import '../services/notification_preferences.dart';
import '../services/booking_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'booking_detail_screen.dart';
import 'shuttle_tracking_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repo = NotificationRepository.instance;
  AlertCategory _selected = AlertCategory.all;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<AppNotification> get _filtered {
    final base = _repo.visible;
    if (_selected == AlertCategory.all) return base;
    return base.where((n) => n.type.category == _selected).toList();
  }

  /// Kelompokkan notifikasi ke bucket tanggal. Kunci di sini SENGAJA
  /// tetap dalam identifier bahasa Inggris tidak berubah (today/yesterday/
  /// week/older), supaya logika grouping stabil terlepas dari bahasa
  /// yang aktif. Label yang ditampilkan diterjemahkan lewat _groupLabel().
  Map<String, List<AppNotification>> get _grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<AppNotification>> groups = {
      'today': [],
      'yesterday': [],
      'week': [],
      'older': [],
    };

    for (final n in _filtered) {
      final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      if (d == today) {
        groups['today']!.add(n);
      } else if (d == yesterday) {
        groups['yesterday']!.add(n);
      } else if (d.isAfter(weekAgo)) {
        groups['week']!.add(n);
      } else {
        groups['older']!.add(n);
      }
    }
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  String _groupLabel(String key) {
    switch (key) {
      case 'today':
        return AppStrings.t('notif_group_today');
      case 'yesterday':
        return AppStrings.t('notif_group_yesterday');
      case 'week':
        return AppStrings.t('notif_group_week');
      default:
        return AppStrings.t('notif_group_older');
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _bulkMarkRead() {
    _repo.markMultipleAsRead(_selectedIds);
    _toggleSelectionMode();
  }

  void _bulkDelete() {
    _repo.removeMultiple(_selectedIds);
    _toggleSelectionMode();
  }

  void _handleNotificationTap(AppNotification item) {
    if (_selectionMode) {
      _toggleSelect(item.id);
      return;
    }
    _repo.markAsRead(item.id);
  }

  void _handleActionTap(AppNotification item) {
    final booking = item.bookingCode != null
        ? BookingRepository.instance.findByCode(item.bookingCode!)
        : null;
    _repo.markAsRead(item.id);

    if (item.type == NotificationType.shuttleArriving && booking != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShuttleTrackingScreen(
            bookingCode: booking.bookingCode,
            pickupPointName: 'Titik Jemput A - ${booking.locationName}',
            destinationName: 'Terminal Keberangkatan',
            userSlotCode: booking.slotCode,
            venueAddress: booking.locationAddress,
          ),
        ),
      );
    } else if (booking != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking terkait tidak ditemukan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final hasNotifications = grouped.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
          title: Text(
            AppStrings.t('search_appbar_title'),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEDEDED),
                child: Icon(Icons.person, color: Colors.grey, size: 18),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(milliseconds: 400)),
          child: CustomScrollView(
            slivers: [
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
              if (!hasNotifications)
                SliverFillRemaining(
                    hasScrollBody: false, child: _buildEmptyState())
              else
                ...grouped.entries.expand((entry) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(_groupLabel(entry.key),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600)),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = entry.value[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(
                                  item: item,
                                  selectionMode: _selectionMode,
                                  selected: _selectedIds.contains(item.id),
                                  onTap: () => _handleNotificationTap(item),
                                  onActionTap: () => _handleActionTap(item),
                                  onDismiss: () => _repo.remove(item.id),
                                ),
                              );
                            },
                            childCount: entry.value.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ]),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
        bottomNavigationBar: _selectionMode && _selectedIds.isNotEmpty
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2))
                  ]),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _bulkMarkRead,
                          icon: const Icon(Icons.mark_email_read_outlined,
                              size: 16),
                          label: Text(
                              '${AppStrings.t('notif_mark_read_btn')} (${_selectedIds.length})',
                              style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _bulkDelete,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: Text(
                              '${AppStrings.t('notif_delete_btn')} (${_selectedIds.length})',
                              style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildHeader() {
    final unread = _repo.unreadCount;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    AppStrings.t('notif_title'),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                          '$unread ${AppStrings.t('notif_new_badge_suffix')}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(AppStrings.t('notif_subtitle'),
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _toggleSelectionMode,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero),
              icon: Icon(_selectionMode ? Icons.close : Icons.checklist,
                  size: 14),
              label: Text(
                  _selectionMode
                      ? AppStrings.t('notif_batal')
                      : AppStrings.t('notif_pilih'),
                  style: const TextStyle(fontSize: 11)),
            ),
            if (unread > 0)
              TextButton(
                onPressed: () => _repo.markAllAsRead(),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero),
                child: Text(
                  AppStrings.t('notif_mark_all_read'),
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    Widget chip(String label, AlertCategory value) {
      final selected = _selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _selected = value),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: selected ? AppColors.primary : Colors.grey.shade300)),
          showCheckmark: false,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(AppStrings.t('notif_filter_semua'), AlertCategory.all),
          chip(AppStrings.t('notif_filter_reminder'), AlertCategory.reminder),
          chip(AppStrings.t('notif_filter_shuttle'), AlertCategory.shuttle),
          chip(AppStrings.t('notif_filter_booking'), AlertCategory.booking),
          chip(AppStrings.t('notif_filter_flight'), AlertCategory.flight),
        ],
      ),
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
            Text(AppStrings.t('notif_empty_title'),
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(AppStrings.t('notif_empty_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.item,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onActionTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final type = item.type;
    final highlight = type == NotificationType.shuttleArriving ||
        type == NotificationType.overstayWarning;

    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: highlight
              ? Border(left: BorderSide(color: type.color, width: 4))
              : (selected ? Border.all(color: AppColors.primary) : null),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectionMode) ...[
              Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(type.icon, color: type.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(type.label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: type.color,
                              letterSpacing: 0.5)),
                      if (type.isPhase2) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(AppStrings.t('notif_phase2_badge'),
                              style: TextStyle(
                                  fontSize: 8, color: Colors.grey.shade600)),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(item.relativeTime,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black38)),
                      const Spacer(),
                      if (!item.isRead)
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              item.isRead ? FontWeight.w600 : FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.4)),
                  if (item.bookingCode != null) ...[
                    const SizedBox(height: 6),
                    Text(
                        '${AppStrings.t('notif_booking_code_label')}${item.bookingCode}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                  ],
                  if (item.actionLabel != null && !selectionMode) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: onActionTap,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: Text(item.actionLabel!,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
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

    if (selectionMode) return card;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: card,
    );
  }
}
