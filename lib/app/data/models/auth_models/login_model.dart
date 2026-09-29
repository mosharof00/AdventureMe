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
  LoginData({this.userId, this.type, this.accessToken});

  final String? userId;
  final String? type;
  final String? accessToken;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    userId: json['userId'],
    type: json['type'],
    accessToken: json['accessToken'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type,
    'accessToken': accessToken,
  };
}
