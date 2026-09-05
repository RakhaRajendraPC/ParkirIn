import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Talks to the backend's Reviews module (`/bookings/:code/review`,
/// `/locations/:id/reviews`).
class ReviewsApiService {
  ReviewsApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// POST /bookings/:code/review. Throws [ApiException] with
  /// `statusCode == 409` if the booking isn't checked out yet, or already
  /// has a review.
  Future<Map<String, dynamic>> submitReview(
    String bookingCode, {
    required int rating,
    String? comment,
    List<String>? tags,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingCode/review',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
          if (tags != null) 'tags': tags,
        },
      );
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /bookings/:code/review. A 404 here just means no review exists yet
  /// for this booking — a normal, expected state, so it's returned as
  /// `null` rather than surfaced to the caller as an [ApiException].
  Future<Map<String, dynamic>?> getBookingReview(String bookingCode) async {
    try {
      final res = await _dio
          .get<Map<String, dynamic>>('/bookings/$bookingCode/review');
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw mapDioError(e);
    }
  }

  /// GET /locations/:id/reviews. Public — no auth required. Each entry
  /// includes a nested `user: { name }`.
  Future<List<Map<String, dynamic>>> getLocationReviews(
    String locationId,
  ) async {
    try {
      final res =
          await _dio.get<List<dynamic>>('/locations/$locationId/reviews');
      return res.data!.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
