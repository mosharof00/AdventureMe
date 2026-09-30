import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/manage_day_photos_controller.dart';

class UploadSummarySheet extends GetView<ManageDayPhotosController> {
  const UploadSummarySheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const UploadSummarySheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: 12.w, right: 12.w),
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Upload Summary',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            18.height,
            for (final category in PhotoCategory.values) ...[
              _SummaryRow(
                label: category.label,
                count: controller.countFor(category),
              ),
              14.height,
            ],
            8.height,
            Row(
              children: [
                Expanded(
                  child: GlobalButton(
                    text: 'Cancel',
                    color: AppColor.primaryDisable,
                    textColor: const Color(0xFF2D2D2D),
                    onTap: controller.cancelSummary,
                  ),
                ),
                12.width,
                Expanded(
                  child: Obx(
                    () => GlobalButton(
                      text: 'Done',
                      onTap: controller.finalize,
                      widget: controller.isFinalizing.value
                          ? GlobalLoading(size: 22.sp, color: AppColor.white)
                          : null,
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            label,
            style: context.bodyMedium.copyWith(color: const Color(0xFF2D2D2D)),
          ),
        ),
        AppText(
          '$count Selected',
          style: context.bodySmall.copyWith(
            color: count == 0 ? AppColor.error : AppColor.hintText,
          ),
        ),
      ],
    );
  }
}
