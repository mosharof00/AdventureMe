import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/archive_controller.dart';

class ArchiveSortTabs extends GetView<ArchiveController> {
  const ArchiveSortTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _SortChip(
              label: 'Recent',
              isActive: controller.selectedFilter.value == 'recent',
              onTap: () => controller.applyFilters(
                filter: 'recent',
                status: controller.selectedStatus.value,
                hasStory: controller.selectedHasStory.value,
              ),
            ),
            10.horizontalSpace,
            _SortChip(
              label: 'All',
              isActive: controller.selectedFilter.value == 'all',
              onTap: () => controller.applyFilters(
                filter: 'all',
                status: controller.selectedStatus.value,
                hasStory: controller.selectedHasStory.value,
              ),
            ),
            10.horizontalSpace,
            _SortChip(
              label: 'Completed',
              isActive: controller.selectedFilter.value == 'completed',
              onTap: () => controller.applyFilters(
                filter: 'completed',
                status: controller.selectedStatus.value,
                hasStory: controller.selectedHasStory.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
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
            color: isActive ? AppColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: AppText(
            label,
            style: context.bodyMedium.copyWith(
              color: isActive ? AppColor.white : AppColor.hintText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
