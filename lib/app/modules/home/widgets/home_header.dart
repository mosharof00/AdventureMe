import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/shimmer_loading.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/home_controller.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
              child: Image.asset(
                Assets.images.homeBgImage.path,
                height: 300.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.find<MainPageController>().openDrawer(),
                      child: AppSvgIcon(
                        Assets.icons.menuIcon,
                        size: 24.sp,
                        color: AppColor.primary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.onProfileTap,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.white, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Obx(
                            () => controller.isUserLoading.value &&
                                    controller.user.value == null
                                ? ShimmerBox(height: 36.w, width: 36.w)
                                : CachedImage(
                                    imgUrl: controller.avatarUrl,
                                    height: 36.w,
                                    width: 36.w,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100.h,
              left: 14.w,
              right: 190.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    Assets.images.adventuresmeSignature.path,
                    height: 25.h,
                    fit: BoxFit.contain,
                  ),
                  12.height,
                  AppText(
                    'The World is Waiting for Your next story.',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                      height: 1.25,
                    ),
                  ),
                  8.height,
                  AppText(
                    'Every adventure you live becomes a story worth remembering.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.primary.withValues(alpha: 1),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
