import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: OnboardingController.totalPages,
            itemBuilder: (_, index) => controller.onboardingImages[index].image(
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          const _OnboardingBottomBar(),
        ],
      ),
    );
  }
}

class _OnboardingBottomBar extends GetView<OnboardingController> {
  const _OnboardingBottomBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
          child: Row(
            children: [
              const _DotStepper(),
              const Spacer(),
              Obx(
                () => GlobalButton(
                  onTap: controller.nextPage,
                  text: controller.currentPage.value == 3
                      ? "Get Started"
                      : "Next",
                  color: AppColor.secondary,
                  textColor: Colors.white,
                  width: 200.w,
                ),
              ),
              // _NextButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotStepper extends GetView<OnboardingController> {
  const _DotStepper();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: List.generate(OnboardingController.totalPages, (index) {
          final isActive = controller.currentPage.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(
              right: index < OnboardingController.totalPages - 1 ? 8.w : 0,
            ),
            width: isActive ? 10.w : 8.w,
            height: isActive ? 10.w : 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColor.white
                  : AppColor.white.withValues(alpha: 0.45),
            ),
          );
        }),
      ),
    );
  }
}

class _NextButton extends GetView<OnboardingController> {
  const _NextButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.nextPage,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.secondary.withValues(alpha: 0.35),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: AppText(
            'Next',
            style: context.titleMedium.copyWith(
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
