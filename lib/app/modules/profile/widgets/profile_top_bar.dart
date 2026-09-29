import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class ProfileTopBar extends GetView<ProfileController> {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.find<MainPageController>().openDrawer(),
            child: AppSvgIcon(
              Assets.icons.menuIcon,
              size: 24.sp,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: controller.onNotifications,
            child: Obx(
              () => Stack(
                clipBehavior: Clip.none,
                children: [
                  AppSvgIcon(
                    Assets.icons.notificationFillIcon,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                  if (controller.hasNotification.value)
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
    );
  }
}
