import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/saved_itineraries_controller.dart';

class SavedItinerariesView extends GetView<SavedItinerariesController> {
  const SavedItinerariesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Saved Itineraries',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          const _SortFilterRow(),
          18.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(
              () => AppText(
                'All Saved Itineraries (${controller.filteredItems.length})',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),
          14.height,
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                itemCount: controller.filteredItems.length,
                separatorBuilder: (_, __) => 12.height,
                itemBuilder: (_, index) {
                  final item = controller.filteredItems[index];
                  return SavedItineraryCard(item: item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortFilterRow extends GetView<SavedItinerariesController> {
  const _SortFilterRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _SortChip(
              label: 'All',
              isActive: controller.selectedSort.value == SavedSort.all,
              onTap: () => controller.changeSort(SavedSort.all),
            ),
            8.width,
            _SortChip(
              label: 'Oldest',
              isActive: controller.selectedSort.value == SavedSort.oldest,
              onTap: () => controller.changeSort(SavedSort.oldest),
            ),
            8.width,
            _SortChip(
              label: 'Newest',
              isActive: controller.selectedSort.value == SavedSort.newest,
              onTap: () => controller.changeSort(SavedSort.newest),
            ),
            const Spacer(),
            GestureDetector(
              onTap: controller.onFilterTap,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                  color: AppColor.white,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: AppColor.hintText,
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : const Color(0xFFE8EEF5),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: AppText(
          label,
          style: context.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColor.white : const Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }
}

class SavedItineraryCard extends GetView<SavedItinerariesController> {
  const SavedItineraryCard({super.key, required this.item});

  final SavedItineraryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedImage(
              imgUrl: item.imageUrl,
              width: 78.w,
              height: 78.w,
              fit: BoxFit.cover,
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        item.title,
                        style: context.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    4.width,
                    GestureDetector(
                      onTap: () => controller.onShare(item),
                      child: Icon(
                        Icons.ios_share_rounded,
                        size: 18.sp,
                        color: AppColor.hintText,
                      ),
                    ),
                    8.width,
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.toggleBookmark(item.id),
                        child: Icon(
                          controller.isBookmarked(item.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20.sp,
                          color: controller.isBookmarked(item.id)
                              ? AppColor.error
                              : AppColor.hintText,
                        ),
                      ),
                    ),
                  ],
                ),
                8.height,
                _MetaRow(icon: Assets.icons.locationIcon, text: item.starting),
                4.height,
                _MetaRow(icon: Assets.icons.locationIcon, text: item.destined),
                4.height,
                _MetaRow(icon: Assets.icons.calendarIcon, text: item.dateRange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSvgIcon(icon, size: 12.sp, color: AppColor.hintText),
        6.width,
        Expanded(
          child: AppText(
            text,
            style: context.labelSmall.copyWith(color: AppColor.hintText),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
