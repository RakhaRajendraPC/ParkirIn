import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'api_exception.dart';

export 'api_exception.dart' show ApiException;

class AuthApiService {
  AuthApiService({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? ApiClient.instance.dio,
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      return _storeTokenAndReturn(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post('/auth/otp/send', data: {'phone': phone});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> verifyOtp(String phone, String code) async {
    try {
      await _dio.post(
        '/auth/otp/verify',
        data: {'phone': phone, 'code': code},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _storeTokenAndReturn(res.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/auth/me');
      return res.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Clears the locally stored token. No backend call — the JWT is
  /// stateless, so there's nothing server-side to invalidate.
  Future<void> logout() async {
    await _storage.delete(key: authTokenStorageKey);
  }

  Future<Map<String, dynamic>> _storeTokenAndReturn(
    Map<String, dynamic> data,
  ) async {
    final token = data['accessToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: authTokenStorageKey, value: token);
    }
    return data;
  }
}
