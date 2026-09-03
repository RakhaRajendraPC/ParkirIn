import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../services/receipt_generator.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';

class BookingQrScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingQrScreen({super.key, required this.booking});

  @override
  State<BookingQrScreen> createState() => _BookingQrScreenState();
}

class _BookingQrScreenState extends State<BookingQrScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  bool _isGeneratingReceipt = false;

  Color get _statusColor {
    switch (widget.booking.status) {
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

  Future<void> _printReceipt() async {
    setState(() => _isGeneratingReceipt = true);
    try {
      await ReceiptGenerator.shareOrPrintReceipt(widget.booking);
    } finally {
      if (mounted) setState(() => _isGeneratingReceipt = false);
    }
  }

  String _fmtDate(DateTime d) {
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

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('QR Code Booking',
              style: TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: _statusColor.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 10))
                  ]),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9)),
                    child: Text(b.status.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _statusColor,
                            letterSpacing: 0.4)),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(18)),
                    child: QrImageView(
                        data: b.bookingCode,
                        version: QrVersions.auto,
                        size: 196,
                        backgroundColor: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(b.bookingCode,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          fontFamily: 'monospace',
                          color: Color(0xFF16181F))),
                  const SizedBox(height: 5),
                  Text('Tunjukkan QR Code ini saat check-in & check-out',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.locationName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF16181F))),
                  const SizedBox(height: 3),
                  Text(b.locationAddress,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  const PerforationDivider(),
                  const SizedBox(height: 12),
                  _infoRow('Masuk', _fmtDate(b.checkIn)),
                  const SizedBox(height: 7),
                  _infoRow('Keluar', _fmtDate(b.checkOut)),
                  const SizedBox(height: 7),
                  _infoRow('Kendaraan', b.vehiclePlate),
                  if (b.slotCode.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    _infoRow('Slot Parkir', b.slotCode)
                  ],
                  const SizedBox(height: 7),
                  _infoRow('Total', CurrencyFormatter.rupiah(b.total),
                      highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isGeneratingReceipt ? null : _printReceipt,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: _isGeneratingReceipt
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text('CETAK / BAGIKAN STRUK',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  letterSpacing: 0.3)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
                'Struk berisi QR Code yang sama, bisa disimpan sebagai PDF atau dicetak di printer thermal.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: highlight ? 14.5 : 12,
                fontWeight: FontWeight.w800,
                color: highlight ? primaryBlue : const Color(0xFF16181F))),
      ],
    );
  }
}
