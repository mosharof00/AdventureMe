import '../config/app_config.dart';

class ApiEndpoint {
  ///  Base URL
  static const String domainUrl = AppConfig.domainUrl;
  static const String baseUrl = '$domainUrl/api';

  ///  Auth
  static const String authBase = '$baseUrl/auth';
  static const String register = '$authBase/register'; // post
  static const String verifyOtp = '$authBase/verify-otp'; // post
  static const String resendOtp = '$authBase/resend-otp'; // post
  static const String forgotPassword = '$authBase/forgot-password'; // post
  static const String resetPassword = '$authBase/reset-password'; // post
  static const String login = '$authBase/login'; // post
  static const String me = '$authBase/me'; // get
  static const String logout = '$authBase/logout'; // post
  static const String refresh = '$authBase/refresh'; // post (Bearer = current token)
  static const String changePassword = '$authBase/change-password'; // patch
  static const String updateProfile = '$authBase/profile'; // patch (multipart)

  /// Endpoints whose 401 must not trigger the session-expired flow: bad
  /// credentials, an invalid OTP/reset token, or an already-expired token on
  /// logout.
  static const List<String> _credentialPaths = [
    login,
    register,
    verifyOtp,
    resendOtp,
    forgotPassword,
    resetPassword,
    logout,
    refresh,
  ];

  /// Authenticated endpoints that also answer 401 for a wrong password, so a
  /// 401 there is a session expiry only when the token itself has expired.
  static const List<String> _passwordCheckPaths = [changePassword];

  static bool isAuthPath(String? path) =>
      path != null && _credentialPaths.any(path.startsWith);

  static bool isPasswordCheckPath(String? path) =>
      path != null && _passwordCheckPaths.any(path.startsWith);

  ///  Trips
  static const String trips = '$baseUrl/trips'; // post: create

  /// user profile
  static const String profileDetails = '$baseUrl/profile/details'; // get
  static const String profileUpdate = '$baseUrl/profile/update'; // post

  ///  product
  static const String productList = 'https://dummyjson.com/products'; // get
  static const String productDetails = '$baseUrl/product/details'; // get
}
