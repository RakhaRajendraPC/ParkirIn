import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../services/booking_repository.dart';
import 'shuttle_tracking_screen.dart';

enum _GateStatus { waiting, validated }

class CheckinScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckinScreen({super.key, required this.booking});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  _GateStatus _gateStatus = _GateStatus.waiting;
  Timer? _pollTimer;
  final List<bool> _photosTaken = [false, false, false, false];
  bool _showPhotoStep = false;
  final List<String> _photoLabels = ['Depan', 'Belakang', 'Kiri', 'Kanan'];

  @override
  void initState() {
    super.initState();
    // Simulasi polling status dari backend: staf/kiosk gerbang men-scan QR
    // milik user, lalu backend mengubah status booking menjadi CHECK_IN.
    // Production: ganti dengan listener realtime (websocket/polling API
    // GET /bookings/{id}/status) ke backend, bukan Timer statis.
    _pollTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _gateStatus = _GateStatus.validated;
        widget.booking.status = BookingStatus.checkIn;
      });
      BookingRepository.instance
          .refresh(); // beritahu BookingsScreen untuk rebuild
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _goToShuttle() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShuttleTrackingScreen(
          bookingCode: widget.booking.bookingCode,
          pickupPointName: 'Titik Jemput A - ${widget.booking.locationName}',
          destinationName: 'Terminal Keberangkatan',
          userSlotCode: widget.booking.slotCode,
          venueAddress: widget.booking.locationAddress,
        ),
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
            Center(
              child: Column(
                children: [
                  Text(
                    _gateStatus == _GateStatus.waiting
                        ? 'Tunjukkan QR ini di gerbang masuk'
                        : 'Check-in Berhasil',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _gateStatus == _GateStatus.waiting
                        ? 'Petugas atau kiosk akan memindai QR Code ini'
                        : 'Kendaraan Anda tercatat aman di area parkir',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildQrCard(),
            const SizedBox(height: 20),
            if (_gateStatus == _GateStatus.validated) ...[
              _buildSuccessBanner(),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showPhotoStep = !_showPhotoStep),
                icon: Icon(
                    _showPhotoStep ? Icons.expand_less : Icons.expand_more,
                    size: 18),
                label: const Text('Opsional: Dokumentasikan Kondisi Kendaraan',
                    style: TextStyle(fontSize: 12)),
              ),
              if (_showPhotoStep) ...[
                const SizedBox(height: 4),
                Text(
                  'Untuk membantu klaim jika terjadi kerusakan selama parkir.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                _buildPhotoGrid(),
              ],
              const SizedBox(height: 100),
            ] else ...[
              const SizedBox(height: 100),
            ],
          ],
        ),
        bottomNavigationBar: _gateStatus == _GateStatus.validated
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2))
                  ]),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _goToShuttle,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Lacak Shuttle',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              )
            : null,
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
          ]),
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
                Text(widget.booking.locationName,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
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
          border: Border.all(
              color: _gateStatus == _GateStatus.validated
                  ? Colors.green
                  : Colors.grey.shade200,
              width: _gateStatus == _GateStatus.validated ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Opacity(
              opacity: _gateStatus == _GateStatus.validated ? 0.35 : 1,
              child: QrImageView(
                  data: widget.booking.bookingCode,
                  version: QrVersions.auto,
                  size: 180),
            ),
            const SizedBox(height: 12),
            Text(widget.booking.bookingCode,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            if (_gateStatus == _GateStatus.waiting) ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
              child: Text('QR berhasil divalidasi oleh gerbang masuk',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
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
}
