// lib/screens/checkin_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'shuttle_tracking_screen.dart';

class CheckinScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckinScreen({super.key, required this.booking});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  bool _qrScanned = false;
  final List<bool> _photosTaken = [
    false,
    false,
    false,
    false
  ]; // Depan, Belakang, Kiri, Kanan
  bool _isSubmitting = false;

  final List<String> _photoLabels = ['Depan', 'Belakang', 'Kiri', 'Kanan'];

  bool get _canSubmit => _qrScanned && _photosTaken.every((e) => e);

  void _simulateScan() {
    setState(() => _qrScanned = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('QR Code berhasil dipindai'),
          duration: Duration(seconds: 2)),
    );
  }

  void _simulateTakePhoto(int index) {
    // Di production: gunakan image_picker untuk buka kamera lalu simpan file-nya.
    setState(() => _photosTaken[index] = true);
  }

  Future<void> _submitCheckin() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Check-in Berhasil'),
        content: const Text(
            'Kendaraan Anda telah tercatat aman. Silakan tunggu shuttle di titik jemput.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShuttleTrackingScreen(
                    bookingCode: widget.booking.bookingCode,
                    pickupPointName:
                        'Titik Jemput A - ${widget.booking.locationName}',
                    destinationName: 'Terminal Keberangkatan',
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Lacak Shuttle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Check-in',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBookingInfo(),
            const SizedBox(height: 20),
            _buildStepTitle('1', 'Scan QR Code', done: _qrScanned),
            const SizedBox(height: 10),
            _buildQrScanBox(),
            const SizedBox(height: 24),
            _buildStepTitle('2', 'Foto Kondisi Kendaraan',
                done: _photosTaken.every((e) => e)),
            const SizedBox(height: 4),
            Text(
              'Dokumentasi ini digunakan untuk klaim jika terjadi kerusakan selama parkir.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
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
                    (_canSubmit && !_isSubmitting) ? _submitCheckin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
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
                    : const Text('Konfirmasi Check-in',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_filled, color: primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.vehiclePlate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Kode booking: ${widget.booking.bookingCode}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
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
          backgroundColor: done ? Colors.green : primaryBlue,
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              Icon(
                _qrScanned ? Icons.check_circle : Icons.qr_code_scanner,
                color: _qrScanned ? Colors.green : Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                _qrScanned
                    ? 'QR Code Terverifikasi'
                    : 'Arahkan kamera ke QR Code\n(tap untuk simulasi scan)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _qrScanned ? Colors.green.shade800 : Colors.white70,
                  fontSize: 12,
                ),
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
              border: Border.all(
                  color: done ? Colors.green : Colors.grey.shade300,
                  style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.camera_alt_outlined,
                  color: done ? Colors.green : Colors.grey.shade400,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  '${_photoLabels[index]} ${done ? "✓" : ""}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          done ? Colors.green.shade800 : Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
