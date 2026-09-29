import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/theme/app_color.dart';

import '../controllers/create_new_trip_controller.dart';

class TripStepProgress extends GetView<CreateNewTripController> {
  const TripStepProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: List.generate(CreateNewTripController.totalSteps, (index) {
          final isActive = index == controller.currentStep.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 5.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColor.secondary
                      : AppColor.hintText.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
