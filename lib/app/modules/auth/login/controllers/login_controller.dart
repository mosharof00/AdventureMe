import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/core/utils/validators.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';

import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = true.obs;
  final isLoading = false.obs;

  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  String? validateEmail(String? value) => Validators.email(value);

  String? validatePassword(String? value) => Validators.requiredPassword(value);

  Future<void> onLogin() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final data = response.data;
      final token = data?.accessToken;
      final userId = data?.userId;

      if (response.success != true ||
          token == null ||
          token.isEmpty ||
          userId == null ||
          userId.isEmpty) {
        globalSnackBar(
          title: 'Login Failed',
          message: response.message ?? 'Unable to login. Please try again.',
        );
        return;
      }

      await HelperUtils.setUser(
        userId: userId,
        token: token,
        refreshToken: data?.refreshToken,
        role: data?.type,
        persist: rememberMe.value,
      );

      Get.offAllNamed(Routes.MAIN_PAGE);
    } catch (e) {
      handleException(e, context: 'Login');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(Routes.REGISTER);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
