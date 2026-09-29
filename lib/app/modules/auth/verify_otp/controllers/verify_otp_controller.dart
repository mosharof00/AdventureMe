import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/auth_models/otp_purpose.dart';
import 'package:adventureme/app/data/models/auth_models/verify_otp_model.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';

import '../../../../routes/app_pages.dart';

/// Arguments: `{'email': String, 'purpose': OtpPurpose}`.
class VerifyOtpController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  static const int otpLength = 5;
  static const Duration otpValidity = Duration(minutes: 5);

  final otpController = TextEditingController();
  final focusNode = FocusNode();

  late final String email;
  late final OtpPurpose purpose;

  final isVerifying = false.obs;
  final isResending = false.obs;
  final remainingSeconds = otpValidity.inSeconds.obs;

  Timer? _timer;

  bool get isExpired => remainingSeconds.value <= 0;

  bool get isRegister => purpose == OtpPurpose.register;

  String get expiryText {
    final s = remainingSeconds.value;
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? const {};
    email = args['email'] as String? ?? '';
    purpose = args['purpose'] as OtpPurpose? ?? OtpPurpose.register;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    remainingSeconds.value = otpValidity.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 1) {
        remainingSeconds.value = 0;
        timer.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void onOtpCompleted(String pin) => onVerify();

  Future<void> onVerify() async {
    if (isVerifying.value) return;
    final code = otpController.text.trim();
    if (code.length < otpLength) {
      globalSnackBar(
        title: 'Invalid OTP',
        message: 'Please enter the $otpLength-digit code.',
      );
      return;
    }
    if (isExpired) {
      globalSnackBar(
        title: 'OTP Expired',
        message: 'The code has expired. Please tap Resend to get a new one.',
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isVerifying.value = true;
      final response = await _authRepository.verifyOtp(
        email: email,
        code: code,
        purpose: purpose,
      );

      final handled = response.success == true &&
          switch (purpose) {
            OtpPurpose.register => await _onRegisterVerified(response.data),
            OtpPurpose.forgotPassword =>
              _onForgotPasswordVerified(response.data),
          };
      if (!handled) {
        globalSnackBar(
          title: 'Verification Failed',
          message: response.message ?? 'Unable to verify. Please try again.',
        );
      }
    } catch (e) {
      otpController.clear();
      handleException(e, context: 'Verify OTP');
    } finally {
      isVerifying.value = false;
    }
  }

  /// Email verified: the response is a session, so log the user in.
  Future<bool> _onRegisterVerified(VerifyOtpData? data) async {
    final token = data?.accessToken;
    final userId = data?.userId;
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }
    await HelperUtils.setUser(userId: userId, token: token, role: data?.type);
    Get.offAllNamed(Routes.MAIN_PAGE);
    return true;
  }

  /// Replaces this screen so back from the reset screen doesn't return to an
  /// already-used OTP.
  bool _onForgotPasswordVerified(VerifyOtpData? data) {
    final resetToken = data?.resetToken;
    if (resetToken == null || resetToken.isEmpty) return false;
    final validFor = data?.expiresInSeconds != null
        ? Duration(seconds: data!.expiresInSeconds!)
        : data?.expiresAt?.difference(DateTime.now()) ??
            const Duration(minutes: 15);
    Get.offNamed(
      Routes.CHANGE_PASSWORD,
      arguments: {
        'resetToken': resetToken,
        'expiresAt': DateTime.now().add(validFor),
      },
    );
    return true;
  }

  Future<void> onResend() async {
    if (isResending.value) return;
    try {
      isResending.value = true;
      await _authRepository.resendOtp(email: email, purpose: purpose);
      otpController.clear();
      _startTimer();
      globalSnackBar(
        title: 'OTP Sent',
        message: 'A new code has been sent to $email.',
      );
    } catch (e) {
      handleException(e, context: 'Resend OTP');
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
