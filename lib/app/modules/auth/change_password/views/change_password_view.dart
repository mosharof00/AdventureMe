import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: controller.isResetMode ? 'Forgot Password' : 'Change Password',
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              40.height,
              AppText(
                controller.isResetMode
                    ? 'Enter New Password'
                    : 'Change Your Password',
                style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              10.height,
              AppText(
                controller.isResetMode
                    ? 'Enter your new password.'
                    : 'Enter your current password, then choose a new one.',
                style: context.bodyMedium.copyWith(
                  color: AppColor.hintText,
                ),
                textAlign: TextAlign.center,
              ),
              36.height,
              if (!controller.isResetMode) ...[
                PasswordInputField(
                  label: 'Current Password',
                  hintText: 'Current password',
                  controller: controller.currentPasswordController,
                  validator: controller.validateCurrentPassword,
                ),
                16.height,
              ],
              PasswordInputField(
                label: controller.isResetMode ? 'Password' : 'New Password',
                hintText: 'Password',
                controller: controller.passwordController,
                validator: controller.validateNewPassword,
              ),
              16.height,
              PasswordInputField(
                label: 'Re-Enter New Password',
                hintText: 'Password',
                controller: controller.confirmPasswordController,
                validator: controller.validateConfirmPassword,
              ),
              36.height,
              Obx(
                () => GlobalButton(
                  text: 'Update Password',
                  onTap: controller.onUpdatePassword,
                  widget: controller.isLoading.value
                      ? GlobalLoading(size: 24.sp, color: AppColor.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
