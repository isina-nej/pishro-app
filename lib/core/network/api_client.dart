import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin Dio wrapper that speaks the backend's JSend envelope.
///
/// The backend is inconsistent by design-history: 156 of 175 route handlers
/// return `{status, data, message}`, the rest return bare JSON. [_unwrap]
/// handles both so callers always receive the payload itself.
class ApiClient {
  ApiClient(this._dio, this._tokens) {
    _dio
      ..options.baseUrl = AppConfig.apiBaseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 20)
      ..options.headers['Accept'] = 'application/json'
      // Non-2xx must reach our own mapper rather than throwing raw.
      ..options.validateStatus = (s) => s != null && s < 500;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) async =>
      _send<T>(() => _dio.get(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send<T>(() => _dio.post(path, data: body, queryParameters: query));

  Future<T> put<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.put(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.patch(path, data: body));

  Future<T> delete<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.delete(path, data: body));

  Future<T> _send<T>(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> res;
    try {
      res = await call();
    } on DioException catch (e) {
      throw switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.connectionError =>
          const NetworkException(),
        _ => ServerException(e.message ?? 'خطای نامشخص در ارتباط با سرور'),
      };
    }
    return _unwrap<T>(res);
  }

  T _unwrap<T>(Response<dynamic> res) {
    final status = res.statusCode ?? 500;
    final body = res.data;

    if (status == 401 || status == 403) {
      throw UnauthorizedException(_messageOf(body) ?? 'دسترسی شما منقضی شده است.');
    }

    // JSend envelope.
    if (body is Map<String, dynamic> && body.containsKey('status')) {
      switch (body['status']) {
        case 'success':
          return body['data'] as T;
        case 'fail':
          throw ValidationException(
            _messageOf(body) ?? 'اطلاعات واردشده معتبر نیست.',
            _fieldErrors(body['data']),
          );
        case 'error':
          throw ServerException(
            _messageOf(body) ?? 'خطایی رخ داد.',
            body['code'] as String?,
          );
      }
    }

    // Un-enveloped handler (19 of them). Trust the HTTP status instead.
    if (status == 404) throw NotFoundException(_messageOf(body) ?? 'موردی یافت نشد.');
    if (status >= 400) throw ServerException(_messageOf(body) ?? 'خطایی رخ داد.');

    return body as T;
  }

  static String? _messageOf(dynamic body) {
    if (body is! Map) return null;
    final m = body['message'] ?? body['error'];
    return m is String && m.isNotEmpty ? m : null;
  }

  /// JSend `fail` payloads map field -> String | String[]. The deck only ever
  /// shows one message per field, so collapse lists to their first entry.
  static Map<String, String> _fieldErrors(dynamic data) {
    if (data is! Map) return const {};
    final out = <String, String>{};
    data.forEach((k, v) {
      if (v is String && v.isNotEmpty) {
        out[k.toString()] = v;
      } else if (v is List && v.isNotEmpty) {
        out[k.toString()] = v.first.toString();
      }
    });
    return out;
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider), ref.watch(tokenStorageProvider)),
);
