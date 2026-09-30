import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/manage_day_photos_controller.dart';
import '../widgets/photo_category_tabs.dart';
import '../widgets/photo_grid.dart';

class ManageDayPhotosView extends GetView<ManageDayPhotosController> {
  const ManageDayPhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Upload Image',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _NoteCard(),
                  22.height,
                  _dayHeader(context),
                  10.height,
                  _dottedDivider(),
                  20.height,
                  _categoryLabel(context),
                  14.height,
                  const PhotoCategoryTabs(),
                  20.height,
                  const PhotoGrid(),
                ],
              ),
            ),
          ),
          const _BottomBar(),
        ],
      ),
    );
  }

  Widget _dayHeader(BuildContext context) {
    return Row(
      children: [
        AppText(
          'Day ${controller.dayNumber}',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const Spacer(),
        AppText(
          controller.dayDate,
          style: context.bodySmall.copyWith(color: AppColor.hintText),
        ),
      ],
    );
  }

  Widget _dottedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              color: AppColor.hintText.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }

  Widget _categoryLabel(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Choose Category ',
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D2D2D),
        ),
        children: [
          TextSpan(
            text: '*',
            style: context.titleMedium.copyWith(color: AppColor.error),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFE0),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText(
                'Note',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6A96B),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline, size: 14.sp, color: AppColor.white),
              ),
            ],
          ),
          10.height,
          AppText(
            'Your Uploaded Images and information will also be visible on Photo Chapter!',
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              height: 1.4,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends GetView<ManageDayPhotosController> {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Obx(() {
          if (controller.hasPending) {
            return GlobalButton(
              text: 'Save as Draft',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: controller.saveAsDraft,
              widget: controller.isSaving.value
                  ? GlobalLoading(size: 22.sp, color: AppColor.primary)
                  : null,
            );
          }
          return GlobalButton(
            text: 'Continue',
            isDisabled: !controller.hasDrafts,
            onTap: controller.onContinue,
          );
        }),
      ),
    );
  }
}
