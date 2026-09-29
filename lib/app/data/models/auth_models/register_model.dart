class RegisterModel {
  final bool? success;
  final String? message;
  final RegisterData? data;

  RegisterModel({this.success, this.message, this.data});

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        success: json['success'],
        message: json['message'],
        data: json['data'] == null ? null : RegisterData.fromJson(json['data']),
      );
}

class RegisterData {
  final String? userId;
  final String? email;

  RegisterData({this.userId, this.email});

  factory RegisterData.fromJson(Map<String, dynamic> json) => RegisterData(
        userId: json['userId'],
        email: json['email'],
      );
}
