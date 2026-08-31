//import 'package:flutter/material.dart';

/// A vehicle as returned by the real backend (GET/POST/PATCH /vehicles).
/// Kept here (rather than a new models/ file) since this is the pre-existing
/// shared model both VehiclesScreen and SelectVehicleScreen already build
/// their UI around.
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

  factory SavedVehicle.fromJson(Map<String, dynamic> json) {
    return SavedVehicle(
      id: json['id'] as String,
      plate: json['plate'] as String,
      brand: json['brand'] as String,
      type: json['type'] as String,
      color: json['color'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

/// Sumber data akun pengguna yang sudah login (nama, email, telepon).
/// Dipakai bersama oleh ProfileScreen dan alur booking, supaya user tidak
/// perlu mengisi ulang data yang sudah terdaftar.
/// Di production: ganti dengan state management (Provider/Riverpod/Bloc)
/// yang disinkronkan dengan data akun dari backend.
///
/// Vehicle data is NOT stored here anymore — VehiclesScreen and
/// SelectVehicleScreen fetch it directly from VehiclesApiService (the real
/// backend), since a shared in-memory mock list can't reflect another
/// device's changes or survive a real login as a different user.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String name = 'Budi Santoso';
  String email = 'budi.santoso@example.com';
  String phone = '0812-3456-7890';
}
