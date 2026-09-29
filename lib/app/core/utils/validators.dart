import 'package:get/get.dart';

/// Form-field validators shared across screens. Password rules mirror the
/// backend so errors show before the request is sent.
class Validators {
  Validators._();

  static const int minPasswordLength = 8;

  static final _upper = RegExp(r'[A-Z]');
  static final _lower = RegExp(r'[a-z]');
  static final _digit = RegExp(r'\d');

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  /// Presence only, for login where older passwords may not meet the rules.
  static String? requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    return null;
  }

  static String? strongPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (!_upper.hasMatch(password) ||
        !_lower.hasMatch(password) ||
        !_digit.hasMatch(password)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      if ((value ?? '').isEmpty) return 'Please confirm your password';
      if (value != password()) return 'Passwords do not match';
      return null;
    };
  }
}
