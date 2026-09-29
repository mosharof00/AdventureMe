import 'package:dio/dio.dart';
import '../utils/helper_utils.dart';
import 'api_exception.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
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
    if (ApiException.fromDio(err).isSessionExpired) {
      final data = err.response?.data;
      HelperUtils.handleSessionExpired(
        data is Map ? data['message']?.toString() : null,
      );
    }

    handler.next(err);
  }
}
