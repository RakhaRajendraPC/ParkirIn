import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/parking_location_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

export 'api_exception.dart' show ApiException;

/// Backed by the backend's Favorites module (`GET /favorites`,
/// `POST /favorites/:locationId/toggle`) — state lives server-side per
/// account, so it no longer leaks between different logged-in users on the
/// same device (the old SharedPreferences-backed Set did).
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Dio _dio = ApiClient.instance.dio;

  List<ParkingLocation> _locations = [];
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  List<ParkingLocation> get locations => List.unmodifiable(_locations);
  bool isFavorite(String locationId) => _favoriteIds.contains(locationId);

  /// GET /favorites. No-ops if already loaded unless [force] is set — call
  /// with `force: true` after login/logout so a different account's data
  /// doesn't linger.
  Future<void> load({bool force = false}) async {
    if (_isLoaded && !force) return;
    try {
      final res = await _dio.get<List<dynamic>>('/favorites');
      _locations =
          res.data!.cast<Map<String, dynamic>>().map(ParkingLocation.fromApi).toList();
      _favoriteIds
        ..clear()
        ..addAll(_locations.map((l) => l.id));
      _isLoaded = true;
    } on DioException catch (e) {
      throw mapDioError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Clears cached state without hitting the network — call on logout so
  /// the previous account's favorites don't briefly show for the next one
  /// before its own [load] completes.
  void reset() {
    _locations = [];
    _favoriteIds.clear();
    _isLoaded = false;
    notifyListeners();
  }

  /// POST /favorites/:locationId/toggle. Updates the local cache
  /// optimistically (so the heart flips instantly) and reverts it if the
  /// request fails, rethrowing an [ApiException] the caller can surface.
  Future<void> toggle(ParkingLocation location) async {
    final wasFavorite = _favoriteIds.contains(location.id);
    if (wasFavorite) {
      _favoriteIds.remove(location.id);
      _locations.removeWhere((l) => l.id == location.id);
    } else {
      _favoriteIds.add(location.id);
      _locations = [location, ..._locations];
    }
    notifyListeners();

    try {
      await _dio.post('/favorites/${location.id}/toggle');
    } on DioException catch (e) {
      if (wasFavorite) {
        _favoriteIds.add(location.id);
        _locations = [location, ..._locations];
      } else {
        _favoriteIds.remove(location.id);
        _locations.removeWhere((l) => l.id == location.id);
      }
      notifyListeners();
      throw mapDioError(e);
    }
  }
}
