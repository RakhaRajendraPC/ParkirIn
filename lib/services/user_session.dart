import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'plate': plate,
        'brand': brand,
        'type': type,
        'color': color,
        'isDefault': isDefault,
      };

  factory SavedVehicle.fromJson(Map<String, dynamic> json) => SavedVehicle(
        id: json['id'] as String,
        plate: json['plate'] as String,
        brand: json['brand'] as String,
        type: json['type'] as String,
        color: json['color'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class UserSession extends ChangeNotifier {
  UserSession._();
  static final UserSession instance = UserSession._();

  static const _prefsKey = 'user_session_v1';

  String name = 'Budi Santoso';
  String email = 'budi.santoso@example.com';
  String phone = '0812-3456-7890';
  List<SavedVehicle> vehicles = [];
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      vehicles = [
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
      await _persist();
    } else {
      try {
        final Map<String, dynamic> data = jsonDecode(raw);
        name = data['name'] as String? ?? name;
        email = data['email'] as String? ?? email;
        phone = data['phone'] as String? ?? phone;
        final List<dynamic> vList = data['vehicles'] as List<dynamic>? ?? [];
        vehicles = vList
            .map((e) => SavedVehicle.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        vehicles = [];
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
    });
    await prefs.setString(_prefsKey, raw);
  }

  /// Panggil setelah mengubah name/email/phone secara langsung
  /// (mis. dari MyDetailsScreen) supaya perubahan tersimpan.
  void save() {
    notifyListeners();
    _persist();
  }

  SavedVehicle? get defaultVehicle {
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere((v) => v.isDefault,
        orElse: () => vehicles.first);
  }

  void addVehicle(SavedVehicle vehicle) {
    vehicles.add(vehicle);
    notifyListeners();
    _persist();
  }

  void setDefaultVehicle(String id) {
    for (final v in vehicles) {
      v.isDefault = v.id == id;
    }
    notifyListeners();
    _persist();
  }

  void removeVehicle(String id) {
    vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
    _persist();
  }
}
