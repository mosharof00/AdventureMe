import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/custom_check_box.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                  80.height,
                  AppText(
                    'Welcome Back!',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  8.height,
                  AppText(
                    'Automatically or manually log where you go',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  40.height,
                  AppInputTextFormField(
                    label: 'Email',
                    hintText: 'example@gmail.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                  ),
                  16.height,
                  PasswordInputField(
                    label: 'Password',
                    hintText: 'Enter password',
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                  ),
                  16.height,
                  const _RememberForgotRow(),
                  32.height,
                  Obx(
                    () => GlobalButton(
                      text: 'Login',
                      onTap: controller.onLogin,
                      widget: controller.isLoading.value
                          ? GlobalLoading(size: 24.sp, color: AppColor.white)
                          : null,
                    ),
                  ),
                  28.height,
                  const _SignUpFooter(),
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

class _RememberForgotRow extends GetView<LoginController> {
  const _RememberForgotRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => CustomCheckBox(
            isChecked: controller.rememberMe.value,
            onTap: controller.toggleRememberMe,
            size: 18.sp,
          ),
        ),
        8.width,
        AppText('Remember Me', style: context.bodyMedium),
        const Spacer(),
        GestureDetector(
          onTap: (){
            Get.toNamed(Routes.FORGOT_PASSWORD);
          },
          child: AppText(
            'Forgot Password?',
            style: context.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignUpFooter extends GetView<LoginController> {
  const _SignUpFooter();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: context.bodyMedium.copyWith(color: const Color(0xFF2D2D2D)),
        children: [
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()..onTap = controller.goToRegister,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
