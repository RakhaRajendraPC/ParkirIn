import 'package:dio/dio.dart';

/// Thrown by API service methods on any failed request. [message] is always
/// a human-readable string suitable for showing directly to the user —
/// either the backend's own validation/error message, or a clear fallback
/// for network-level failures (e.g. backend not running).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Maps a [DioException] to an [ApiException] with a human-readable message
/// — the backend's own error message when available (Nest's ValidationPipe
/// returns `message` as a string, or as an array of strings when multiple
/// class-validator rules fail), otherwise a clear network-failure fallback.
/// Shared by every API service so error handling reads the same everywhere.
ApiException mapDioError(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] != null) {
    final rawMessage = data['message'];
    final message =
        rawMessage is List ? rawMessage.join(', ') : rawMessage.toString();
    return ApiException(message, statusCode: e.response?.statusCode);
  }

  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiException(
        'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
      );
    default:
      return ApiException(e.message ?? 'Terjadi kesalahan tak terduga');
  }
}
