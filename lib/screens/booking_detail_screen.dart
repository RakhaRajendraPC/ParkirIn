import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'checkin_screen.dart';
import 'checkout_screen.dart';
import 'reschedule_cancel_screen.dart';
import 'rating_review_screen.dart';
import 'booking_qr_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  String _fmt(DateTime d) {
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
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $hh:$mm';
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.menungguPembayaran:
        return Colors.orange;
      case BookingStatus.dipesan:
        return primaryBlue;
      case BookingStatus.checkIn:
        return Colors.teal;
      case BookingStatus.checkOut:
        return Colors.green;
      case BookingStatus.dibatalkan:
        return Colors.redAccent;
      case BookingStatus.kedaluwarsa:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Detail Booking',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(booking.status.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor)),
                      ),
                      Text(booking.bookingCode,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(booking.locationName,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(booking.locationAddress,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (booking.status == BookingStatus.kedaluwarsa) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking ini dibatalkan otomatis oleh sistem karena tidak ada check-in dalam batas waktu yang ditentukan.',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BookingQrScreen(booking: booking))),
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Lihat QR Code & Cetak Struk'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoCard('Jadwal', [
              ('Check-in', _fmt(booking.checkIn)),
              ('Check-out', _fmt(booking.checkOut)),
              ('Durasi', '${booking.durationNights} malam'),
              if (booking.actualCheckoutTime != null)
                ('Check-out aktual', _fmt(booking.actualCheckoutTime!)),
            ]),
            const SizedBox(height: 14),
            _buildInfoCard('Kendaraan', [
              ('Plat Nomor', booking.vehiclePlate),
              if (booking.slotCode.isNotEmpty)
                ('Slot Parkir', booking.slotCode),
            ]),
            const SizedBox(height: 14),
            _buildBillingCard(),
            const SizedBox(height: 20),
            if (booking.status == BookingStatus.dipesan)
              ..._buildDipesanActions(context),
            if (booking.status == BookingStatus.checkIn)
              _buildCheckoutAction(context),
            if (booking.status == BookingStatus.checkOut)
              _buildRateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<(String, String)> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    Text(r.$2,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBillingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Biaya',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          _billRow('Tarif dasar', booking.subtotal),
          _billRow('Biaya layanan', booking.serviceFee),
          if (booking.overstayFee > 0)
            _billRow('Biaya keterlambatan', booking.overstayFee, warn: true),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1)),
          _billRow('Total', booking.total, bold: true),
        ],
      ),
    );
  }

  Widget _billRow(String label, double amount,
      {bool bold = false, bool warn = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 13 : 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('Rp ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: bold ? 13 : 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: warn ? Colors.redAccent : Colors.black87,
              )),
        ],
      ),
    );
  }

  List<Widget> _buildDipesanActions(BuildContext context) {
    return [
      SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckinScreen(booking: booking))),
          icon: const Icon(Icons.login, size: 18),
          label: const Text('Check-in Sekarang'),
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryBlue,
              side: const BorderSide(color: primaryBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        height: 44,
        child: TextButton.icon(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RescheduleCancelScreen(booking: booking))),
          icon: const Icon(Icons.edit_calendar_outlined,
              size: 16, color: Colors.black54),
          label: const Text('Reschedule / Batalkan Booking',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ),
      ),
    ];
  }

  Widget _buildCheckoutAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckoutScreen(booking: booking))),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Check-out Sekarang'),
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RatingReviewScreen(booking: booking))),
        icon: const Icon(Icons.star_outline, size: 18),
        label: const Text('Beri Rating & Ulasan'),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
