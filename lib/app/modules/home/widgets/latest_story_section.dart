import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';

import '../controllers/home_controller.dart';
import 'home_section_header.dart';

/// Teal used for story / itinerary highlight cards in the home design.
const Color homeTeal = Color(0xFF2AB8C4);

class LatestStorySection extends GetView<HomeController> {
  const LatestStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeader(
          title: 'Your Latest Story',
          showViewAll: true,
          onViewAll: controller.onViewAll,
        ),
        12.height,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: 160.h,
          decoration: BoxDecoration(
            color: homeTeal,
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(
                      imgUrl: controller.latestStoryImage,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: homeTeal,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: AppText(
                          controller.latestStoryStatus,
                          style: context.labelSmall.copyWith(
                            color: AppColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        controller.latestStoryTitle,
                        style: context.titleSmall.copyWith(
                          color: AppColor.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                      ),
                      6.height,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11.sp,
                            color: AppColor.white.withValues(alpha: 0.9),
                          ),
                          3.width,
                          Flexible(
                            child: AppText(
                              controller.latestStoryDate,
                              style: context.labelSmall.copyWith(
                                color: AppColor.white.withValues(alpha: 0.9),
                                fontSize: 10.sp,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          6.width,
                          Icon(
                            Icons.access_time_rounded,
                            size: 11.sp,
                            color: AppColor.white.withValues(alpha: 0.9),
                          ),
                          3.width,
                          AppText(
                            controller.latestStoryReadTime,
                            style: context.labelSmall.copyWith(
                              color: AppColor.white.withValues(alpha: 0.9),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                      6.height,
                      Expanded(
                        child: AppText(
                          controller.latestStoryDesc,
                          style: context.labelSmall.copyWith(
                            color: AppColor.white.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                          maxLines: 3,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.onOpenStory,
                        child: AppText(
                          'Open Story →',
                          style: context.bodySmall.copyWith(
                            color: AppColor.white,
                            fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
