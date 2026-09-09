// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'shuttle_tracking_screen.dart';
import 'search_results_screen.dart';
import 'ground_transport_screen.dart';
import 'notifications_screen.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/bookings_api_service.dart';
import '../services/notifications_api_service.dart';
import '../services/notification_preferences.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'booking_detail_screen.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/material_symbol.dart';
import '../widgets/parkirin_header_bar.dart';
import '../widgets/stub_icon.dart' show PerforationDivider;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String airportName = 'CGK - Soekarno Hatta';
  DateTime checkIn = DateTime(2026, 10, 12, 8, 0);
  DateTime checkOut = DateTime(2026, 10, 15, 18, 0);

  final BookingsApiService _bookingsApi = BookingsApiService();
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
    _loadActiveBooking();
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  /// Real backend fetch, replacing the old mock `BookingRepository` binding
  /// — mirrors the pattern already used in bookings_screen.dart. Best-effort:
  /// the active-booking slab just doesn't render if this fails, same as any
  /// other optional Home-screen module.
  Future<void> _loadActiveBooking() async {
    try {
      final json = await _bookingsApi.getBookings();
      final bookings = json.map(BookingModel.fromApi).toList();
      if (!mounted) return;
      setState(() => _bookings = bookings);
    } catch (_) {
      // Offline / unauthenticated at first paint — Home still works without
      // the active-booking slab.
    }
  }

  BookingModel? get _activeBooking {
    final active = _bookings.where((b) =>
        b.status == BookingStatus.dipesan || b.status == BookingStatus.checkIn);
    return active.isEmpty ? null : active.first;
  }

  List<BannerSlide> get _banners => [
        BannerSlide(
          imagePath: 'assets/images/hero_banner.png',
          badgeText: 'PARK & FLY',
          badgeIcon: Icons.local_parking,
          title: 'Parkir Aman\nSampai Pulang',
          subtitle: 'Lahan parkir 24 jam dengan pengawasan CCTV & satpam.',
          accent: AppColors.primary,
        ),
        const BannerSlide(
          imagePath: 'assets/images/hero_banner2.jpeg',
          badgeText: 'GRATIS SHUTTLE',
          badgeIcon: Icons.directions_bus_filled,
          title: 'Antar-Jemput\nLangsung ke Terminal',
          subtitle:
              'Layanan shuttle gratis dan cepat setiap 15 menit ke terminal.',
          accent: Color(0xFFFF8A00),
        ),
        const BannerSlide(
          imagePath: 'assets/images/hero_banner3.jpeg',
          badgeText: 'PROMO PENGGUNA BARU',
          badgeIcon: Icons.local_offer_rounded,
          title: 'Diskon 20%\nBooking Pertama',
          subtitle:
              'Berlaku untuk semua lokasi parkir inap yang ada di bandara.',
          accent: Color(0xFF4B4FE0),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: const ParkirInHeaderBar(actions: [_NotificationBell()]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  HeroBannerCarousel(slides: _banners),
                  if (_activeBooking != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -40,
                      child: _buildActiveBookingSlab(),
                    ),
                ],
              ),
              SizedBox(height: _activeBooking != null ? 54 : 22),
              _buildSeamDivider(),
              const SizedBox(height: 22),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildEyebrowLabel('PERJALANAN KAMU'),
              const SizedBox(height: 11),
              _buildSearchCard(),
              const SizedBox(height: 16),
              _buildSearchButton(),
              const SizedBox(height: 16),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildWhyChooseUsTitle(),
              const SizedBox(height: 4),
              _buildWhyChooseList(),
              const SizedBox(height: 12),
              _buildEyebrowLabel('AKSES & TRANSPORTASI'),
              const SizedBox(height: 10),
              _buildAksesGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlaps the hero by 58px in the target design; scaled to ~40px here
  /// since this carousel's hero is shorter (180px vs. the target's static
  /// 272px), keeping a proportionally similar overlap.
  Widget _buildActiveBookingSlab() {
    final b = _activeBooking;
    if (b == null) return const SizedBox.shrink();

    final isParked = b.status == BookingStatus.checkIn;
    final statusLabel = isParked
        ? AppStrings.t('search_active_booking_parked')
        : AppStrings.t('search_active_booking_waiting');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailScreen(booking: b)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ACTIVE BOOKING',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                  ),
                ),
                const Spacer(),
                MaterialSymbol(MSymbols.northEast,
                    color: Colors.white, size: 18, weight: 300),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              statusLabel,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    b.locationName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 12.5),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withOpacity(0.45), width: 1),
                  ),
                  child: Text(
                    '${AppStrings.t('bookings_slot_label').toUpperCase()} ${b.slotCode}',
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 1px hairline seam between the hero zone and the content zone below it
  /// — present in the target design, absent from the previous layout.
  Widget _buildSeamDivider() {
    return Container(height: 1, color: AppColors.ink.withOpacity(0.14));
  }

  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            height: 1.28,
            letterSpacing: -0.4),
        children: [
          TextSpan(text: AppStrings.t('search_title_1')),
          TextSpan(
              text: AppStrings.t('search_title_2'),
              style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }

  /// Small mono section eyebrow — matches the target design's
  /// "PERJALANAN KAMU" / "AKSES & TRANSPORTASI" labels.
  Widget _buildEyebrowLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'IBM Plex Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.8,
            color: AppColors.label));
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('CGK',
                            style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColors.ink)),
                        const SizedBox(width: 9),
                        const Text('Soekarno Hatta',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.ink)),
                      ],
                    ),
                  ],
                ),
              ),
              MaterialSymbol(MSymbols.verified,
                  color: AppColors.primary, size: 20, weight: 300),
            ],
          ),
          const SizedBox(height: 14),
          const PerforationDivider(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  symbol: MSymbols.flightTakeoff,
                  iconColor: const Color(0xFFFF8A00),
                  label: AppStrings.t('search_masuk'),
                  date: checkIn,
                  onTap: () => _pickDate(isCheckIn: true),
                ),
              ),
              Container(
                  height: 34,
                  width: 1,
                  color: AppColors.hairline,
                  margin: const EdgeInsets.symmetric(horizontal: 10)),
              Expanded(
                child: _DateTile(
                  symbol: MSymbols.flightLand,
                  iconColor: AppColors.primary,
                  label: AppStrings.t('search_keluar'),
                  date: checkOut,
                  onTap: () => _pickDate(isCheckIn: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                  airportName: airportName,
                  checkIn: checkIn,
                  checkOut: checkOut),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A00),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MaterialSymbol(MSymbols.search,
                color: Colors.white, size: 20, weight: 300),
            const SizedBox(width: 8),
            Text(AppStrings.t('search_cta'),
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }

  /// Plain white card, dashed border, no shadow/icon — matches the target
  /// design's compact promo treatment exactly (replacing the previous
  /// tinted, icon-and-badge card).
  Widget _buildPromoBanner() {
    return CustomPaint(
      painter: const _DashedBorderPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.t('search_promo_badge')} · ${AppStrings.t('search_promo_title')}'
                        .toUpperCase(),
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                        color: AppColors.label),
                  ),
                  const SizedBox(height: 4),
                  const Text('TERBANGAMAN',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Mono',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.ink)),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'PAKAI KODE',
                style: TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsTitle() {
    return Text(AppStrings.t('search_why_title'),
        style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.2));
  }

  /// Plain numbered list (01/02), hairline top-dividers, no cards/shadow/
  /// icons — replaces the previous 2-column card grid.
  Widget _buildWhyChooseList() {
    final items = [
      (
        AppStrings.t('search_feature_slot_title'),
        AppStrings.t('search_feature_slot_sub'),
      ),
      (
        AppStrings.t('search_feature_biaya_title'),
        AppStrings.t('search_feature_biaya_sub'),
      ),
    ];
    return Column(
      children: List.generate(items.length, (i) {
        final (title, subtitle) = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hairline))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text('0${i + 1}',
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.body,
                            height: 1.55)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 2-column grid, white fill, hairline border per cell, plain outlined
  /// icon at top — replaces the previous two stacked tinted rows.
  Widget _buildAksesGrid() {
    // IntrinsicHeight forces a bounded-height measurement pass before the
    // Row's CrossAxisAlignment.stretch runs — without it, stretch tries to
    // tighten each child to the Row's incoming height constraint, which is
    // unbounded here (Row sits inside a Column inside a
    // SingleChildScrollView), throwing "BoxConstraints forces an infinite
    // height" and blanking the whole scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildAksesCell(
              icon: MSymbols.directionsBusFilled,
              title: AppStrings.t('search_shuttle_title'),
              subtitle: AppStrings.t('search_shuttle_sub'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShuttleTrackingScreen(
                    bookingCode: 'PKR-88213',
                    pickupPointName: 'Titik Jemput A - Lahan Parkir',
                    destinationName: 'Terminal 3, CGK',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _buildAksesCell(
              icon: MSymbols.localTaxi,
              title: AppStrings.t('search_ground_transport_title'),
              subtitle: AppStrings.t('search_ground_transport_sub'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GroundTransportScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAksesCell({
    required int icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaterialSymbol(icon, size: 22, color: AppColors.ink, weight: 200),
            const SizedBox(height: 28),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.15,
                    height: 1.25)),
            const SizedBox(height: 5),
            Text(subtitle,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.body,
                    height: 1.45)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? checkIn : checkOut;
    final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;
    setState(() {
      final combined =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isCheckIn) {
        checkIn = combined;
      } else {
        checkOut = combined;
      }
    });
  }
}

/// Notification-bell header action, replacing AppHeaderAvatar on Home only.
/// Profile stays reachable via the bottom "PROFIL" tab. Unread count uses
/// the exact same real-data + category-filter pattern as
/// notifications_screen.dart's `_unreadCount`.
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final NotificationsApiService _notificationsApi = NotificationsApiService();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    NotificationPreferences.instance.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    NotificationPreferences.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final json = await _notificationsApi.getNotifications();
      final notifications = json.map(AppNotification.fromApi).toList();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } catch (_) {
      // Best-effort — the bell just shows no unread dot if this fails.
    }
  }

  int get _unreadCount {
    final prefs = NotificationPreferences.instance;
    return _notifications
        .where((n) => prefs.isCategoryEnabled(n.type.category) && !n.isRead)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen())),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const MaterialSymbol(MSymbols.notifications,
                  size: 24, color: AppColors.ink, weight: 200),
              if (unread > 0)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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

class _DateTile extends StatelessWidget {
  final int symbol;
  final Color iconColor;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateTile(
      {required this.symbol,
      required this.iconColor,
      required this.label,
      required this.date,
      required this.onTap});

  String get _formatted {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          MaterialSymbol(symbol, size: 17, color: iconColor, weight: 300),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 10,
                        color: AppColors.label,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_formatted,
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashGap = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
          return Row(
            children: List.generate(count, (_) {
              return Padding(
                padding: const EdgeInsets.only(right: dashGap),
                child: Container(
                  width: dashWidth,
                  height: 1,
                  color: Colors.white.withOpacity(0.35),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Dashed rounded-rect border painter for the promo card — matches the
/// target design's `border: 1px dashed #C3C8D2` exactly (a one-off value
/// from the design file, distinct from the [AppColors.hairline] token).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const double _radius = 18;
  static const Color _color = Color(0xFFC3C8D2);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(_radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
