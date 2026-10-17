import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/archive_controller.dart';

class FeedFilterBottomSheet extends StatelessWidget {
  const FeedFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FeedFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArchiveController>();

    final tempFilter = controller.selectedFilter.value.obs;
    final tempStatus = controller.selectedStatus.value.obs;
    final tempHasStory = controller.selectedHasStory.value.obs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            12.height,

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'Filters',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18.sp, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            16.height,

            // Filter mode
            AppText(
              'Sort Mode',
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            8.height,
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _FilterChip(
                    label: 'Recent',
                    isSelected: tempFilter.value == 'recent',
                    onTap: () => tempFilter.value = 'recent',
                  ),
                  _FilterChip(
                    label: 'All',
                    isSelected: tempFilter.value == 'all',
                    onTap: () => tempFilter.value = 'all',
                  ),
                  _FilterChip(
                    label: 'Completed',
                    isSelected: tempFilter.value == 'completed',
                    onTap: () => tempFilter.value = 'completed',
                  ),
                ],
              ),
            ),
            16.height,

            // Trip Status
            AppText(
              'Trip Status',
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            8.height,
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: tempStatus.value == null,
                    onTap: () => tempStatus.value = null,
                  ),
                  _FilterChip(
                    label: 'Completed',
                    isSelected: tempStatus.value == 'COMPLETED',
                    onTap: () => tempStatus.value = 'COMPLETED',
                  ),
                  _FilterChip(
                    label: 'Active',
                    isSelected: tempStatus.value == 'ACTIVE',
                    onTap: () => tempStatus.value = 'ACTIVE',
                  ),
                  _FilterChip(
                    label: 'Pending',
                    isSelected: tempStatus.value == 'PENDING',
                    onTap: () => tempStatus.value = 'PENDING',
                  ),
                ],
              ),
            ),
            16.height,

            // AI Generated Story
            AppText(
              'Story Attached',
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            8.height,
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: tempHasStory.value == null,
                    onTap: () => tempHasStory.value = null,
                  ),
                  _FilterChip(
                    label: 'Has Story',
                    isSelected: tempHasStory.value == true,
                    onTap: () => tempHasStory.value = true,
                  ),
                  _FilterChip(
                    label: 'No Story',
                    isSelected: tempHasStory.value == false,
                    onTap: () => tempHasStory.value = false,
                  ),
                ],
              ),
            ),
            24.height,

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      tempFilter.value = 'recent';
                      tempStatus.value = null;
                      tempHasStory.value = null;
                      controller.resetFilters();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: AppText(
                      'Reset',
                      style: context.titleSmall.copyWith(
                        color: AppColor.hintText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: GlobalButton(
                    text: 'Apply',
                    height: 48.h,
                    onTap: () {
                      controller.applyFilters(
                        filter: tempFilter.value,
                        status: tempStatus.value,
                        hasStory: tempHasStory.value,
                      );
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.grey.shade300,
          ),
        ),
        child: AppText(
          label,
          style: context.labelSmall.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
