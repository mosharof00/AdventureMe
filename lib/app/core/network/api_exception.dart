import 'package:dio/dio.dart';

import '../utils/helper_utils.dart';
import 'api_endpoints.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? path;

  ApiException(this.message, {this.statusCode, this.path});

  /// Whether this error means the session is gone (handled by
  /// [AuthInterceptor]) rather than bad credentials shown to the user.
  bool get isSessionExpired {
    if (statusCode != 401 || ApiEndpoint.isAuthPath(path)) return false;
    if (ApiEndpoint.isPasswordCheckPath(path)) {
      final token = HelperUtils.token;
      return token.isEmpty || HelperUtils.isTokenExpired(token);
    }
    return true;
  }

  factory ApiException.fromDio(DioException e) {
    final path = e.requestOptions.uri.toString();

    if (e.type == DioExceptionType.connectionTimeout) {
      return ApiException("Connection timeout", path: path);
    }

    if (e.type == DioExceptionType.badResponse) {
      return ApiException(
        _messageFrom(e.response?.data),
        statusCode: e.response?.statusCode,
        path: path,
      );
    }

    if (e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionError) {
      return ApiException("No Internet connection", path: path);
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException("Request timed out", path: path);
    }
    if (e.type == DioExceptionType.cancel) {
      return ApiException("Request was cancelled", path: path);
    }

    return ApiException("Something went wrong", path: path);
  }

  /// A field-level validation detail replaces the generic message
  /// ("Validation failed"); a detail without a field is a hint appended to it
  /// ("Email is already verified. You can log in instead.").
  static String _messageFrom(dynamic data) {
    if (data is String && data.isNotEmpty) return data;
    if (data is! Map) return "Server error";

    final message = data['message']?.toString();
    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      final first = details.first;
      final detail = first is Map ? first['message']?.toString() : null;
      if (detail != null && detail.isNotEmpty) {
        if (first['field'] != null || message == null || message.isEmpty) {
          return detail;
        }
        return '$message $detail';
      }
    }
    return message ?? "Server error";
  }
}
