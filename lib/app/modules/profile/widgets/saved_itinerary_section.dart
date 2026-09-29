import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class SavedItinerarySection extends GetView<ProfileController> {
  const SavedItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  'Your Saved Itinerary',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAllItineraries,
                child: AppText(
                  'View All >',
                  style: context.bodySmall.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        12.height,
        SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: controller.savedItineraries.length,
            separatorBuilder: (_, __) => 12.width,
            itemBuilder: (_, index) {
              final item = controller.savedItineraries[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: 220.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImage(
                        imgUrl: item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(12.w, 28.h, 12.w, 12.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                item.title,
                                style: context.titleSmall.copyWith(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                              ),
                              6.height,
                              Row(
                                children: [
                                  AppSvgIcon(
                                    Assets.icons.locationIcon,
                                    size: 12.sp,
                                    color: AppColor.white,
                                  ),
                                  4.width,
                                  Expanded(
                                    child: AppText(
                                      item.location,
                                      style: context.labelSmall.copyWith(
                                        color: AppColor.white,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
