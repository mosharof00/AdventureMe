import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/itinerary_controller.dart';

class ItineraryTabs extends GetView<ItineraryController> {
  const ItineraryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _TabChip(
              label: 'All',
              isActive: controller.selectedTab.value == ItineraryTab.all,
              onTap: () => controller.changeTab(ItineraryTab.all),
            ),
            8.horizontalSpace,
            _TabChip(
              label: 'Pending',
              isActive: controller.selectedTab.value == ItineraryTab.pending,
              onTap: () => controller.changeTab(ItineraryTab.pending),
            ),
            8.horizontalSpace,
            _TabChip(
              label: 'Ongoing',
              isActive: controller.selectedTab.value == ItineraryTab.ongoing,
              onTap: () => controller.changeTab(ItineraryTab.ongoing),
            ),
            8.horizontalSpace,
            _TabChip(
              label: 'Completed',
              isActive: controller.selectedTab.value == ItineraryTab.completed,
              onTap: () => controller.changeTab(ItineraryTab.completed),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : AppColor.white,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isActive
                  ? AppColor.primary
                  : AppColor.hintText.withValues(alpha: 0.2),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppText(
              label,
              style: context.bodySmall.copyWith(
                color: isActive ? AppColor.white : AppColor.hintText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
