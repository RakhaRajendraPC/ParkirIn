// lib/screens/shuttle_tracking_screen.dart
//
// Shuttle Bus Tracking screen — PRD §6.4
// Requirements yang diimplementasikan:
//  - Peta lokasi shuttle secara real-time (mock animasi, siap diganti Google Maps)
//  - Estimasi waktu kedatangan (ETA) ke titik jemput
//  - Notifikasi otomatis saat shuttle mendekat (banner + snackbar saat ETA <= 5 menit)
//  - (Fase 2) tombol "Panggil Shuttle" manual untuk titik jemput non-standar

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum ShuttleStatus { menujuJemput, tiba, dalamPerjalanan, selesai }

class ShuttleTrackingScreen extends StatefulWidget {
  final String bookingCode;
  final String pickupPointName;
  final String destinationName;

  const ShuttleTrackingScreen({
    super.key,
    this.bookingCode = 'PKR-88213',
    this.pickupPointName = 'Titik Jemput A - Lahan Parkir',
    this.destinationName = 'Terminal 3, CGK',
  });

  @override
  State<ShuttleTrackingScreen> createState() => _ShuttleTrackingScreenState();
}

class _ShuttleTrackingScreenState extends State<ShuttleTrackingScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  // Mock state: dalam production, ini datang dari stream lokasi shuttle
  // (mis. websocket/polling ke Maps & Geolocation API, PRD §9).
  Duration _eta = const Duration(minutes: 12);
  ShuttleStatus _status = ShuttleStatus.menujuJemput;
  Timer? _etaTimer;
  bool _hasNotifiedArrivalSoon = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulasi ETA berkurang tiap beberapa detik (mock real-time update).
    _etaTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        final remaining = _eta.inSeconds - 30;
        if (remaining <= 0) {
          _eta = Duration.zero;
          _status = ShuttleStatus.tiba;
          timer.cancel();
        } else {
          _eta = Duration(seconds: remaining);
        }
      });

      // Notifikasi otomatis saat shuttle mendekat (<= 5 menit), sesuai §6.4 & §6.5.
      if (_eta.inMinutes <= 5 &&
          !_hasNotifiedArrivalSoon &&
          _status != ShuttleStatus.tiba) {
        _hasNotifiedArrivalSoon = true;
        _showArrivalSoonNotification();
      }
    });
  }

  @override
  void dispose() {
    _etaTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showArrivalSoonNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange.shade700,
        content: const Row(
          children: [
            Icon(Icons.directions_bus_filled, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Shuttle Anda akan tiba dalam 5 menit. Mohon menuju titik jemput.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _callManualShuttle() {
    // (Fase 2) fitur "panggil shuttle" manual untuk titik jemput non-standar.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Panggil Shuttle'),
        content: const Text(
          'Fitur ini akan mengirim permintaan shuttle ke titik jemput non-standar Anda. '
          '(Fase 2 — memerlukan koordinasi dengan mitra operasional shuttle.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Kirim Permintaan'),
          ),
        ],
      ),
    );
  }

  String get _etaText {
    if (_status == ShuttleStatus.tiba) return 'Shuttle telah tiba';
    final m = _eta.inMinutes;
    final s = _eta.inSeconds % 60;
    return '$m menit ${s.toString().padLeft(2, '0')} detik';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Lacak Shuttle',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Peta simulasi real-time. Ganti Container ini dengan GoogleMap()
            // dari package google_maps_flutter untuk implementasi production.
            Expanded(
              flex: 3,
              child: _buildMockMap(),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEtaCard(),
                    const SizedBox(height: 16),
                    _buildStatusStepper(),
                    const SizedBox(height: 16),
                    _buildRouteInfo(),
                    const SizedBox(height: 16),
                    _buildDriverCard(),
                    const SizedBox(height: 16),
                    _buildCallShuttleButton(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockMap() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFDCE8F5),
      child: Stack(
        children: [
          // Garis rute putus-putus sederhana (dekorasi)
          CustomPaint(
            size: Size.infinite,
            painter: _DashedRoutePainter(),
          ),
          // Marker titik jemput
          const Positioned(
            left: 40,
            bottom: 60,
            child: _MapPin(
              icon: Icons.flag_circle,
              color: Colors.redAccent,
              label: 'Titik Jemput',
            ),
          ),
          // Marker terminal tujuan
          const Positioned(
            right: 30,
            top: 40,
            child: _MapPin(
              icon: Icons.flight_takeoff,
              color: primaryBlue,
              label: 'Terminal 3',
            ),
          ),
          // Marker shuttle bergerak (dengan animasi pulse)
          Positioned(
            left: 130,
            top: 110,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1 + (_pulseController.value * 0.25);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.directions_bus_filled,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 6)
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed, size: 12, color: primaryBlue),
                  SizedBox(width: 4),
                  Text('Live',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaCard() {
    final bool arriving = _status == ShuttleStatus.tiba;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: arriving ? Colors.green.shade50 : primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: arriving
                ? Colors.green.shade200
                : primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            arriving ? Icons.check_circle : Icons.access_time_filled,
            color: arriving ? Colors.green : primaryBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arriving ? 'Shuttle Telah Tiba' : 'Estimasi Kedatangan (ETA)',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        arriving ? Colors.green.shade800 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _etaText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: arriving ? Colors.green.shade800 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper() {
    final steps = [
      ('Konfirmasi', true),
      ('Menuju Jemput', _status.index >= ShuttleStatus.menujuJemput.index),
      ('Tiba', _status.index >= ShuttleStatus.tiba.index),
      ('Perjalanan', _status.index >= ShuttleStatus.dalamPerjalanan.index),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final (label, done) = steps[i];
        final isLast = i == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: done ? primaryBlue : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: done ? Colors.black87 : Colors.grey.shade400,
                      fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 14),
                    color: done ? primaryBlue : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRouteInfo() {
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
        children: [
          _buildRouteRow(Icons.radio_button_checked, Colors.redAccent,
              widget.pickupPointName),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(width: 2, height: 20, color: Colors.grey.shade300),
          ),
          _buildRouteRow(
              Icons.location_on, primaryBlue, widget.destinationName),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
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
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEDEDED),
            child: Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agus Wijaya',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                SizedBox(height: 2),
                Text('Shuttle B 7788 KJ · Nomor titik: A3',
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          _buildIconButton(Icons.call, primaryBlue, () {}),
          const SizedBox(width: 8),
          _buildIconButton(Icons.chat_bubble_outline, Colors.orange, () {}),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildCallShuttleButton() {
    // (Fase 2) — panggil shuttle manual untuk titik jemput non-standar.
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _callManualShuttle,
        icon: const Icon(Icons.add_location_alt_outlined, size: 18),
        label: const Text('Panggil Shuttle ke Titik Lain (Fase 2)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapPin({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)
            ],
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// Dekorasi garis rute putus-putus pada mock map.
class _DashedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E5EFF).withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.85,
        size.height * 0.2,
      );

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
