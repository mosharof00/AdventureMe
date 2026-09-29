import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class LastTripCard extends GetView<ProfileController> {
  const LastTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Time Since Your Last Trip',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          4.height,
          AppText(
            "We can't wait for your next adventure",
            style: context.bodySmall.copyWith(color: AppColor.hintText),
          ),
          14.height,
          Row(
            children: [
              _TimeBox(label: 'Year', value: controller.yearsSinceTrip),
              10.width,
              _TimeBox(label: 'Month', value: controller.monthsSinceTrip),
              10.width,
              _TimeBox(label: 'Days', value: controller.daysSinceTrip),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F1EC),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            AppSvgIcon(Assets.icons.clockIcon, color: Colors.grey),
            4.height,
            AppText(
              label,
              style: context.labelSmall.copyWith(color: AppColor.hintText),
            ),
            2.height,
            AppText(
              value,
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
