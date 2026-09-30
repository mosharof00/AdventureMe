import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/manage_day_photos_controller.dart';

class PhotoCategoryTabs extends GetView<ManageDayPhotosController> {
  const PhotoCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = PhotoCategory.values;
    return Obx(
      () => Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            Expanded(
              child: _CategoryCard(
                category: categories[i],
                isActive: controller.selected.value == categories[i],
                onTap: () => controller.selectCategory(categories[i]),
              ),
            ),
            if (i != categories.length - 1) 8.horizontalSpace,
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
        height: 68.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? AppColor.white : const Color(0xFFFBEFE0),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive
                ? AppColor.secondary
                : AppColor.amber.withAlpha(100),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                AppSvgIcon(category.icon, size: 22.sp, color: AppColor.primary),
                if (isActive)
                  Icon(Icons.check, size: 18.sp, color: AppColor.secondary),
              ],
            ),
            6.verticalSpace,
            AppText(
              category.label,
              style: context.labelSmall.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
