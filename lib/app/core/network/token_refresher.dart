import 'package:dio/dio.dart';

import '../utils/helper_utils.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';

enum RefreshResult {
  /// A new access token is stored and in use.
  refreshed,

  /// The server refused the refresh; the session is over.
  rejected,

  /// Network/server trouble; the session may still be valid.
  failed,
}

/// Exchanges the current access token (even an expired one) for a new one via
/// `POST /auth/refresh`. Concurrent callers share one in-flight request.
class TokenRefresher {
  TokenRefresher._();

  /// Separate client without [AuthInterceptor] so a refresh can never trigger
  /// another refresh.
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoint.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static Future<RefreshResult>? _inFlight;

  static Future<RefreshResult> refresh() {
    return _inFlight ??= _refresh().whenComplete(() => _inFlight = null);
  }

  static Future<RefreshResult> _refresh() async {
    final current = HelperUtils.token;
    if (current.isEmpty) return RefreshResult.rejected;

    try {
      final response = await _dio.post(
        ApiEndpoint.refresh,
        options: Options(headers: {'Authorization': 'Bearer $current'}),
      );

      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final newToken = data is Map ? data['accessToken']?.toString() : null;
      if (body is! Map || body['success'] != true || newToken == null || newToken.isEmpty) {
        Log.w('[Refresh Token] Unexpected response: $body');
        return RefreshResult.rejected;
      }

      await HelperUtils.updateToken(
        newToken,
        userId: data['userId']?.toString(),
        role: data['type']?.toString(),
      );
      Log.i('[Refresh Token] Access token refreshed');
      return RefreshResult.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        Log.w('[Refresh Token] Rejected ($status): ${e.response?.data}');
        return RefreshResult.rejected;
      }
      Log.e('[Refresh Token] Failed: $e');
      return RefreshResult.failed;
    } catch (e) {
      Log.e('[Refresh Token] Failed: $e');
      return RefreshResult.failed;
    }
  }
}
