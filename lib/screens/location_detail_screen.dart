import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../models/review_model.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';
import 'parking_slot_map_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;

  const LocationDetailScreen(
      {super.key,
      required this.location,
      required this.checkIn,
      required this.checkOut});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  IconData _facilityIcon(String label) {
    if (label.contains('CCTV')) return Icons.videocam_rounded;
    if (label.contains('Pagar')) return Icons.fence_rounded;
    if (label.contains('Petugas')) return Icons.security_rounded;
    if (label.contains('Tertutup')) return Icons.roofing_rounded;
    if (label.contains('Shuttle')) return Icons.airport_shuttle_rounded;
    if (label.contains('Car Wash')) return Icons.local_car_wash_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.primary.withOpacity(0.08),
              expandedHeight: 170,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF16181F), size: 18),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                    child: StubIcon(
                        icon: location.isIndoor
                            ? Icons.warehouse_rounded
                            : Icons.local_parking_rounded,
                        color: AppColors.primary,
                        size: 92)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16181F),
                            letterSpacing: -0.3)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(location.address,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 17, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${location.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                            '· ${location.distanceKm} ${AppStrings.t('loc_km_from_airport')}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    BarAccentLabel(
                        text:
                            AppStrings.t('loc_facilities_title').toUpperCase(),
                        color: AppColors.primary),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: location.facilities
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(11),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8)
                                    ]),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_facilityIcon(f),
                                        size: 15, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(f,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF16181F))),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    if (location.isAccessible) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0EA5A4).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            const Icon(Icons.accessible_rounded,
                                color: Color(0xFF0EA5A4)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(AppStrings.t('loc_accessible_note'),
                                    style: const TextStyle(fontSize: 11.5))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    BarAccentLabel(
                        text: AppStrings.t('loc_location_title').toUpperCase(),
                        color: AppColors.primary),
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCE8F5),
                          borderRadius: BorderRadius.circular(18)),
                      child: Center(
                          child: Icon(Icons.map_rounded,
                              color: AppColors.primary, size: 36)),
                    ),
                    const SizedBox(height: 22),
                    _buildReviewsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4))
            ]),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF16181F)),
                      children: [
                        TextSpan(
                            text: CurrencyFormatter.rupiah(
                                location.pricePerNight),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        TextSpan(
                            text: AppStrings.t('loc_per_night'),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParkingSlotMapScreen(
                                location: location,
                                checkIn: widget.checkIn,
                                checkOut: widget.checkOut))),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 26)),
                    child: Text(
                        AppStrings.t('loc_select_slot_btn').toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: 0.3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = LocationReview.mockForLocation(widget.location.id);
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BarAccentLabel(
                text: AppStrings.t('loc_reviews_title').toUpperCase(),
                color: Colors.amber.shade700),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${avgRating.toStringAsFixed(1)} (${reviews.length})',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Text(AppStrings.t('loc_no_reviews'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
        else
          ...reviews.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReviewCard(r))),
      ],
    );
  }

  Widget _buildReviewCard(LocationReview r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/100?img=${r.userAvatarSeed}')),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    Row(
                        children: List.generate(
                            5,
                            (i) => Icon(
                                i < r.rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 12,
                                color: Colors.amber))),
                  ],
                ),
              ),
              Text('${r.date.day}/${r.date.month}/${r.date.year}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 9),
          Text(r.comment,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade700, height: 1.45)),
          if (r.tags.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              children: r.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
