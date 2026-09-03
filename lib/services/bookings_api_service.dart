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

  /// GET /bookings — all of the caller's bookings, each including its
  /// nested `location`, `vehicle`, and `slot` objects.
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final res = await _dio.get<List<dynamic>>('/bookings');
      return res.data!.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /bookings/:code/checkin. Requires the booking's status to
  /// currently be `dipesan`. Returns the updated booking.
  Future<Map<String, dynamic>> checkin(String bookingCode) async {
    try {
      final res =
          await _dio.post<Map<String, dynamic>>('/bookings/$bookingCode/checkin');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /bookings/:code/checkout-status. Requires status `check_in`.
  /// Returns `{ isOverstay, overstayFee, overstayHours, paymentStatus:
  /// 'not_required'|'unpaid'|'pending'|'paid', canCheckout }`.
  Future<Map<String, dynamic>> getCheckoutStatus(String bookingCode) async {
    try {
      final res = await _dio
          .get<Map<String, dynamic>>('/bookings/$bookingCode/checkout-status');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /bookings/:code/overstay/payment. Unlike [initiatePayment], the
  /// backend's OverstayPaymentDto requires `gateway` explicitly (not
  /// defaulted server-side). For `method: 'va'`, the response includes a
  /// `vaNumbers` array, same shape as [initiatePayment].
  Future<Map<String, dynamic>> createOverstayPayment(
    String bookingCode, {
    String method = 'va',
    String gateway = 'midtrans',
    String? bank,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingCode/overstay/payment',
        data: {
          'method': method,
          'gateway': gateway,
          if (bank != null) 'bank': bank,
        },
      );
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /bookings/:code/checkout. Requires status `check_in`. Throws
  /// [ApiException] with `statusCode == 402` if an overstay fee exists and
  /// hasn't been paid yet — the backend re-verifies this independently of
  /// whatever the client believes from a prior checkout-status check.
  Future<Map<String, dynamic>> checkout(String bookingCode) async {
    try {
      final res =
          await _dio.post<Map<String, dynamic>>('/bookings/$bookingCode/checkout');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /bookings/:code/cancel. Only allowed while status is
  /// `menunggu_pembayaran` or `dipesan`.
  Future<Map<String, dynamic>> cancelBooking(String bookingCode) async {
    try {
      final res =
          await _dio.patch<Map<String, dynamic>>('/bookings/$bookingCode/cancel');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
