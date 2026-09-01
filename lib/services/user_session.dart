import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'plate': plate,
        'brand': brand,
        'type': type,
        'color': color,
        'isDefault': isDefault,
      };
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
///
/// Not a ChangeNotifier: confirmed via a full-codebase search that nothing
/// listens to this class anywhere, and the `provider` package isn't even a
/// project dependency — adopting that here would be speculative.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  static const _prefsKey = 'user_session_v1';

  String name = 'Budi Santoso';
  String email = 'budi.santoso@example.com';
  String phone = '0812-3456-7890';
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(raw);
        name = data['name'] as String? ?? name;
        email = data['email'] as String? ?? email;
        phone = data['phone'] as String? ?? phone;
      } catch (_) {
        // Corrupt/unreadable data — keep the hardcoded defaults above.
      }
    }
    // No saved data on first run: name/email/phone already hold the
    // hardcoded mock defaults declared above, so there's nothing else to do.

    _isLoaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
    });
    await prefs.setString(_prefsKey, raw);
  }

  void save() {
    _persist();
  }
}
