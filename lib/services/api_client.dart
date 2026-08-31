import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Backend base URL.
///
/// Currently set for the Android Emulator, whose fixed alias for the host
/// machine's localhost is 10.0.2.2 (not a real network address — this only
/// works from inside the emulator). To test on a physical device instead,
/// change this single line to the host machine's LAN IP, e.g.
/// 'http://192.168.1.23:3000'.
const String _baseUrl = 'http://10.0.2.2:3000';

const String authTokenStorageKey = 'auth_token';

/// Shared Dio instance used by all API services. Attaches the stored JWT
/// (if any) to every outgoing request.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: authTokenStorageKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Dio get dio => _dio;
}
