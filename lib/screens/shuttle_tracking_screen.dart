// lib/screens/shuttle_tracking_screen.dart
//
// Lacak Shuttle — menampilkan rute shuttle (titik halte & titik terminal),
// status armada (berangkat/standby), dan arah jalan kaki dari slot parkir
// customer menuju halte terdekat. Tidak ada fitur kontak supir.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ShuttleUnitStatus { berangkat, standby }

class ShuttleStop {
  final String name;
  final bool isHalte; // true = halte/titik jemput, false = terminal

  const ShuttleStop({required this.name, required this.isHalte});
}

class ShuttleUnit {
  final String plateNumber;
  ShuttleUnitStatus status;
  int currentStopIndex;
  Duration etaToNextStop;

  ShuttleUnit({
    required this.plateNumber,
    required this.status,
    required this.currentStopIndex,
    required this.etaToNextStop,
  });
}

class ShuttleTrackingScreen extends StatefulWidget {
  final String bookingCode;
  final String pickupPointName;
  final String destinationName;

  /// Kode slot parkir customer (mis. 'A3'), dipakai untuk menghitung
  /// halte terdekat & menampilkan diagram arah jalan kaki.
  /// Production: sambungkan dari BookingModel.slotCode setelah field itu
  /// ditambahkan ke model booking.
  final String userSlotCode;

  /// Alamat venue untuk fallback "Buka Petunjuk Arah" ke Google Maps
  /// (navigasi menuju area bandara secara umum, bukan turn-by-turn indoor).
  final String venueAddress;

  const ShuttleTrackingScreen({
    super.key,
    this.bookingCode = 'PKR-88213',
    this.pickupPointName = 'Titik Jemput A - Lahan Parkir',
    this.destinationName = 'Terminal 3, CGK',
    this.userSlotCode = 'A3',
    this.venueAddress =
        'SkyPark Fly & Park CGK, Jl. Marsekal Suryadarma No. 12, Tangerang',
  });

  @override
  State<ShuttleTrackingScreen> createState() => _ShuttleTrackingScreenState();
}

