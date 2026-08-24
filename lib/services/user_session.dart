//import 'package:flutter/material.dart';

class SavedVehicle {
  final String id;
  final String plate;
  final String brand;
  final String type;
  final String color;
  bool isDefault;

  SavedVehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.type,
    this.color = '',
    this.isDefault = false,
  });
}

/// Sumber data akun & kendaraan pengguna yang sudah login.
/// Dipakai bersama oleh ProfileScreen, VehiclesScreen, dan alur booking,
/// supaya user tidak perlu mengisi ulang data yang sudah terdaftar.
/// Di production: ganti dengan state management (Provider/Riverpod/Bloc)
/// yang disinkronkan dengan data akun dari backend.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String name = 'Budi Santoso';
  String email = 'budi.santoso@example.com';
  String phone = '0812-3456-7890';

  final List<SavedVehicle> vehicles = [
    SavedVehicle(
        id: 'v1',
        plate: 'B 1234 CD',
        brand: 'Toyota Avanza',
        type: 'MPV',
        color: 'Hitam',
        isDefault: true),
    SavedVehicle(
        id: 'v2',
        plate: 'B 5566 XY',
        brand: 'Honda Brio',
        type: 'Hatchback',
        color: 'Putih'),
  ];

  SavedVehicle? get defaultVehicle {
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere((v) => v.isDefault,
        orElse: () => vehicles.first);
  }

  void addVehicle(SavedVehicle vehicle) {
    vehicles.add(vehicle);
  }

  void setDefaultVehicle(String id) {
    for (final v in vehicles) {
      v.isDefault = v.id == id;
    }
  }

  void removeVehicle(String id) {
    vehicles.removeWhere((v) => v.id == id);
  }
}
