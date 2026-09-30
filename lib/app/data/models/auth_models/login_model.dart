class LoginModel {
  LoginModel({this.success, this.message, this.data});

  final bool? success;
  final String? message;
  final LoginData? data;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json['success'],
    message: json['message'],
    data: json['data'] == null ? null : LoginData.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class LoginData {
  LoginData({this.userId, this.type, this.accessToken, this.refreshToken});

  final String? userId;
  final String? type;
  final String? accessToken;
  final String? refreshToken;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    userId: json['userId'],
    type: json['type'],
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
