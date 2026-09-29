import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/validators.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/auth/login/controllers/login_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../../../../routes/app_pages.dart';

/// Reset mode (forgot-password flow) when opened with
/// `{'resetToken': String, 'expiresAt': DateTime}`; otherwise the logged-in
/// change-password screen from Settings, which also asks for the current
/// password.
class ChangePasswordController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  String? _resetToken;
  DateTime? _resetExpiresAt;

  bool get isResetMode => _resetToken != null;

  late final String? Function(String?) validateConfirmPassword =
      Validators.confirmPassword(() => passwordController.text);

  String? validateCurrentPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Current password is required';
    return null;
  }

  String? validateNewPassword(String? value) {
    final error = Validators.strongPassword(value);
    if (error != null) return error;
    if (!isResetMode && value == currentPasswordController.text) {
      return 'New password must be different from the current password';
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['resetToken'] is String) {
      _resetToken = args['resetToken'] as String;
      _resetExpiresAt = args['expiresAt'] as DateTime?;
    }
  }

  Future<void> onUpdatePassword() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (isResetMode) {
      await _resetPassword();
    } else {
      await _changePassword();
    }
  }

  Future<void> _changePassword() async {
    try {
      isLoading.value = true;
      final message = await _authRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      _showSuccess(message ?? 'Your password has been updated successfully!');
    } catch (e) {
      handleException(e, context: 'Change Password');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resetPassword() async {
    if (_resetExpiresAt != null && DateTime.now().isAfter(_resetExpiresAt!)) {
      globalSnackBar(
        title: 'Session Expired',
        message: 'Your reset session has expired. Please request a new OTP.',
      );
      Get.until(
        (route) =>
            route.settings.name == Routes.FORGOT_PASSWORD || route.isFirst,
      );
      return;
    }

    try {
      isLoading.value = true;
      final message = await _authRepository.resetPassword(
        resetToken: _resetToken!,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      _showSuccess(message ?? 'Password reset successfully. Please log in.');
    } catch (e) {
      handleException(e, context: 'Reset Password');
    } finally {
      isLoading.value = false;
    }
  }

  /// Closing the sheet in any way (button or system back) leaves the screen:
  /// to login after a reset (the token is spent), back to Settings after a
  /// change.
  Future<void> _showSuccess(String description) async {
    await AppBottomSheet.show(
      sticker: Assets.images.happySticker.path,
      title: 'Password Update!',
      description: description,
      isDismissible: !isResetMode,
      enableDrag: !isResetMode,
      actionWidget: GlobalButton(
        text: isResetMode ? 'Back to Login' : 'Done',
        onTap: () => Get.back(),
      ),
    );
    _leave();
  }

  bool _leaving = false;

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!isResetMode) {
      Get.back();
    } else if (Get.isRegistered<LoginController>()) {
      Get.until((route) => route.settings.name == Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
