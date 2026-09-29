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

class OnThisDaySection extends GetView<HomeController> {
  const OnThisDaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: 'On This Day'),
        12.height,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColor.bgGradient2.withAlpha(10),
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImage(
                imgUrl: controller.onThisDayImage,
                width: 88.w,
                height: 88.w,
                borderRadius: 12.r,
                fit: BoxFit.cover,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12.sp,
                          color: AppColor.hintText,
                        ),
                        4.width,
                        AppText(
                          controller.onThisDayDate,
                          style: context.labelSmall.copyWith(
                            color: AppColor.hintText,
                          ),
                        ),
                      ],
                    ),
                    6.height,
                    AppText(
                      controller.onThisDayTitle,
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),
                    4.height,
                    AppText(
                      controller.onThisDayDesc,
                      style: context.bodySmall.copyWith(
                        color: AppColor.hintText,
                      ),
                      maxLines: 1,
                    ),
                    8.height,
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
          ),
        ),
      ],
    );
  }
}
