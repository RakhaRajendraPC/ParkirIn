import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../models/parking_location_model.dart';

/// Talks to the backend's Locations module (`/locations`). Deliberately
/// public/no-auth on the backend side, but reuses [ApiClient]'s shared Dio
/// instance anyway — the JWT interceptor is a no-op when there's no token.
class LocationsApiService {
  LocationsApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// GET /locations — unfiltered list. Filter query params exist on the
  /// backend but are intentionally not wired here yet.
  Future<List<ParkingLocation>> getLocations() async {
    try {
      final res = await _dio.get<List<dynamic>>('/locations');
      return res.data!
          .map((json) => ParkingLocation.fromApi(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /locations/:id — summary fields plus closingTime/totalSlots/
  /// availableSlots. Raw map since no screen consumes this yet.
  Future<Map<String, dynamic>> getLocationDetail(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/locations/$id');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /locations/:id/slots — live slot grid. Raw maps since no screen
  /// consumes this yet.
  Future<List<Map<String, dynamic>>> getLocationSlots(String id) async {
    try {
      final res = await _dio.get<List<dynamic>>('/locations/$id/slots');
      return res.data!.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
