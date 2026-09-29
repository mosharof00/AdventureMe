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

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Forgot Password',
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              40.height,
              AppText(
                'Send an OTP',
                style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              10.height,
              AppText(
                'Enter your email address to reset your password.',
                style: context.bodyMedium.copyWith(
                  color: AppColor.hintText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              36.height,
              AppInputTextFormField(
                label: 'Email',
                hintText: 'example@gmail.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              28.height,
              Obx(
                () => GlobalButton(
                  text: 'Send OTP',
                  onTap: controller.onSendOtp,
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
