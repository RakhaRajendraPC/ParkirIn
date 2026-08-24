// lib/screens/booking_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../services/receipt_generator.dart';

/// Bisa dibuka kapan saja dari Riwayat Booking / Detail Booking, supaya
/// user yang lupa menyimpan QR saat konfirmasi booking tetap bisa
/// mengaksesnya kembali dengan mudah.
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
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(b.status.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _statusColor)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: b.bookingCode,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(b.bookingCode,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    'Tunjukkan QR Code ini saat check-in & check-out',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.locationName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(b.locationAddress,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1)),
                  _infoRow('Masuk', _fmtDate(b.checkIn)),
                  const SizedBox(height: 6),
                  _infoRow('Keluar', _fmtDate(b.checkOut)),
                  const SizedBox(height: 6),
                  _infoRow('Kendaraan', b.vehiclePlate),
                  if (b.slotCode.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _infoRow('Slot Parkir', b.slotCode),
                  ],
                  const SizedBox(height: 6),
                  _infoRow('Total', 'Rp ${b.total.toStringAsFixed(0)}',
                      highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingReceipt ? null : _printReceipt,
                icon: _isGeneratingReceipt
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.receipt_long_outlined),
                label: Text(_isGeneratingReceipt
                    ? 'Menyiapkan Struk...'
                    : 'Cetak / Bagikan Struk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Struk berisi QR Code yang sama, bisa disimpan sebagai PDF atau dicetak di printer thermal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
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
              fontSize: highlight ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: highlight ? primaryBlue : Colors.black87,
            )),
      ],
    );
  }
}
