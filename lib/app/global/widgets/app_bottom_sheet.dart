import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.sticker,
    required this.title,
    required this.description,
    required this.actionWidget,
    this.stickerWidth,
    this.stickerHeight,
  });

  /// Asset path for the sticker / illustration (png).
  final String sticker;
  final String title;
  final String description;

  /// Typically a [GlobalButton] or any custom action widget.
  final Widget actionWidget;

  final double? stickerWidth;
  final double? stickerHeight;

  static Future<T?> show<T>({
    required String sticker,
    required String title,
    required String description,
    required Widget actionWidget,
    double? stickerWidth,
    double? stickerHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      AppBottomSheet(
        sticker: sticker,
        title: title,
        description: description,
        actionWidget: actionWidget,
        stickerWidth: stickerWidth,
        stickerHeight: stickerHeight,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: 12.w, right: 12.w),
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.all(Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              sticker,
              width: stickerWidth ?? 110.w,
              height: stickerHeight ?? 110.w,
              fit: BoxFit.contain,
            ),
            18.height,
            AppText(
              title,
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            10.height,
            AppText(
              description,
              style: context.bodyMedium.copyWith(
                color: AppColor.hintText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            20.height,
            actionWidget,
          ],
        ),
      ),
    );
  }
}
