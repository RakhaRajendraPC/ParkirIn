// lib/screens/bookings_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'checkin_screen.dart';
import 'checkout_screen.dart';
import 'booking_qr_screen.dart';
import 'booking_detail_screen.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/app_header_avatar.dart';
import '../widgets/stub_icon.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingRepository _repo = BookingRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _repo.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    AppSettings.instance.removeListener(_onChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<BookingModel> _byGroup(String group) =>
      _repo.all.where((b) => b.status.tabGroup == group).toList();

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
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelPadding: const EdgeInsets.symmetric(horizontal: 18),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: AppStrings.t('bookings_tab_aktif')),
              Tab(text: AppStrings.t('bookings_tab_selesai')),
              Tab(text: AppStrings.t('bookings_tab_dibatalkan')),
              Tab(text: AppStrings.t('bookings_tab_kedaluwarsa')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_byGroup('aktif')),
            _buildList(_byGroup('selesai')),
            _buildList(_byGroup('dibatalkan')),
            _buildList(_byGroup('kedaluwarsa')),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(AppStrings.t('bookings_empty'),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BookingDetailScreen(booking: bookings[index]))),
        borderRadius: BorderRadius.circular(16),
        child: _buildBookingCard(bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final statusAccent = switch (b.status) {
      BookingStatus.menungguPembayaran => const Color(0xFFF59E0B),
      BookingStatus.dipesan => AppColors.primary,
      BookingStatus.checkIn => const Color(0xFF0EA5A4),
      BookingStatus.checkOut => const Color(0xFF16A34A),
      BookingStatus.dibatalkan => const Color(0xFFDC2626),
      BookingStatus.kedaluwarsa => Colors.grey.shade500,
    };
    final canCheckin = b.status == BookingStatus.dipesan;
    final canCheckout = b.status == BookingStatus.checkIn;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: statusAccent.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StubIcon(
                    icon: Icons.local_parking_rounded,
                    color: statusAccent,
                    size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BarAccentLabel(text: b.status.label, color: statusAccent),
                      const SizedBox(height: 5),
                      Text(b.locationName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Color(0xFF16181F))),
                    ],
                  ),
                ),
                Text(
                  b.bookingCode,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.locationAddress,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  if (b.slotCode.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                            '${AppStrings.t('bookings_slot_label')} ${b.slotCode}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (b.status == BookingStatus.kedaluwarsa) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 54),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(AppStrings.t('bookings_expired_note'),
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 13),
            const PerforationDivider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${b.checkIn.day}/${b.checkIn.month} - ${b.checkOut.day}/${b.checkOut.month} · ${b.durationNights} ${AppStrings.t('search_malam')}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16181F)),
                  ),
                ),
                Text(CurrencyFormatter.rupiah(b.total),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: statusAccent)),
              ],
            ),
            if (canCheckin || canCheckout) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (canCheckin)
                    Expanded(
                      child: _softActionButton(
                        icon: Icons.login_rounded,
                        label: AppStrings.t('bookings_checkin_btn'),
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CheckinScreen(booking: b))),
                      ),
                    ),
                  if (canCheckin && canCheckout) const SizedBox(width: 8),
                  if (canCheckout)
                    Expanded(
                      child: _softActionButton(
                        icon: Icons.logout_rounded,
                        label: AppStrings.t('bookings_checkout_btn'),
                        color: const Color(0xFFFF8A00),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CheckoutScreen(booking: b))),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingQrScreen(booking: b))),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2_rounded,
                        size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(AppStrings.t('bookings_qr_btn'),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
