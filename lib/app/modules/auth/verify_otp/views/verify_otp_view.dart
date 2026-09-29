import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: context.titleLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2D2D),
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade400, width: 0.8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColor.primary, width: 1.2),
      ),
    );

    return AppScaffold(
      appbarTitle: controller.isRegister ? 'Verify Email' : 'Forgot Password',
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            32.height,
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
              child: AppSvgIcon(
                Assets.icons.emailFillIcon,
                color: Colors.white,
                height: 25.w,
                width: 25.w,
              ),
            ),
            24.height,
            AppText(
              'OTP Verification',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
            12.height,
            AppText(
              controller.isRegister
                  ? 'Enter the OTP sent to ${controller.email} to verify your email and start using your account.'
                  : 'Enter the OTP sent to ${controller.email} to verify your identity. Once verified, you can proceed to reset your password.',
              style: context.bodyMedium.copyWith(
                color: AppColor.hintText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            36.height,
            Pinput(
              length: VerifyOtpController.otpLength,
              controller: controller.otpController,
              focusNode: controller.focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: focusedPinTheme,
              separatorBuilder: (index) => SizedBox(width: 10.w),
              onCompleted: controller.onOtpCompleted,
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 1.5, height: 22.h, color: AppColor.primary),
                ],
              ),
            ),
            20.height,
            Obx(
              () => AppText(
                controller.isExpired
                    ? 'Code expired'
                    : 'Code expires in ${controller.expiryText}',
                style: context.bodyMedium.copyWith(
                  color: controller.isExpired ? Colors.red : AppColor.hintText,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            8.height,
            Obx(
              () => controller.isResending.value
                  ? GlobalLoading(size: 22.sp)
                  : Text.rich(
                      TextSpan(
                        style: context.bodyMedium.copyWith(
                          color: AppColor.hintText,
                        ),
                        children: [
                          const TextSpan(text: "Haven't received the code? "),
                          TextSpan(
                            text: 'Resend',
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = controller.onResend,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            36.height,
            Obx(
              () => GlobalButton(
                text: 'Verify',
                onTap: controller.onVerify,
                widget: controller.isVerifying.value
                    ? GlobalLoading(size: 24.sp, color: AppColor.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
