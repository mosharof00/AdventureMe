import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_controller.dart';

class ItineraryHeader extends GetView<ItineraryController> {
  const ItineraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
          child: Image.asset(
            Assets.images.itinearyBgImage.path,
            height: 300.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Top bar: menu + notification
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.find<MainPageController>().openDrawer(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: AppSvgIcon(
                      Assets.icons.menuIcon,
                      size: 24.sp,
                      color: AppColor.white,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: controller.onNotifications,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppSvgIcon(
                          Assets.icons.notificationIcon,
                          color: Colors.white,
                        ),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8A3D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Headline
        Positioned(
          top: 90.h,
          left: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Your Journey',
                style: context.headlineLarge.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppText(
                'Stash is Here!',
                style: context.headlineLarge.copyWith(
                  color: AppColor.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Glass stats card overlapping the bottom
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 10.h,
          child: const _StatsCard(),
        ),
      ],
    );
  }
}

class _StatsCard extends GetView<ItineraryController> {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${controller.countriesVisited}',
                      style: context.displayLarge.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    4.height,
                    AppText(
                      'Countries visited out of ${controller.totalCountries}',
                      style: context.bodySmall.copyWith(
                        color: AppColor.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 45.r,
                lineWidth: 10.w,
                percent: controller.worldPercent.clamp(0.0, 1.0),
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppColor.white.withValues(alpha: 0.35),
                progressColor: AppColor.secondary,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      '${controller.worldPercentLabel}%',
                      style: context.titleMedium.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppText(
                      'WORLD',
                      style: context.labelSmall.copyWith(
                        color: AppColor.white.withValues(alpha: 0.8),
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
