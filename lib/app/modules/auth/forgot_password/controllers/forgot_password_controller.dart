import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/validators.dart';
import 'package:adventureme/app/data/models/auth_models/otp_purpose.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';

import '../../../../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;

  String? validateEmail(String? value) => Validators.email(value);

  Future<void> onSendOtp() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = emailController.text.trim();
    try {
      isLoading.value = true;
      final message = await _authRepository.forgotPassword(email: email);

      globalSnackBar(
        title: 'OTP Sent',
        message: message ?? 'An OTP has been sent to your email.',
      );
      Get.toNamed(
        Routes.VERIFY_OTP,
        arguments: {'email': email, 'purpose': OtpPurpose.forgotPassword},
      );
    } catch (e) {
      handleException(e, context: 'Forgot Password');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
