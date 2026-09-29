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

import '../controllers/home_controller.dart';
import 'home_section_header.dart';

class CountryExploredSection extends GetView<HomeController> {
  const CountryExploredSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeader(
          title: 'Country Explored',
          showViewAll: true,
          onViewAll: controller.onViewAll,
        ),
        12.height,
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: controller.countries.length,
            separatorBuilder: (_, __) => 12.width,
            itemBuilder: (_, index) {
              final item = controller.countries[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: 160.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImage(imgUrl: item.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10.w, 28.h, 10.w, 12.h),
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
                                  fontSize: 13.sp,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                              ),
                              6.height,
                              Row(
                                children: [
                                  AppSvgIcon(
                                    Assets.icons.locationIcon,
                                    size: 11.sp,
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
