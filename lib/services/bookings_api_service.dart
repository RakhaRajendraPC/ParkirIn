import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Talks to the backend's Bookings module (`/bookings`). Requires auth — the
/// JWT is attached automatically by the shared [ApiClient]. Methods return
/// raw `Map<String, dynamic>` since no screen needs a dedicated model yet,
/// matching the `LocationsApiService.getLocationDetail`/`getLocationSlots`
/// precedent.
class BookingsApiService {
  BookingsApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// POST /bookings. Requires the caller to currently hold the Redis lock
  /// on [slotId] (acquired via [SlotLockService.lockSlot]). Throws
  /// [ApiException] with `statusCode == 409` if that lock has expired or is
  /// invalid — the backend's own message is specific and safe to show
  /// as-is. The response includes `lockExpiresAt`, the real expiry after
  /// the backend extends the lock to a payment window.
  Future<Map<String, dynamic>> createBooking({
    required String slotId,
    required String vehicleId,
    required DateTime checkInPlanned,
    required DateTime checkOutPlanned,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/bookings',
        data: {
          'slotId': slotId,
          'vehicleId': vehicleId,
          'checkInPlanned': checkInPlanned.toIso8601String(),
          'checkOutPlanned': checkOutPlanned.toIso8601String(),
        },
      );
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /bookings/:code/payment. For `method: 'va'`, the response
  /// includes a `vaNumbers` array (bank + va_number pairs, Midtrans's own
  /// shape) among other channel fields.
  Future<Map<String, dynamic>> initiatePayment(
    String bookingCode, {
    String method = 'va',
    String? bank,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingCode/payment',
        data: {
          'method': method,
          if (bank != null) 'bank': bank,
        },
      );
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /bookings/:code — used for polling the webhook-driven status
  /// transition from `menunggu_pembayaran` to `dipesan`.
  Future<Map<String, dynamic>> getBooking(String bookingCode) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/bookings/$bookingCode');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
