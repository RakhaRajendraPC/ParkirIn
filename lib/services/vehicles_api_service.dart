import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'user_session.dart' show SavedVehicle;

class VehiclesApiService {
  VehiclesApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<SavedVehicle> createVehicle({
    required String plate,
    required String brand,
    required String type,
    required String color,
    bool isDefault = false,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/vehicles',
        data: {
          'plate': plate,
          'brand': brand,
          'type': type,
          'color': color,
          'isDefault': isDefault,
        },
      );
      return SavedVehicle.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<SavedVehicle>> getVehicles() async {
    try {
      final res = await _dio.get<List<dynamic>>('/vehicles');
      return res.data!
          .map((json) => SavedVehicle.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<SavedVehicle> getVehicle(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/vehicles/$id');
      return SavedVehicle.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<SavedVehicle> updateVehicle(
    String id, {
    String? plate,
    String? brand,
    String? type,
    String? color,
    bool? isDefault,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/vehicles/$id',
        data: {
          if (plate != null) 'plate': plate,
          if (brand != null) 'brand': brand,
          if (type != null) 'type': type,
          if (color != null) 'color': color,
          if (isDefault != null) 'isDefault': isDefault,
        },
      );
      return SavedVehicle.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<SavedVehicle> setDefaultVehicle(String id) async {
    try {
      final res =
          await _dio.patch<Map<String, dynamic>>('/vehicles/$id/default');
      return SavedVehicle.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Throws [ApiException] with the backend's actual message on failure —
  /// e.g. "Cannot delete a vehicle with existing bookings" surfaces as-is,
  /// not a generic error.
  Future<void> deleteVehicle(String id) async {
    try {
      await _dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
