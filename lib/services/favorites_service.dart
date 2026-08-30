import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _prefsKey = 'favorites_data_v1';

  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  bool isFavorite(String locationId) => _favoriteIds.contains(locationId);
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _favoriteIds.addAll(list.cast<String>());
      } catch (_) {}
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_favoriteIds.toList()));
  }

  void toggle(String locationId) {
    if (_favoriteIds.contains(locationId)) {
      _favoriteIds.remove(locationId);
    } else {
      _favoriteIds.add(locationId);
    }
    notifyListeners();
    _persist();
  }
}
