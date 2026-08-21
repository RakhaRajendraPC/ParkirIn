// lib/models/parking_location_model.dart
import 'package:flutter/material.dart';

class ParkingLocation {
  final String id;
  final String name;
  final String address;
  final double pricePerNight;
  final double rating;
  final double distanceKm;
  final bool isIndoor;
  final List<String> facilities; // e.g. CCTV 24 Jam, Pagar Keliling
  final bool isAccessible; // ramah kursi roda / lansia

  const ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.distanceKm,
    required this.isIndoor,
    required this.facilities,
    this.isAccessible = false,
  });

  static List<ParkingLocation> mockList() => const [
        ParkingLocation(
          id: 'loc1',
          name: 'SkyPark Fly & Park CGK',
          address: 'Jl. Marsekal Suryadarma No. 12, Tangerang',
          pricePerNight: 45000,
          rating: 4.7,
          distanceKm: 1.2,
          isIndoor: true,
          facilities: [
            'CCTV 24 Jam',
            'Pagar Keliling',
            'Petugas Jaga',
            'Area Tertutup'
          ],
          isAccessible: true,
        ),
        ParkingLocation(
          id: 'loc2',
          name: 'SafePark Soekarno Hatta',
          address: 'Jl. Husein Sastranegara No. 5, Tangerang',
          pricePerNight: 38000,
          rating: 4.5,
          distanceKm: 2.5,
          isIndoor: false,
          facilities: ['CCTV 24 Jam', 'Petugas Jaga', 'Shuttle Reguler'],
        ),
        ParkingLocation(
          id: 'loc3',
          name: 'Angkasa Park & Fly Premium',
          address: 'Jl. Prof. Dr. Soepomo No. 3, Tangerang',
          pricePerNight: 60000,
          rating: 4.9,
          distanceKm: 0.8,
          isIndoor: true,
          facilities: [
            'CCTV 24 Jam',
            'Pagar Keliling',
            'Petugas Jaga',
            'Area Tertutup',
            'Car Wash'
          ],
          isAccessible: true,
        ),
      ];
}
