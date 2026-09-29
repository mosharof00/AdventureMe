import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/itinerary_details_controller.dart';
import 'tracking_day_card.dart';
import 'trip_info_card.dart';
import 'trip_timer_section.dart';

class TimelineTab extends GetView<ItineraryDetailsController> {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TripInfoCard(),
          28.height,
          const TripTimerSection(),
          28.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppText(
              'Tracking Details',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          16.height,
          for (var i = 0; i < controller.days.length; i++) ...[
            TrackingDayCard(
              day: controller.days[i],
              isDone: controller.isDayDone(i),
              onManagePhotos: () => controller.onManageDayPhotos(
                i + 1,
                controller.days[i].date,
              ),
            ),
            if (i != controller.days.length - 1) 16.height,
          ],
          32.height,
          const _ActionButtons(),
        ],
      ),
    );
  }
}

class _ActionButtons extends GetView<ItineraryDetailsController> {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          GlobalButton(text: 'View Map', onTap: controller.onViewMap),
          12.height,
          GlobalButton(
            text: '',
            onTap: controller.onGenerateStory,
            gradient: const LinearGradient(
              colors: [AppColor.secondary, Color(0xFF8A7CFF)],
            ),
            widget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: AppColor.white, size: 18.sp),
                8.width,
                AppText(
                  'Generate Story',
                  style: context.titleSmall.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
