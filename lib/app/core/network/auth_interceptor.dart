import 'package:dio/dio.dart';
import '../utils/helper_utils.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'token_refresher.dart';

/// Attaches the access token, refreshes it shortly before it expires, and on a
/// session 401 refreshes once and retries the request. The session-expired
/// dialog is shown only when the server rejects the refresh.
class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.uri.toString();

    if (HelperUtils.isLogin &&
        HelperUtils.token.isNotEmpty &&
        !ApiEndpoint.isAuthPath(path) &&
        HelperUtils.isTokenExpired(
          HelperUtils.token,
          leeway: HelperUtils.tokenRefreshLeeway,
        )) {
      await TokenRefresher.refresh();
    }

    final token = HelperUtils.token;
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if the response indicates the user is unauthenticated even with a 200 status
    if (response.data is Map && response.data['message'] == "Unauthenticated.") {
      HelperUtils.handleSessionExpired();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (!ApiException.fromDio(err).isSessionExpired) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedKey] == true;

    if (!alreadyRetried && HelperUtils.isLogin) {
      final result = await TokenRefresher.refresh();

      if (result == RefreshResult.refreshed) {
        try {
          return handler.resolve(await _retry(options));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }

      // Couldn't reach the server — keep the session and fail this request
      // as a connection error so the user sees a message.
      if (result == RefreshResult.failed) {
        return handler.next(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: err.error,
          ),
        );
      }
    }

    final data = err.response?.data;
    HelperUtils.handleSessionExpired(
      data is Map ? data['message']?.toString() : null,
    );
    handler.next(err);
  }

  /// Re-sends [options] with the new token. Multipart bodies are single-use,
  /// so they are cloned.
  Future<Response<dynamic>> _retry(RequestOptions options) {
    final data = options.data;
    return dio.fetch(
      options.copyWith(
        data: data is FormData ? data.clone() : data,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer ${HelperUtils.token}',
        },
        extra: {...options.extra, _retriedKey: true},
      ),
    );
  }
}
