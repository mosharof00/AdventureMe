/// `data` depends on the purpose: REGISTER returns a session
/// (userId, type, accessToken); FORGOT_PASSWORD returns a reset token.
class VerifyOtpModel {
  final bool? success;
  final String? message;
  final VerifyOtpData? data;

  VerifyOtpModel({this.success, this.message, this.data});

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
        success: json['success'],
        message: json['message'],
        data: json['data'] == null ? null : VerifyOtpData.fromJson(json['data']),
      );
}

class VerifyOtpData {
  final String? userId;
  final String? type;
  final String? accessToken;
  final String? resetToken;
  final DateTime? expiresAt;
  final int? expiresInSeconds;

  VerifyOtpData({
    this.userId,
    this.type,
    this.accessToken,
    this.resetToken,
    this.expiresAt,
    this.expiresInSeconds,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) => VerifyOtpData(
        userId: json['userId'],
        type: json['type'],
        accessToken: json['accessToken'],
        resetToken: json['resetToken'],
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      );
}
