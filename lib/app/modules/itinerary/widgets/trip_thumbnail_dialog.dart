import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_controller.dart';

class TripThumbnailDialog extends GetView<ItineraryController> {
  const TripThumbnailDialog({super.key, required this.trip});

  final TripListItem trip;

  static Future<void> show(TripListItem trip) {
    return Get.dialog(
      TripThumbnailDialog(trip: trip),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.closeThumbnailDialog();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Obx(() {
            final isSaving = controller.isUploadingThumbnail.value;
            final picked = controller.pickedThumbnail.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'Change Thumbnail',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                  textAlign: TextAlign.center,
                ),
                6.height,
                AppText(
                  trip.title ?? 'Untitled Trip',
                  style: context.bodyMedium.copyWith(color: AppColor.hintText),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                16.height,
                GestureDetector(
                  onTap: isSaving
                      ? null
                      : () => controller.pickThumbnail(ImageSource.gallery),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: 170.h,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (picked != null)
                            Image.file(picked, fit: BoxFit.cover)
                          else if (trip.hasCover)
                            CachedImage(
                              imgUrl: trip.coverUrl!,
                              width: double.infinity,
                              height: 170.h,
                              fit: BoxFit.cover,
                            )
                          else
                            Image.asset(
                              Assets.images.itinearyBgImage.path,
                              fit: BoxFit.cover,
                            ),
                          if (picked == null)
                            ColoredBox(
                              color: Colors.black.withValues(alpha: 0.35),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 34.sp,
                                      color: AppColor.white,
                                    ),
                                    6.height,
                                    AppText(
                                      'Tap to choose a photo',
                                      style: context.labelSmall.copyWith(
                                        color: AppColor.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                12.height,
                Row(
                  children: [
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: isSaving
                            ? null
                            : () => controller.pickThumbnail(ImageSource.camera),
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: isSaving
                            ? null
                            : () =>
                                controller.pickThumbnail(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                20.height,
                Row(
                  children: [
                    Expanded(
                      child: GlobalButton(
                        text: 'Cancel',
                        color: const Color(0xFFD6E4F0),
                        textColor: const Color(0xFF2D2D2D),
                        isDisabled: isSaving,
                        onTap: controller.closeThumbnailDialog,
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: GlobalButton(
                        text: 'Save',
                        isDisabled: picked == null && !isSaving,
                        onTap: () => controller.saveThumbnail(trip),
                        widget: isSaving
                            ? Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: AppColor.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppColor.primary),
            6.width,
            AppText(
              label,
              style: context.labelLarge.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
