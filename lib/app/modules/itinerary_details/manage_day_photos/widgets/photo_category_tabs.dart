import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/manage_day_photos_controller.dart';

class PhotoCategoryTabs extends GetView<ManageDayPhotosController> {
  const PhotoCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          for (var i = 0; i < controller.categories.length; i++) ...[
            Expanded(
              child: _CategoryCard(
                category: controller.categories[i],
                isActive: controller.selected.value == i,
                onTap: () => controller.selectCategory(i),
              ),
            ),
            if (i != controller.categories.length - 1) 8.horizontalSpace,
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isActive,
    required this.onTap,
  });

  final PhotoCategory category;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColor.white : const Color(0xFFFBEFE0),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? AppColor.secondary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Stack(
          children: [
            if (isActive)
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check,
                  size: 14.sp,
                  color: AppColor.secondary,
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 22.sp, color: AppColor.primary),
                  6.verticalSpace,
                  AppText(
                    category.label,
                    style: context.labelSmall.copyWith(
                      color: const Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
