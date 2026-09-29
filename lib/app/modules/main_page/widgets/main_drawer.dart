import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/modules/home/controllers/home_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/main_page_controller.dart';

class MainDrawer extends GetView<MainPageController> {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DrawerHeader(),
              32.height,
              Obx(
                () => Column(
                  children: [
                    _DrawerItem(
                      title: 'Saved Itineraries',
                      isSelected: controller.drawerSelectedIndex.value == 0,
                      onTap: () => controller.onDrawerItemTap(0),
                    ),
                    8.height,
                    _DrawerItem(
                      title: 'Setting',
                      isSelected: controller.drawerSelectedIndex.value == 1,
                      onTap: () => controller.onDrawerItemTap(1),
                    ),
                    8.height,
                    _DrawerItem(
                      title: 'Privacy & Policy',
                      isSelected: controller.drawerSelectedIndex.value == 2,
                      onTap: () => controller.onDrawerItemTap(2),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends GetView<HomeController> {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Stack(
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
                      width: 72.w,
                      height: 72.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -10.w,
                bottom: -5.w,
                child: Obx(
                  () => controller.user.value?.emailVerified == true
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
        ),
        14.height,
        Obx(
          () => AppText(
            controller.user.value?.name ?? '',
            style: context.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColor.primaryDisable : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: AppColor.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primaryDisable,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: () {
          Get.back();
          HelperUtils.confirmLogout();
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  'Logout',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Icon(Icons.logout_rounded, size: 20.sp, color: AppColor.error),
            ],
          ),
        ),
      ),
    );
  }
}
