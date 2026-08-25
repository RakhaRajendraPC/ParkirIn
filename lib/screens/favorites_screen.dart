// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../services/favorites_service.dart';
import 'location_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final FavoritesService _favorites = FavoritesService.instance;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onChanged);
  }

  @override
  void dispose() {
    _favorites.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allLocations = ParkingLocation.mockList();
    final favLocations =
        allLocations.where((l) => _favorites.isFavorite(l.id)).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Favorit Saya',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: favLocations.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 52, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('Belum ada lokasi favorit',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                        'Tap ikon hati di hasil pencarian untuk menyimpan lokasi.',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favLocations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final loc = favLocations[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationDetailScreen(
                          location: loc,
                          checkIn: DateTime.now().add(const Duration(days: 1)),
                          checkOut: DateTime.now().add(const Duration(days: 2)),
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8)
                          ]),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12)),
                            child: Icon(
                                loc.isIndoor
                                    ? Icons.warehouse
                                    : Icons.local_parking,
                                color: primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(loc.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _favorites.toggle(loc.id),
                            icon: const Icon(Icons.favorite,
                                color: Colors.redAccent, size: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
