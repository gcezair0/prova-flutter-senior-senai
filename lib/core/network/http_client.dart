import 'package:dio/dio.dart';
import '../config/env.dart';
import '../storage/token_storage.dart';

class HttpClient {


  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(_AuthInterceptor(dio, tokenStorage));

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  _AuthInterceptor(this._dio, this._tokenStorage);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await _tokenStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );

      await _tokenStorage.saveToken(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );

      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }
}