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

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.secondary, width: 2.5),
                ),
                child: ClipOval(
                  child: Obx(
                    () => CachedImage(
                      imgUrl: controller.avatarUrl,
                      width: 55.w,
                      height: 55.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -18.w,
                bottom: -8.w,
                child: Obx(
                  () => controller.isVerified
                      ? AppSvgIcon(
                          Assets.icons.verifiedBadgeIcon,
                          height: 40.w,
                          width: 40.w,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => AppText(
                          controller.userName.value,
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    6.width,
                    GestureDetector(
                      onTap: controller.onEditProfile,
                      child: AppSvgIcon(Assets.icons.editIcon,
                      )
                    ),
                  ],
                ),
                6.height,
                Row(
                  children: [
                    AppSvgIcon(Assets.icons.flashIcon, color: AppColor.primary,
                    width: 14.w,
                      height: 14.w,
                    ),
                    2.width,
                    AppText(
                      'Adventure Streak ${controller.adventureStreak}',
                      style: context.bodySmall.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
                    8.width,
                    Container(
                      width: 1,
                      height: 12.h,
                      color: AppColor.hintText.withValues(alpha: 0.4),
                    ),
                    8.width,
                    Obx(
                      () => AppText(
                        'Joined ${controller.joinedYear}',
                        style: context.bodySmall.copyWith(
                          color: AppColor.hintText,
                        ),
                      ),
                    ),
                  ],
                ),
                8.height,
                Obx(
                  () => AppText(
                    controller.bio.value,
                    style: context.bodySmall.copyWith(
                      color: AppColor.hintText,
                      height: 1.35,
                    ),
                    maxLines: 2,
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
