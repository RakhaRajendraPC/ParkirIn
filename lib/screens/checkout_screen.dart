// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class CheckoutScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckoutScreen({super.key, required this.booking});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  bool _qrScanned = false;
  final List<bool> _photosTaken = [false, false, false, false];
  bool _completed = false;
  bool _isSubmitting = false;

  final List<String> _photoLabels = ['Depan', 'Belakang', 'Kiri', 'Kanan'];

  bool get _canSubmit => _qrScanned && _photosTaken.every((e) => e);

  double get _overstayFee {
    final now = DateTime.now();
    if (now.isAfter(widget.booking.checkOut)) {
      final extraHours = now.difference(widget.booking.checkOut).inHours;
      final extraDays = (extraHours / 24).ceil();
      return extraDays * 20000.0; // contoh tarif overstay per hari
    }
    return 0;
  }

  void _simulateScan() {
    setState(() => _qrScanned = true);
  }

  void _simulateTakePhoto(int index) {
    setState(() => _photosTaken[index] = true);
  }

  Future<void> _submitCheckout() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _completed = true;
      widget.booking.overstayFee = _overstayFee;
      widget.booking.actualCheckoutTime = DateTime.now();
      widget.booking.status = BookingStatus.selesai;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildInvoice();

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
            if (_overstayFee > 0) _buildOverstayWarning(),
            if (_overstayFee > 0) const SizedBox(height: 16),
            _buildStepTitle('1', 'Scan QR Code', done: _qrScanned),
            const SizedBox(height: 10),
            _buildQrScanBox(),
            const SizedBox(height: 24),
            _buildStepTitle('2', 'Foto Kondisi Kendaraan (Verifikasi Akhir)',
                done: _photosTaken.every((e) => e)),
            const SizedBox(height: 10),
            _buildPhotoGrid(),
            const SizedBox(height: 100),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    (_canSubmit && !_isSubmitting) ? _submitCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Konfirmasi Check-out',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
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
              'Anda melebihi durasi booking. Biaya tambahan (overstay fee) sebesar Rp ${_overstayFee.toStringAsFixed(0)} akan ditambahkan ke invoice.',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String number, String title, {required bool done}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: done ? Colors.green : Colors.orange,
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }

  Widget _buildQrScanBox() {
    return InkWell(
      onTap: _qrScanned ? null : _simulateScan,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _qrScanned ? Colors.green.withOpacity(0.06) : Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: _qrScanned ? Border.all(color: Colors.green) : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_qrScanned ? Icons.check_circle : Icons.qr_code_scanner,
                  color: _qrScanned ? Colors.green : Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                _qrScanned
                    ? 'QR Code Terverifikasi'
                    : 'Arahkan kamera ke QR Code\n(tap untuk simulasi scan)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _qrScanned ? Colors.green.shade800 : Colors.white70,
                    fontSize: 12),
              ),
            ],
          ),
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
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final done = _photosTaken[index];
        return InkWell(
          onTap: done ? null : () => _simulateTakePhoto(index),
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
            Text('Terima kasih telah menggunakan ParkirIn!',
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
                ],
              ),
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
                    _row('Biaya overstay', b.overstayFee, isWarning: true),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Selesai',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
                color: isWarning ? Colors.redAccent : Colors.black87,
              )),
          Text('Rp ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isWarning ? Colors.redAccent : Colors.black87,
              )),
        ],
      ),
    );
  }
}
