import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_repository.dart';
import '../services/booking_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'booking_detail_screen.dart';
import 'shuttle_tracking_screen.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/app_header_avatar.dart';

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
          builder: (context) => BookingDetailScreen(booking: booking),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking terkait tidak ditemukan')),
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
    final unread = _repo.unreadCount;
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 0),
            child: AppLogoBadge(height: 38),
          ),
          leadingWidth: 160,
          title: null,
          centerTitle: true,
          actions: const [AppHeaderAvatar()],
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(milliseconds: 400)),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _buildFilterBarWithSelect(),
                ),
              ),
              if (_repo.unreadCount > 0 && !_selectionMode)
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

// ============================================================================
// TEMPELKAN KODE INI DI BARIS PALING BAWAH FILE notifications_screen.dart
// ============================================================================

class PreviewNotificationScreen extends StatelessWidget {
  const PreviewNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Preview Notifikasi',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kartu Notifikasi Tunggal (Preview Desain Baru)
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7)
                        .withOpacity(0.045), // Latar highlight
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Bulat Kategori
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Color(0xFF0284C7),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 13),
                      // Konten Teks & Tombol Action
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row Header: Badge Kategori + Phase + Waktu + Dot Merah Unread
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7)
                                        .withOpacity(0.11),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Text(
                                    'SHUTTLE',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Fase 2',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text('·',
                                    style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 7),
                                Text(
                                  '5 mnt lalu',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      shape: BoxShape.circle),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Judul Notifikasi
                            const Text(
                              'Shuttle Hampir Tiba!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D29),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Deskripsi Notifikasi
                            Text(
                              'Armada shuttle Anda diperkirakan akan sampai di titik jemput dalam kurun waktu 3 menit.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                  height: 1.5),
                            ),
                            const SizedBox(height: 10),
                            // Kode Booking dengan Icon Tiket
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_number_outlined,
                                    size: 12, color: Colors.grey.shade400),
                                const SizedBox(width: 5),
                                Text(
                                  'BK-882910',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Tombol Aksi (Action Button)
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0284C7).withOpacity(0.09),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Lacak Shuttle',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0284C7)),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(Icons.chevron_right_rounded,
                                        size: 16, color: Color(0xFF0284C7)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
