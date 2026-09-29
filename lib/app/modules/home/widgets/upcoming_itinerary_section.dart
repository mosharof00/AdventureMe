import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/home_controller.dart';
import 'home_section_header.dart';

class UpcomingItinerarySection extends GetView<HomeController> {
  const UpcomingItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeader(
          title: 'Upcoming Itinerary',
          showViewAll: true,
          onViewAll: controller.onViewAll,
        ),
        12.height,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColor.bgGradient2.withAlpha(200),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      controller.upcomingTitle,
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6C8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      controller.upcomingStatus,
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFF8B6914),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              12.height,
              Row(
                children: [
                  AppSvgIcon(
                    Assets.icons.locationIcon,
                    size: 14.sp,
                    color: AppColor.hintText,
                  ),
                  6.width,
                  Expanded(
                    child: AppText(
                      controller.upcomingRoute,
                      style: context.bodySmall.copyWith(
                        color: AppColor.hintText,
                      ),
                    ),
                  ),
                ],
              ),
              8.height,
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: AppColor.hintText,
                  ),
                  6.width,
                  AppText(
                    controller.upcomingDates,
                    style: context.bodySmall.copyWith(color: AppColor.hintText),
                  ),
                ],
              ),
              12.height,
              GestureDetector(
                onTap: controller.onViewDetails,
                child: AppText(
                  'View Details →',
                  style: context.bodySmall.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
