import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/archive_controller.dart';
import '../widgets/archive_story_card.dart';

class ArchiveView extends GetView<ArchiveController> {
  const ArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ArchiveTopBar(),
              18.height,
              _buildTitle(context),
              20.height,
              const _SearchBar(),
              // 18.height,
              // const ArchiveSortTabs(),
              20.height,
              ...List.generate(
                controller.stories.length,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: ArchiveStoryCard(story: controller.stories[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final base = context.headlineLarge.copyWith(fontWeight: FontWeight.w600);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text.rich(
          TextSpan(
            text: 'Get inspired for your \nnext ',
            style: base.copyWith(color: const Color(0xFF2D2D2D)),
            children: [
              TextSpan(
                text: 'adventure!',
                style: base.copyWith(color: AppColor.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ArchiveTopBar extends StatelessWidget {
  const _ArchiveTopBar();

  @override
  Widget build(BuildContext context) {
    final archiveController = Get.find<ArchiveController>();
    return Padding(
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
            onTap: archiveController.onNotifications,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppSvgIcon(
                  Assets.icons.notificationFillIcon,
                  color: Colors.black,
                  size: 24.sp,
                ),
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
        ],
      ),
    );
  }
}

class _SearchBar extends GetView<ArchiveController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppInputTextFormField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        hintText: 'Search Itinerary',
        borderRadius: 30,
        enabledBorderColor: AppColor.hintText.withValues(alpha: 0.2),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: AppSvgIcon(Assets.icons.searchIcon, color: AppColor.hintText),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: AppSvgIcon(Assets.icons.filterIcon, color: AppColor.hintText),
        ),
      ),
    );
  }
}
