import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/validators.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/custom_check_box.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.bgGradient2,
              AppColor.bgGradient1,
              AppColor.bgGradient3,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  24.height,
                  Assets.logos.appLogo.image(width: 120.w, height: 120.w),
                  16.height,
                  AppText(
                    'Welcome Back!',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  28.height,
                  AppInputTextFormField(
                    label: 'Full Name',
                    hintText: 'you name',
                    controller: controller.fullNameController,
                    keyboardType: TextInputType.name,
                    validator: Validators.name,
                  ),
                  16.height,
                  AppInputTextFormField(
                    label: 'Email',
                    hintText: 'example@gmail.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  16.height,
                  PasswordInputField(
                    label: 'Password',
                    hintText: 'Password',
                    controller: controller.passwordController,
                    validator: Validators.strongPassword,
                  ),
                  16.height,
                  PasswordInputField(
                    label: 'Confirm Password',
                    hintText: 'Password',
                    controller: controller.confirmPasswordController,
                    validator: controller.validateConfirmPassword,
                  ),
                  16.height,
                  const _TermsRow(),
                  28.height,
                  Obx(
                    () => GlobalButton(
                      text: 'Sign Up',
                      onTap: controller.onSignUp,
                      widget: controller.isLoading.value
                          ? GlobalLoading(size: 24.sp, color: AppColor.white)
                          : null,
                    ),
                  ),
                  24.height,
                  const _LoginFooter(),
                  24.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends GetView<RegisterController> {
  const _TermsRow();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: CustomCheckBox(
              isChecked: controller.agreedToTerms.value,
              onTap: controller.toggleTerms,
              size: 18.sp,
            ),
          ),
          10.width,
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.bodySmall.copyWith(
                  color: const Color(0xFF2D2D2D),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.openTermsOfService,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.openPrivacyPolicy,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends GetView<RegisterController> {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: context.bodyMedium.copyWith(color: const Color(0xFF2D2D2D)),
        children: [
          const TextSpan(text: 'Already have an account? '),
          TextSpan(
            text: 'Log In',
            style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()..onTap = controller.goToLogin,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
