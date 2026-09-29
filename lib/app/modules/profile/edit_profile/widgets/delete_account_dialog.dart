import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({
    super.key,
    required this.onCancel,
    required this.onDelete,
  });

  final VoidCallback onCancel;
  final VoidCallback onDelete;

  static Future<void> show({
    required VoidCallback onCancel,
    required VoidCallback onDelete,
  }) {
    return Get.dialog(
      DeleteAccountDialog(onCancel: onCancel, onDelete: onDelete),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.images.crySticker.path,
              width: 110.w,
              height: 110.w,
              fit: BoxFit.contain,
            ),
            18.height,
            AppText(
              'Are You Sure You Want to Delete Account?',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            10.height,
            AppText(
              'Deleting your account will lose all the data from the beginning to the end.',
              style: context.bodyMedium.copyWith(
                color: AppColor.hintText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
            22.height,
            Row(
              children: [
                Expanded(
                  child: GlobalButton(
                    text: 'Cancel',
                    color: const Color(0xFFD6E4F0),
                    textColor: const Color(0xFF2D2D2D),
                    onTap: onCancel,
                  ),
                ),
                12.width,
                Expanded(
                  child: GlobalButton(
                    text: 'Delete',
                    color: AppColor.error,
                    onTap: onDelete,
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
