// lib/services/favorites_service.dart
import 'package:flutter/foundation.dart';

/// Menyimpan ID lokasi parkir favorit milik user. ChangeNotifier supaya
/// tombol bookmark di berbagai layar (hasil pencarian, detail lokasi)
/// otomatis sinkron statusnya.
/// Production: persist ke backend/SharedPreferences, bukan in-memory saja.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Set<String> _favoriteIds = {};

  bool isFavorite(String locationId) => _favoriteIds.contains(locationId);

  void toggle(String locationId) {
    if (_favoriteIds.contains(locationId)) {
      _favoriteIds.remove(locationId);
    } else {
      _favoriteIds.add(locationId);
    }
    notifyListeners();
  }

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
}
