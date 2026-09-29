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
import 'latest_story_section.dart';

class CurrentItinerarySection extends GetView<HomeController> {
  const CurrentItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: 'Current Itinerary'),
        12.height,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: homeTeal,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      controller.currentItineraryTitle,
                      style: context.titleMedium.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.height,
                    AppText(
                      controller.currentItineraryDesc,
                      style: context.bodySmall.copyWith(
                        color: AppColor.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                      maxLines: 3,
                    ),
                    10.height,
                    GestureDetector(
                      onTap: controller.onViewDetails,
                      child: AppText(
                        'View Details →',
                        style: context.bodySmall.copyWith(
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              12.width,
              CachedImage(
                imgUrl: controller.currentItineraryMapImage,
                width: 90.w,
                height: 90.w,
                borderRadius: 12.r,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
