import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';
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
        return const Color(0xFFF59E0B);
      case BookingStatus.dipesan:
        return primaryBlue;
      case BookingStatus.checkIn:
        return const Color(0xFF0EA5A4);
      case BookingStatus.checkOut:
        return const Color(0xFF16A34A);
      case BookingStatus.dibatalkan:
        return const Color(0xFFDC2626);
      case BookingStatus.kedaluwarsa:
        return Colors.grey.shade500;
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
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: statusColor.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BarAccentLabel(
                          text: booking.status.label, color: statusColor),
                      Text(booking.bookingCode,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              letterSpacing: 0.3)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      StubIcon(
                          icon: Icons.local_parking_rounded,
                          color: statusColor,
                          size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.locationName,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF16181F))),
                            const SizedBox(height: 2),
                            Text(booking.locationAddress,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (booking.status == BookingStatus.kedaluwarsa) ...[
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Booking ini dibatalkan otomatis oleh sistem karena tidak ada check-in dalam batas waktu yang ditentukan.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade700))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BookingQrScreen(booking: booking))),
                style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('Lihat QR Code & Cetak Struk',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoCard('JADWAL', [
              ('Check-in', _fmt(booking.checkIn)),
              ('Check-out', _fmt(booking.checkOut)),
              ('Durasi', '${booking.durationNights} malam'),
              if (booking.actualCheckoutTime != null)
                ('Check-out aktual', _fmt(booking.actualCheckoutTime!)),
            ]),
            const SizedBox(height: 14),
            _buildInfoCard('KENDARAAN', [
              ('Plat Nomor', booking.vehiclePlate),
              if (booking.slotCode.isNotEmpty) ('Slot Parkir', booking.slotCode)
            ]),
            const SizedBox(height: 14),
            _buildBillingCard(),
            const SizedBox(height: 22),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarAccentLabel(text: title, color: primaryBlue),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    Text(r.$2,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16181F))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBillingCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarAccentLabel(text: 'RINCIAN BIAYA', color: primaryBlue),
          const SizedBox(height: 10),
          _billRow('Tarif dasar', booking.subtotal),
          _billRow('Biaya layanan', booking.serviceFee),
          if (booking.overstayFee > 0)
            _billRow('Biaya keterlambatan', booking.overstayFee, warn: true),
          const SizedBox(height: 5),
          const PerforationDivider(),
          const SizedBox(height: 9),
          _billRow('Total', booking.total, bold: true),
        ],
      ),
    );
  }

  Widget _billRow(String label, double amount,
      {bool bold = false, bool warn = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 13.5 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.normal)),
          Text(CurrencyFormatter.rupiah(amount),
              style: TextStyle(
                  fontSize: bold ? 13.5 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: warn
                      ? const Color(0xFFDC2626)
                      : (bold ? primaryBlue : const Color(0xFF16181F)))),
        ],
      ),
    );
  }

  List<Widget> _buildDipesanActions(BuildContext context) {
    return [
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckinScreen(booking: booking))),
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login_rounded, size: 18),
              const SizedBox(width: 8),
              Text('CHECK-IN SEKARANG'.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 0.3))
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      Center(
        child: TextButton.icon(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RescheduleCancelScreen(booking: booking))),
          icon: Icon(Icons.edit_calendar_rounded,
              size: 15, color: Colors.grey.shade500),
          label: Text('Reschedule / Batalkan Booking',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ];
  }

  Widget _buildCheckoutAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckoutScreen(booking: booking))),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8A00),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18),
            const SizedBox(width: 8),
            const Text('CHECK-OUT SEKARANG',
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3))
          ],
        ),
      ),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RatingReviewScreen(booking: booking))),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 18),
            const SizedBox(width: 8),
            const Text('BERI RATING & ULASAN',
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3))
          ],
        ),
      ),
    );
  }
}
