// lib/screens/location_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import 'parking_slot_map_screen.dart';

class LocationDetailScreen extends StatelessWidget {
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;

  const LocationDetailScreen({
    super.key,
    required this.location,
    required this.checkIn,
    required this.checkOut,
  });

  static const Color primaryBlue = Color(0xFF1E5EFF);

  IconData _facilityIcon(String label) {
    if (label.contains('CCTV')) return Icons.videocam_outlined;
    if (label.contains('Pagar')) return Icons.fence_outlined;
    if (label.contains('Petugas')) return Icons.security_outlined;
    if (label.contains('Tertutup')) return Icons.roofing_outlined;
    if (label.contains('Shuttle')) return Icons.airport_shuttle_outlined;
    if (label.contains('Car Wash')) return Icons.local_car_wash_outlined;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: primaryBlue.withOpacity(0.1),
              expandedHeight: 160,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.black87, size: 18),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Icon(
                    location.isIndoor ? Icons.warehouse : Icons.local_parking,
                    size: 72,
                    color: primaryBlue.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(location.address,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${location.rating}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('· ${location.distanceKm} km dari bandara',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Fasilitas Keamanan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: location.facilities
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4)
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_facilityIcon(f),
                                        size: 15, color: primaryBlue),
                                    const SizedBox(width: 6),
                                    Text(f,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    if (location.isAccessible) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.accessible, color: Colors.teal),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Lokasi ini ramah untuk lansia & pengguna kursi roda (dekat lift/gate).',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text('Lokasi',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE8F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(Icons.map_outlined,
                            color: primaryBlue, size: 36),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
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
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                            text:
                                'Rp ${location.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: ' / malam',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingSlotMapScreen(
                            location: location,
                            checkIn: checkIn,
                            checkOut: checkOut,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Pilih Slot Ini',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
