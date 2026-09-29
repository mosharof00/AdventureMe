import 'package:flutter/material.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/global/widgets/custom_svg_image.dart';

import '../../../../gen/assets.gen.dart';
import '../controllers/main_page_controller.dart';
import '../widgets/main_drawer.dart';

class MainPageView extends GetView<MainPageController> {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.onBackPressed();
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: AppColor.background,
        drawer: const MainDrawer(),
        body: Obx(() => controller.pages[controller.selectedIndex.value]),
        bottomNavigationBar: const _BottomNav(),
      ),
    );
  }
}

class _BottomNav extends GetView<MainPageController> {
  const _BottomNav();

  static final _tabs = [
    _NavTab(
      outlineIcon: Assets.icons.homeIcon,
      fillIcon: Assets.icons.homeFillIcon,
      label: 'Home',
    ),
    _NavTab(
      outlineIcon: Assets.icons.itineraryIcon,
      fillIcon: Assets.icons.itineraryFillIcon,
      label: 'Itinerary',
    ),
    _NavTab(
      outlineIcon: Assets.icons.blockIcon,
      fillIcon: Assets.icons.blockFillIcon,
      label: 'Archive',
    ),
    _NavTab(
      outlineIcon: Assets.icons.userIcon,
      fillIcon: Assets.icons.userFillIcon,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Obx(
            () => GNav(
              selectedIndex: controller.selectedIndex.value,
              onTabChange: controller.changePage,
              backgroundColor: Colors.white,
              activeColor: Colors.white,
              color: AppColor.hintText,
              tabBackgroundColor: AppColor.primary,
              gap: 6.w,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              duration: const Duration(milliseconds: 300),
              tabs: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = controller.selectedIndex.value == index;
                return GButton(
                  icon: Icons.circle,
                  leading: customSvgImage(
                    imagePath: isActive ? tab.fillIcon : tab.outlineIcon,
                    color: isActive ? Colors.white : AppColor.hintText,
                    width: 20.w,
                    height: 20.w,
                  ),
                  text: tab.label,
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final String outlineIcon;
  final String fillIcon;
  final String label;

  const _NavTab({
    required this.outlineIcon,
    required this.fillIcon,
    required this.label,
  });
}
