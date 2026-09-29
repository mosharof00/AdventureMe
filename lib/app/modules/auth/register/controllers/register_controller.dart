import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/validators.dart';
import 'package:adventureme/app/data/models/auth_models/otp_purpose.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';

import '../../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final agreedToTerms = true.obs;
  final isLoading = false.obs;

  late final String? Function(String?) validateConfirmPassword =
      Validators.confirmPassword(() => passwordController.text);

  void toggleTerms() => agreedToTerms.value = !agreedToTerms.value;

  Future<void> onSignUp() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!agreedToTerms.value) {
      globalSnackBar(
        title: 'Terms Required',
        message: 'Please agree to the Terms of Service and Privacy Policy.',
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    final email = emailController.text.trim();
    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        name: fullNameController.text.trim(),
        email: email,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (response.success != true) {
        globalSnackBar(
          title: 'Registration Failed',
          message: response.message ?? 'Unable to register. Please try again.',
        );
        return;
      }

      globalSnackBar(
        title: 'Verify Your Email',
        message: response.message ?? 'An OTP has been sent to your email.',
      );
      Get.toNamed(
        Routes.VERIFY_OTP,
        arguments: {
          'email': response.data?.email ?? email,
          'purpose': OtpPurpose.register,
        },
      );
    } catch (e) {
      handleException(e, context: 'Register');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();

  void openTermsOfService() {
    // UI only — open terms later
  }

  void openPrivacyPolicy() => Get.toNamed(Routes.PRIVACY_POLICY);

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
