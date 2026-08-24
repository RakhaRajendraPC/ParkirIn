import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import 'ground_transport_screen.dart';

enum _GateStatus { waiting, validated }

class CheckoutScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckoutScreen({super.key, required this.booking});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  _GateStatus _gateStatus = _GateStatus.waiting;
  Timer? _pollTimer;
  final List<bool> _photosTaken = [false, false, false, false];
  bool _showPhotoStep = false;
  final List<String> _photoLabels = ['Depan', 'Belakang', 'Kiri', 'Kanan'];

  double get _overstayFee {
    final now = DateTime.now();
    if (now.isAfter(widget.booking.checkOut)) {
      final extraHours = now.difference(widget.booking.checkOut).inHours;
      final extraBlocks =
          (extraHours / 1).ceil(); // per jam, sesuai kebijakan bandara §6.2
      return extraBlocks * 15000.0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // Simulasi: kalau ada biaya tambahan tertunggak, portal keluar tidak
    // akan divalidasi otomatis sampai user "melunasi" (di sini otomatis
    // dianggap lunas setelah delay, karena pembayaran real terjadi di
    // BookingSummaryScreen/payment gateway pada kasus nyata).
    _pollTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _gateStatus = _GateStatus.validated;
        widget.booking.overstayFee = _overstayFee;
        widget.booking.actualCheckoutTime = DateTime.now();
        widget.booking.status = BookingStatus.checkOut;
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gateStatus == _GateStatus.validated) return _buildInvoice();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Check-out',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_overstayFee > 0) ...[
              _buildOverstayWarning(),
              const SizedBox(height: 16)
            ],
            Center(
              child: Column(
                children: [
                  const Text('Tunjukkan QR ini di gerbang keluar',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Petugas atau kiosk akan memindai QR Code ini',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildQrCard(),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => setState(() => _showPhotoStep = !_showPhotoStep),
              icon: Icon(_showPhotoStep ? Icons.expand_less : Icons.expand_more,
                  size: 18),
              label: const Text('Opsional: Verifikasi Akhir Kondisi Kendaraan',
                  style: TextStyle(fontSize: 12)),
            ),
            if (_showPhotoStep) ...[
              const SizedBox(height: 10),
              _buildPhotoGrid(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverstayWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Anda melebihi durasi booking. Biaya tambahan Rp ${_overstayFee.toStringAsFixed(0)} akan otomatis ditambahkan sebelum portal keluar dapat digunakan.',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            QrImageView(
                data: widget.booking.bookingCode,
                version: QrVersions.auto,
                size: 180),
            const SizedBox(height: 12),
            Text(widget.booking.bookingCode,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 14),
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: primaryBlue)),
            const SizedBox(height: 8),
            Text('Menunggu validasi gerbang...',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _photoLabels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3),
      itemBuilder: (context, index) {
        final done = _photosTaken[index];
        return InkWell(
          onTap: done ? null : () => setState(() => _photosTaken[index] = true),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: done ? Colors.green.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: done ? Colors.green : Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(done ? Icons.check_circle : Icons.camera_alt_outlined,
                    color: done ? Colors.green : Colors.grey.shade400,
                    size: 28),
                const SizedBox(height: 6),
                Text('${_photoLabels[index]} ${done ? "✓" : ""}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: done
                            ? Colors.green.shade800
                            : Colors.grey.shade600)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoice() {
    final b = widget.booking;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Invoice Final',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Check-out Berhasil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Lot parkir Anda telah kembali tersedia',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                  Text('Kode Booking: ${b.bookingCode}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(b.locationName,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1)),
                  _row('Tarif dasar (${b.durationNights} malam)', b.subtotal),
                  _row('Biaya layanan', b.serviceFee),
                  if (b.overstayFee > 0)
                    _row('Biaya keterlambatan', b.overstayFee, isWarning: true),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1)),
                  _row('Total Akhir', b.total, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Selesai',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GroundTransportScreen())),
                icon: const Icon(Icons.commute, size: 18),
                label: const Text('Cari Transportasi Lanjutan'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount,
      {bool isTotal = false, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 14 : 12,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isWarning ? Colors.redAccent : Colors.black87)),
          Text('Rp ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: isTotal ? 14 : 12,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isWarning ? Colors.redAccent : Colors.black87)),
        ],
      ),
    );
  }
}
