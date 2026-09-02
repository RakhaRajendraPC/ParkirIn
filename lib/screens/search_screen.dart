// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'shuttle_tracking_screen.dart';
import 'search_results_screen.dart';
import 'ground_transport_screen.dart';
import '../models/booking_model.dart';
import '../services/booking_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'booking_detail_screen.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/app_header_avatar.dart';
import '../widgets/stub_icon.dart';
import '../widgets/hero_banner_carousel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String airportName = 'CGK - Soekarno Hatta';
  DateTime checkIn = DateTime(2026, 10, 12, 8, 0);
  DateTime checkOut = DateTime(2026, 10, 15, 18, 0);

  final BookingRepository _bookingRepo = BookingRepository.instance;

  @override
  void initState() {
    super.initState();
    _bookingRepo.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _bookingRepo.removeListener(_onChanged);
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  BookingModel? get _activeBooking {
    final active = _bookingRepo.all.where((b) =>
        b.status == BookingStatus.dipesan || b.status == BookingStatus.checkIn);
    return active.isEmpty ? null : active.first;
  }

  List<BannerSlide> get _banners => [
        BannerSlide(
          imagePath: 'assets/images/hero_banner.png',
          badgeText: 'PARK & FLY',
          badgeIcon: Icons.local_parking,
          title: 'Parkir Aman\nSampai Pulang',
          accent: AppColors.primary,
        ),
        const BannerSlide(
          imagePath: 'assets/images/hero_banner2.jpeg',
          badgeText: 'GRATIS SHUTTLE',
          badgeIcon: Icons.directions_bus_filled,
          title: 'Antar-Jemput\nLangsung ke Terminal',
          accent: Color(0xFFFF8A00),
        ),
        const BannerSlide(
          imagePath: 'assets/images/hero_banner3.jpeg',
          badgeText: 'PROMO PENGGUNA BARU',
          badgeIcon: Icons.local_offer_rounded,
          title: 'Diskon 20%\nBooking Pertama',
          accent: Color(0xFF4B4FE0),
        ),
      ];

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBannerCarousel(slides: _banners),
              if (_activeBooking != null) ...[
                const SizedBox(height: 14),
                _buildActiveBookingBanner(),
              ],
              const SizedBox(height: 22),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSearchCard(),
              const SizedBox(height: 16),
              _buildSearchButton(),
              const SizedBox(height: 16),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildWhyChooseUsTitle(),
              const SizedBox(height: 12),
              _buildFeatureGrid(),
              const SizedBox(height: 12),
              _buildShuttleTracker(),
              const SizedBox(height: 12),
              _buildGroundTransportCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookingBanner() {
    final b = _activeBooking;
    if (b == null) return const SizedBox.shrink();

    final isParked = b.status == BookingStatus.checkIn;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailScreen(booking: b)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            StubIcon(
              icon: isParked
                  ? Icons.local_parking
                  : Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 42,
              onWhiteBase: false,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isParked
                        ? AppStrings.t('search_active_booking_parked')
                        : AppStrings.t('search_active_booking_waiting'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${b.locationName} · ${AppStrings.t('bookings_slot_label')} ${b.slotCode}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_east_rounded,
                color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16181F),
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
              StubIcon(
                  icon: Icons.local_parking_rounded,
                  color: AppColors.primary,
                  size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOKASI PARKIR',
                        style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    const Text('CGK - Soekarno Hatta',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16181F))),
                  ],
                ),
              ),
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          const PerforationDivider(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: const Color(0xFFFF8A00),
                  label: AppStrings.t('search_masuk'),
                  date: checkIn,
                  onTap: () => _pickDate(isCheckIn: true),
                ),
              ),
              Container(
                  height: 34,
                  width: 1,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 10)),
              Expanded(
                child: _DateTile(
                  icon: Icons.flight_land_rounded,
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, size: 20),
            const SizedBox(width: 8),
            Text(AppStrings.t('search_cta'),
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4B4FE0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4B4FE0).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StubIcon(
                    icon: Icons.local_offer_rounded,
                    color: Color(0xFF4B4FE0),
                    size: 46),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarAccentLabel(
                          text: AppStrings.t('search_promo_badge'),
                          color: const Color(0xFF4B4FE0)),
                      const SizedBox(height: 6),
                      Text(AppStrings.t('search_promo_title'),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16181F),
                              letterSpacing: -0.3)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const PerforationDivider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(AppStrings.t('search_promo_code_label'),
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                const Text('TERBANGAMAN',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4B4FE0),
                        fontFamily: 'monospace',
                        letterSpacing: 1.2)),
                const Spacer(),
                Text('PAKAI KODE',
                    style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5)),
                const SizedBox(width: 2),
                const LinkArrow(color: Color(0xFF4B4FE0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsTitle() {
    return Row(
      children: [
        Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(AppStrings.t('search_why_title'),
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF16181F),
                letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return Row(
      children: [
        Expanded(
          child: _FeatureCard(
            icon: Icons.verified_user_rounded,
            color: const Color(0xFF16A34A),
            title: AppStrings.t('search_feature_slot_title'),
            subtitle: AppStrings.t('search_feature_slot_sub'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeatureCard(
            icon: Icons.payments_rounded,
            color: AppColors.primary,
            title: AppStrings.t('search_feature_biaya_title'),
            subtitle: AppStrings.t('search_feature_biaya_sub'),
          ),
        ),
      ],
    );
  }

  Widget _buildShuttleTracker() {
    const accent = Color(0xFFFF8A00);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShuttleTrackingScreen(
              bookingCode: 'PKR-88213',
              pickupPointName: 'Titik Jemput A - Lahan Parkir',
              destinationName: 'Terminal 3, CGK',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            const StubIcon(
                icon: Icons.directions_bus_filled_rounded,
                color: accent,
                size: 44),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarAccentLabel(
                      text: AppStrings.t('search_shuttle_title').toUpperCase(),
                      color: accent),
                  const SizedBox(height: 4),
                  Text(AppStrings.t('search_shuttle_sub'),
                      style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const LinkArrow(color: accent),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundTransportCard() {
    const accent = Color(0xFF00A896);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const GroundTransportScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            const StubIcon(
                icon: Icons.commute_rounded, color: accent, size: 44),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarAccentLabel(
                      text: AppStrings.t('search_ground_transport_title')
                          .toUpperCase(),
                      color: accent),
                  const SizedBox(height: 4),
                  Text(AppStrings.t('search_ground_transport_sub'),
                      style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const LinkArrow(color: accent),
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

class _DateTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateTile(
      {required this.icon,
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
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(_formatted,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16181F)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StubIcon(icon: icon, color: color, size: 38),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: Color(0xFF16181F))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }
}
