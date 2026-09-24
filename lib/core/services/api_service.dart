import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import '../widgets/app_error_dialog.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseUrl;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(_withFriendlyMessage(error));
      },
    ));
  }

  /// Every failed request carries a customer-safe `message` (offline, timeout, server error,
  /// or the backend's own user-facing text), so callers reading data['message'] never show raw errors.
  DioException _withFriendlyMessage(DioException e) {
    final friendly = AppError.fromDio(e);
    final original = e.response?.data;
    final data = original is Map ? Map<String, dynamic>.from(original) : <String, dynamic>{};
    data['success'] = false;
    data['message'] = friendly;
    final resp = e.response != null
        ? Response(requestOptions: e.requestOptions, statusCode: e.response!.statusCode, headers: e.response!.headers, data: data)
        : Response(requestOptions: e.requestOptions, statusCode: 0, data: data);
    return e.copyWith(response: resp);
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token');
      if (refresh == null) return false;
      final res = await _dio.post('/auth/refresh-token', data: {'refreshToken': refresh});
      final data = res.data['data'];
      await _storage.write(key: 'access_token', value: data['accessToken']);
      await _storage.write(key: 'refresh_token', value: data['refreshToken']);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // Generic methods
  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
