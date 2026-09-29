import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/data/models/auth_models/login_model.dart';
import 'package:adventureme/app/data/models/auth_models/otp_purpose.dart';
import 'package:adventureme/app/data/models/auth_models/register_model.dart';
import 'package:adventureme/app/data/models/auth_models/verify_otp_model.dart';
import 'package:adventureme/app/data/models/user_models/user_model.dart';

abstract class IAuthRepository {
  Future<LoginModel> login({required String email, required String password});

  Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<VerifyOtpModel> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  });

  Future<void> resendOtp({required String email, required OtpPurpose purpose});

  /// Returns the server message; it's the same whether or not the email exists.
  Future<String?> forgotPassword({required String email});

  Future<String?> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  });

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<UserModel> getMe();

  /// Multipart; null fields are left unchanged on the server.
  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? about,
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    File? avatar,
  });

  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  @override
  Future<LoginModel> login({required String email, required String password}) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.login,
        data: {'email': email, 'password': password},
      ),
      (dynamic data) => LoginModel.fromJson(data),
      'Login',
    );
  }

  @override
  Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'type': 'USER',
        },
      ),
      (dynamic data) => RegisterModel.fromJson(data),
      'Register',
    );
  }

  @override
  Future<VerifyOtpModel> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.verifyOtp,
        data: {'email': email, 'code': code, 'purpose': purpose.value},
      ),
      (dynamic data) => VerifyOtpModel.fromJson(data),
      'Verify OTP',
    );
  }

  @override
  Future<String?> forgotPassword({required String email}) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.forgotPassword,
        data: {'email': email},
      ),
      (dynamic data) => data is Map ? data['message']?.toString() : null,
      'Forgot Password',
    );
  }

  @override
  Future<String?> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.resetPassword,
        data: {
          'resetToken': resetToken,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      ),
      (dynamic data) => data is Map ? data['message']?.toString() : null,
      'Reset Password',
    );
  }

  @override
  Future<void> resendOtp({required String email, required OtpPurpose purpose}) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.resendOtp,
        data: {'email': email, 'purpose': purpose.value},
      ),
      (_) {},
      'Resend OTP',
    );
  }

  @override
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _client.handleRequest(
      () => _client.dio.patch(
        ApiEndpoint.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      ),
      (dynamic data) => data is Map ? data['message']?.toString() : null,
      'Change Password',
    );
  }

  @override
  Future<UserModel> getMe() {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.me),
      (dynamic data) => UserModel.fromJson(data),
      'Get Me',
    );
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? about,
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    File? avatar,
  }) async {
    final fields = <String, String?>{
      'name': name,
      'username': username,
      'about': about,
      'gender': gender,
      'date_of_birth': dateOfBirth == null
          ? null
          : DateFormat('yyyy-MM-dd').format(dateOfBirth),
      'phone_number': phoneNumber,
    }..removeWhere((_, value) => value == null);

    final formData = FormData.fromMap(fields);
    if (avatar != null) {
      final fileName = avatar.path.split(Platform.pathSeparator).last;
      var ext = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpeg';
      if (ext == 'jpg') ext = 'jpeg';
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatar.path,
            filename: fileName,
            contentType: DioMediaType('image', ext),
          ),
        ),
      );
    }

    return _client.handleRequest(
      () => _client.dio.patch(ApiEndpoint.updateProfile, data: formData),
      (dynamic data) => UserModel.fromJson(data),
      'Update Profile',
    );
  }

  @override
  Future<void> logout() {
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.logout),
      (_) {},
      'Logout',
    );
  }
}
