import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/create_new_trip_controller.dart';
import '../widgets/trip_details_step.dart';
import '../widgets/trip_privacy_step.dart';
import '../widgets/trip_step_progress.dart';
import '../widgets/travel_tracker_step.dart';

class CreateNewTripView extends GetView<CreateNewTripController> {
  const CreateNewTripView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(
        title: controller.isEditing ? 'Edit Trip' : 'Planning New Trip',
        showBackButton: true,
        onBackTap: controller.onBack,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const TripStepProgress(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Obx(() {
                final step = controller.currentStep.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(context, step),
                    32.height,
                    _buildStepContent(step),
                  ],
                );
              }),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const TripDetailsStep();
      case 1:
        return const TravelTrackerStep();
      default:
        return const TripPrivacyStep();
    }
  }

  Widget _buildTitle(BuildContext context, int step) {
    final base = context.headlineLarge.copyWith(fontWeight: FontWeight.w700);
    final dark = base.copyWith(color: const Color(0xFF2D2D2D));
    final teal = base.copyWith(color: AppColor.secondary);

    final TextSpan span = step == 0
        ? TextSpan(
            text: 'Where',
            style: teal,
            children: [TextSpan(text: ' are we headed!', style: dark)],
          )
        : TextSpan(
            text: 'Capture your route\n',
            style: dark,
            children: [TextSpan(text: 'automatically!', style: teal)],
          );

    return Text.rich(span, textAlign: TextAlign.center);
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Obx(
        () => GlobalButton(
          text: controller.isEditing && controller.isLastStep
              ? 'Save Changes'
              : 'Continue',
          color: AppColor.primary,
          onTap: controller.onContinue,
          widget: controller.isSubmitting.value
              ? GlobalLoading(size: 24.sp, color: AppColor.white)
              : null,
        ),
      ),
    );
  }
}
