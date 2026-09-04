import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Talks to the backend's Notifications module (`/notifications`). Requires
/// auth — the JWT is attached automatically by the shared [ApiClient].
class NotificationsApiService {
  NotificationsApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// GET /notifications — all of the caller's, ordered createdAt desc, each
  /// including its nested `booking` (bookingCode only) when present.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await _dio.get<List<dynamic>>('/notifications');
      return res.data!.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /notifications/:id/read
  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /notifications/read-all — no body, marks every unread
  /// notification for the caller as read.
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /notifications/read — body { ids: [...] }, bulk mark-read.
  Future<void> markMultipleAsRead(Iterable<String> ids) async {
    try {
      await _dio.patch('/notifications/read', data: {'ids': ids.toList()});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /notifications/:id
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /notifications — body { ids: [...] }, bulk delete.
  Future<void> deleteMultiple(Iterable<String> ids) async {
    try {
      await _dio.delete('/notifications', data: {'ids': ids.toList()});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
