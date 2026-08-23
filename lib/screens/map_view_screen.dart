// lib/screens/map_view_screen.dart
import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import 'location_detail_screen.dart';

/// Alternatif tampilan hasil pencarian dalam bentuk peta interaktif.
/// Ganti mock canvas ini dengan GoogleMap() dari google_maps_flutter
/// di production, dengan marker mengambil koordinat asli tiap lokasi.
class MapViewScreen extends StatefulWidget {
  final DateTime checkIn;
  final DateTime checkOut;

  const MapViewScreen(
      {super.key, required this.checkIn, required this.checkOut});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  ParkingLocation? _selected;
  final List<ParkingLocation> _locations = ParkingLocation.mockList();

  // Posisi mock marker di kanvas (persentase dari lebar/tinggi peta)
  final List<Offset> _positions = const [
    Offset(0.3, 0.4),
    Offset(0.6, 0.55),
    Offset(0.45, 0.25)
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFDCE8F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.maybePop(context)),
          title: const Text('Peta Lokasi Parkir',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: List.generate(_locations.length, (i) {
                    final loc = _locations[i];
                    final pos = _positions[i];
                    final isSelected = _selected?.id == loc.id;
                    return Positioned(
                      left: constraints.maxWidth * pos.dx - 20,
                      top: constraints.maxHeight * pos.dy - 20,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = loc),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange : primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6)
                            ],
                          ),
                          child: Icon(Icons.local_parking,
                              color: Colors.white, size: isSelected ? 22 : 18),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            if (_selected != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _buildLocationPreview(_selected!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPreview(ParkingLocation loc) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationDetailScreen(
                    location: loc,
                    checkIn: widget.checkIn,
                    checkOut: widget.checkOut)));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
            ]),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(loc.isIndoor ? Icons.warehouse : Icons.local_parking,
                  color: primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                      'Rp ${loc.pricePerNight.toStringAsFixed(0)}/malam · ${loc.distanceKm} km',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