class _ShuttleTrackingScreenState extends State<ShuttleTrackingScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  final List<ShuttleStop> _stops = const [
    ShuttleStop(name: 'Halte A - Lahan Parkir', isHalte: true),
    ShuttleStop(name: 'Halte B - Lahan Parkir', isHalte: true),
    ShuttleStop(name: 'Terminal 1', isHalte: false),
    ShuttleStop(name: 'Terminal 2', isHalte: false),
    ShuttleStop(name: 'Terminal 3', isHalte: false),
  ];

  late List<ShuttleUnit> _units;
  Timer? _refreshTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _units = [
      ShuttleUnit(
          plateNumber: 'B 7788 KJ',
          status: ShuttleUnitStatus.berangkat,
          currentStopIndex: 0,
          etaToNextStop: const Duration(minutes: 4)),
      ShuttleUnit(
          plateNumber: 'B 7790 KJ',
          status: ShuttleUnitStatus.berangkat,
          currentStopIndex: 2,
          etaToNextStop: const Duration(minutes: 7)),
      ShuttleUnit(
          plateNumber: 'B 7801 KJ',
          status: ShuttleUnitStatus.standby,
          currentStopIndex: 4,
          etaToNextStop: Duration.zero),
      ShuttleUnit(
          plateNumber: 'B 7812 KJ',
          status: ShuttleUnitStatus.standby,
          currentStopIndex: 4,
          etaToNextStop: Duration.zero),
    ];

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        for (final u in _units) {
          if (u.status == ShuttleUnitStatus.berangkat) {
            final remaining = u.etaToNextStop.inSeconds - 30;
            if (remaining <= 0) {
              if (u.currentStopIndex < _stops.length - 1) {
                u.currentStopIndex++;
                u.etaToNextStop = const Duration(minutes: 5);
              }
              if (u.currentStopIndex == _stops.length - 1) {
                u.status = ShuttleUnitStatus.standby;
                u.etaToNextStop = Duration.zero;
              }
            } else {
              u.etaToNextStop = Duration(seconds: remaining);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  List<ShuttleUnit> get _berangkatUnits =>
      _units.where((u) => u.status == ShuttleUnitStatus.berangkat).toList();
  List<ShuttleUnit> get _standbyUnits =>
      _units.where((u) => u.status == ShuttleUnitStatus.standby).toList();

  /// Menentukan halte terdekat berdasarkan baris slot: baris A/B -> Halte A,
  /// baris C/D dst -> Halte B. Logika sederhana; production sebaiknya
  /// pakai jarak Euclidean dari koordinat riil slot & halte.
  ShuttleStop get _nearestHalte {
    final rowLetter = widget.userSlotCode.isNotEmpty
        ? widget.userSlotCode[0].toUpperCase()
        : 'A';
    final index = rowLetter.codeUnitAt(0) - 65; // A=0, B=1, C=2, ...
    return index <= 1 ? _stops[0] : _stops[1];
  }

  /// Estimasi jarak & waktu jalan kaki, mock berdasarkan baris slot.
  (int meters, int minutes) get _walkingEstimate {
    final rowLetter = widget.userSlotCode.isNotEmpty
        ? widget.userSlotCode[0].toUpperCase()
        : 'A';
    final rowIndex = rowLetter.codeUnitAt(0) - 65;
    final meters = 40 + (rowIndex * 25);
    final minutes = (meters / 70).ceil().clamp(1, 15);
    return (meters, minutes);
  }

  Future<void> _openExternalMaps() async {
    final query = Uri.encodeComponent(widget.venueAddress);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta')));
    }
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
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWalkingDirectionCard(),
            const SizedBox(height: 16),
            _buildRouteCard(),
            const SizedBox(height: 20),
            _buildSectionTitle(
                'Shuttle Sedang Berangkat',
                Icons.directions_bus_filled,
                primaryBlue,
                _berangkatUnits.length),
            const SizedBox(height: 10),
            if (_berangkatUnits.isEmpty)
              _buildEmptyState(
                  'Tidak ada shuttle yang sedang dalam perjalanan saat ini.')
            else
              ..._berangkatUnits.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildBerangkatCard(u),
                  )),
            const SizedBox(height: 20),
            _buildSectionTitle('Shuttle Standby di Terminal',
                Icons.pause_circle_outline, Colors.teal, _standbyUnits.length),
            const SizedBox(height: 10),
            if (_standbyUnits.isEmpty)
              _buildEmptyState('Tidak ada shuttle yang standby saat ini.')
            else
              ..._standbyUnits.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildStandbyCard(u),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkingDirectionCard() {
    final halte = _nearestHalte;
    final (meters, minutes) = _walkingEstimate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk, size: 16, color: primaryBlue),
              const SizedBox(width: 8),
              const Text('Arah ke Halte Terdekat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(painter: _WalkingPathPainter()),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stopLabel(Icons.local_parking, 'Slot Anda', widget.userSlotCode,
                  Colors.redAccent),
              _stopLabel(
                  Icons.flag, 'Halte Terdekat', halte.name, Colors.orange),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.social_distance, size: 16, color: primaryBlue),
                const SizedBox(width: 8),
                Text('± $meters meter',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Icon(Icons.timer_outlined, size: 16, color: primaryBlue),
                const SizedBox(width: 8),
                Text('± $minutes menit jalan kaki',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _openExternalMaps,
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text('Buka Petunjuk Arah',
                  style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopLabel(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
            Text(value,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, size: 16, color: primaryBlue),
              const SizedBox(width: 8),
              const Text('Rute Shuttle',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_stops.length, (i) {
            final stop = _stops[i];
            final isLast = i == _stops.length - 1;
            final shuttlesHere =
                _units.where((u) => u.currentStopIndex == i).toList();

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stop.isHalte ? Colors.orange : primaryBlue,
                        ),
                        child: stop.isHalte
                            ? const Icon(Icons.flag,
                                size: 8, color: Colors.white)
                            : const Icon(Icons.flight,
                                size: 8, color: Colors.white),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                              width: 2,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(vertical: 2)),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  stop.isHalte
                                      ? 'Titik Jemput'
                                      : 'Titik Terminal',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          if (shuttlesHere.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: shuttlesHere.map((u) {
                                final isStandby =
                                    u.status == ShuttleUnitStatus.standby;
                                return AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final scale = isStandby
                                        ? 1.0
                                        : 1 + (_pulseController.value * 0.15);
                                    return Transform.scale(
                                        scale: scale, child: child);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: isStandby
                                          ? Colors.teal
                                          : Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.directions_bus_filled,
                                        color: Colors.white,
                                        size: 11),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, Color color, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildBerangkatCard(ShuttleUnit u) {
    final currentStop = _stops[u.currentStopIndex];
    final nextStop = u.currentStopIndex < _stops.length - 1
        ? _stops[u.currentStopIndex + 1]
        : null;
    final m = u.etaToNextStop.inMinutes;
    final s = u.etaToNextStop.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
            child:
                const Icon(Icons.directions_bus_filled, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shuttle ${u.plateNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Baru saja lewat: ${currentStop.name}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                if (nextStop != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Menuju: ${nextStop.name} · ETA ${m}m ${s.toString().padLeft(2, '0')}d',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandbyCard(ShuttleUnit u) {
    final stop = _stops[u.currentStopIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: Colors.teal, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.pause_circle_filled, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shuttle ${u.plateNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Standby di ${stop.name}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Siap Berangkat',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
        ],
      ),
    );
  }
}

/// Diagram sederhana garis putus-putus dari ikon mobil (slot parkir) menuju
/// ikon bendera (halte terdekat), meniru peta arah jalan kaki singkat.
class _WalkingPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E5EFF).withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(24, size.height - 20)
      ..quadraticBezierTo(
          size.width * 0.4, 10, size.width - 24, size.height - 20);

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }

    // Marker start (slot parkir)
    final startPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(Offset(24, size.height - 20), 8, startPaint);

    // Marker end (halte)
    final endPaint = Paint()..color = Colors.orange;
    canvas.drawCircle(Offset(size.width - 24, size.height - 20), 8, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
