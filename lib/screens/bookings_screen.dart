import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_repository.dart';
import 'checkin_screen.dart';
import 'checkout_screen.dart';
import 'booking_qr_screen.dart';
import 'booking_detail_screen.dart';
import '../utils/currency_formatter.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  late TabController _tabController;
  final BookingRepository _repo = BookingRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
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
          title: const Text('My Bookings',
              style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryBlue,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Dibatalkan'),
              Tab(text: 'Kedaluwarsa')
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
            Text('Belum ada booking',
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
    final statusColor = switch (b.status) {
      BookingStatus.menungguPembayaran => Colors.orange,
      BookingStatus.dipesan => primaryBlue,
      BookingStatus.checkIn => Colors.teal,
      BookingStatus.checkOut => Colors.green,
      BookingStatus.dibatalkan => Colors.redAccent,
      BookingStatus.kedaluwarsa => Colors.grey.shade600,
    };
    final canCheckin = b.status == BookingStatus.dipesan;
    final canCheckout = b.status == BookingStatus.checkIn;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(b.status.label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor)),
              ),
              Text(b.bookingCode,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(b.locationName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(b.locationAddress,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          if (b.slotCode.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.local_parking,
                    size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Slot ${b.slotCode}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          if (b.status == BookingStatus.kedaluwarsa) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                          'Dibatalkan otomatis karena tidak check-in sesuai batas waktu',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600))),
                ],
              ),
            ),
          ],
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1)),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${b.checkIn.day}/${b.checkIn.month} - ${b.checkOut.day}/${b.checkOut.month} · ${b.durationNights} malam',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              Text(CurrencyFormatter.rupiah(b.total),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue)),
            ],
          ),
          if (canCheckin || canCheckout) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (canCheckin)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CheckinScreen(booking: b))),
                      icon: const Icon(Icons.login, size: 16),
                      label: const Text('Check-in',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                if (canCheckout)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutScreen(booking: b))),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Check-out',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingQrScreen(booking: b))),
              icon: const Icon(Icons.qr_code, size: 16),
              label:
                  const Text('Lihat QR Code', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}
