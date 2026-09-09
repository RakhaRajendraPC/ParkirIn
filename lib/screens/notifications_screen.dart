// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/bookings_api_service.dart';
import '../services/notification_preferences.dart';
import '../services/notifications_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_header_avatar.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_error_view.dart';
import '../widgets/parkirin_header_bar.dart';
import 'booking_detail_screen.dart';
import 'shuttle_tracking_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsApiService _notificationsApi = NotificationsApiService();
  final BookingsApiService _bookingsApi = BookingsApiService();
  AlertCategory _selected = AlertCategory.all;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
    NotificationPreferences.instance.addListener(_onChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    NotificationPreferences.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final json = await _notificationsApi.getNotifications();
      final notifications = json.map(AppNotification.fromApi).toList();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Same "respect the user's category on/off preferences" filtering the
  /// mock repository's `visible` getter used to apply, now over the
  /// real fetched list.
  List<AppNotification> get _visible {
    final prefs = NotificationPreferences.instance;
    final list = _notifications
        .where((n) => prefs.isCategoryEnabled(n.type.category))
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int get _unreadCount => _visible.where((n) => !n.isRead).length;

  List<AppNotification> get _filtered {
    final base = _visible;
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

  Future<void> _bulkMarkRead() async {
    final ids = Set<String>.from(_selectedIds);
    _toggleSelectionMode();
    try {
      await _notificationsApi.markMultipleAsRead(ids);
      if (!mounted) return;
      setState(() {
        for (final n in _notifications) {
          if (ids.contains(n.id)) n.isRead = true;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationsApi.markAllAsRead();
      if (!mounted) return;
      setState(() {
        for (final n in _notifications) {
          n.isRead = true;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _notificationsApi.deleteNotification(id);
      if (!mounted) return;
      setState(() => _notifications.removeWhere((n) => n.id == id));
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _bulkDelete() async {
    final ids = Set<String>.from(_selectedIds);
    _toggleSelectionMode();
    try {
      await _notificationsApi.deleteMultiple(ids);
      if (!mounted) return;
      setState(() => _notifications.removeWhere((n) => ids.contains(n.id)));
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _handleNotificationTap(AppNotification item) async {
    if (_selectionMode) {
      _toggleSelect(item.id);
      return;
    }
    if (item.isRead) return;
    try {
      await _notificationsApi.markAsRead(item.id);
      if (!mounted) return;
      setState(() => item.isRead = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _handleActionTap(AppNotification item) async {
    BookingModel? booking;
    if (item.bookingCode != null) {
      try {
        final json = await _bookingsApi.getBooking(item.bookingCode!);
        booking = BookingModel.fromApi(json);
      } on ApiException {
        booking = null;
      }
    }
    if (!item.isRead) {
      try {
        await _notificationsApi.markAsRead(item.id);
        if (mounted) setState(() => item.isRead = true);
      } on ApiException {
        // Non-critical — the user is navigating on regardless.
      }
    }
    if (!mounted) return;

    final resolvedBooking = booking;
    if (item.type == NotificationType.shuttleArriving &&
        resolvedBooking != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShuttleTrackingScreen(
            bookingCode: resolvedBooking.bookingCode,
            pickupPointName: 'Titik Jemput A - ${resolvedBooking.locationName}',
            destinationName: 'Terminal Keberangkatan',
            userSlotCode: resolvedBooking.slotCode,
            venueAddress: resolvedBooking.locationAddress,
          ),
        ),
      );
    } else if (resolvedBooking != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BookingDetailScreen(booking: resolvedBooking)));
    } else {
      showAppToast(
        context,
        severity: AppSeverity.warning,
        message: 'Booking terkait tidak ditemukan',
      );
    }
  }

  Widget _buildFilterBarWithSelect() {
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
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: selected ? AppColors.primary : Colors.grey.shade300),
          ),
          showCheckmark: false,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip(AppStrings.t('notif_filter_semua'), AlertCategory.all),
                chip(AppStrings.t('notif_filter_reminder'),
                    AlertCategory.reminder),
                chip(AppStrings.t('notif_filter_shuttle'),
                    AlertCategory.shuttle),
                chip(AppStrings.t('notif_filter_booking'),
                    AlertCategory.booking),
                chip(AppStrings.t('notif_filter_flight'), AlertCategory.flight),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: _toggleSelectionMode,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectionMode ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _selectionMode
                      ? AppColors.primary
                      : Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectionMode ? Icons.close : Icons.checklist,
                  size: 14,
                  color: _selectionMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 4),
                Text(
                  _selectionMode
                      ? AppStrings.t('notif_batal')
                      : AppStrings.t('notif_pilih'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectionMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadStrip() {
    final unread = _unreadCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
          child: Text(
            '$unread ${AppStrings.t('notif_new_badge_suffix')}',
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: _markAllAsRead,
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

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final hasNotifications = grouped.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: const ParkirInHeaderBar(actions: [AppHeaderAvatar()]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? NetworkErrorView(
                    onRetry: _loadNotifications,
                    title: AppStrings.t('notif_load_error_title'),
                    message: _errorMessage,
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: _buildFilterBarWithSelect(),
                          ),
                        ),
                        if (_unreadCount > 0 && !_selectionMode)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _buildUnreadStrip(),
                            ),
                          ),
                        if (!hasNotifications)
                          SliverFillRemaining(
                              hasScrollBody: false, child: _buildEmptyState())
                        else
                          ...grouped.entries.expand((entry) => [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    child: Text(_groupLabel(entry.key),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600)),
                                  ),
                                ),
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final item = entry.value[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: _NotificationCard(
                                            item: item,
                                            selectionMode: _selectionMode,
                                            selected:
                                                _selectedIds.contains(item.id),
                                            onTap: () =>
                                                _handleNotificationTap(item),
                                            onActionTap: () =>
                                                _handleActionTap(item),
                                            onDismiss: () =>
                                                _deleteNotification(item.id),
                                          ),
                                        );
                                      },
                                      childCount: entry.value.length,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 8)),
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

    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
          boxShadow: [
            BoxShadow(
              color: type.color.withOpacity(item.isRead ? 0.06 : 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Baris atas: ikon stub + meta + checkbox seleksi ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode) ...[
                    Checkbox(
                      value: selected,
                      onChanged: (_) => onTap(),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 2),
                  ],
                  // Ikon "stub" kotak bersudut, warna solid, dengan lekukan
                  // kecil di sudut kanan-bawah — meniru robekan tiket.
                  _StubIcon(
                      icon: type.icon,
                      color: type.color,
                      isUnread: !item.isRead),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Marker garis vertikal pendek + label kategori,
                            // bukan pill — kesan editorial/tag, bukan chip UI generik.
                            Container(width: 3, height: 11, color: type.color),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                type.label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: type.color,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            if (type.isPhase2) ...[
                              const SizedBox(width: 6),
                              Text(
                                'FASE 2',
                                style: TextStyle(
                                    fontSize: 8.5,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.relativeTime,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Judul & deskripsi, sedikit indent sejajar teks di atas ---
              Padding(
                padding: EdgeInsets.only(left: selectionMode ? 54 : 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16181F),
                        height: 1.2,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          height: 1.45),
                    ),
                  ],
                ),
              ),

              // --- Perforasi ala robekan tiket, muncul kalau ada kode booking / CTA ---
              if (item.bookingCode != null ||
                  (item.actionLabel != null && !selectionMode)) ...[
                const SizedBox(height: 12),
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _PerforationPainter(color: Colors.grey.shade200),
                ),
                const SizedBox(height: 10),
              ],

              // --- Kode booking (gaya kode tiket, monospace) + tombol aksi ---
              if (item.bookingCode != null ||
                  (item.actionLabel != null && !selectionMode))
                Row(
                  children: [
                    if (item.bookingCode != null)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_num_outlined,
                                size: 13, color: Colors.grey.shade400),
                            const SizedBox(width: 5),
                            Text(
                              item.bookingCode!,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    if (item.actionLabel != null && !selectionMode)
                      InkWell(
                        onTap: onActionTap,
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.actionLabel!.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: type.color,
                                  letterSpacing: 0.3),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.north_east_rounded,
                                size: 13, color: type.color),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    if (selectionMode) return card;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: card,
    );
  }
}

/// Ikon "stub" — kotak bersudut dengan satu sudut dipotong miring, meniru
/// gunting di ujung tiket boarding pass. Titik unread ditempel menyatu di
/// sudut, bukan mengambang terpisah di pojok card.
class _StubIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isUnread;

  const _StubIcon(
      {required this.icon, required this.color, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _StubClipper(),
            child: Container(
              width: 44,
              height: 44,
              color: color,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 3, right: 3),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
          ),
          if (isUnread)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StubClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cut = 10.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Garis putus-putus tipis, meniru perforasi sobekan tiket sebagai
/// pembatas antara isi notifikasi dan bagian kode booking/aksi.
class _PerforationPainter extends CustomPainter {
  final Color color;

  const _PerforationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
