import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/day_photos_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../widgets/upload_summary_sheet.dart';

/// Opened with `{'tripId': String, 'day': int, 'date': String}`.
///
/// Picked photos stay local until "Save as Draft" uploads them as drafts;
/// "Continue" then finalizes every draft of the day.
class ManageDayPhotosController extends GetxController {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();
  final _picker = ImagePicker();

  String tripId = '';
  int dayNumber = 1;
  String dayDate = '';

  final selected = PhotoCategory.favoriteImage.obs;

  final uploaded = {
    for (final category in PhotoCategory.values) category: <TripPhoto>[].obs,
  };
  final pending = {
    for (final category in PhotoCategory.values) category: <File>[].obs,
  };

  final isLoading = false.obs;
  final hasError = false.obs;
  final isSaving = false.obs;
  final isFinalizing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      tripId = arg['tripId']?.toString() ?? '';
      dayNumber = (arg['day'] as int?) ?? 1;
      dayDate = arg['date']?.toString() ?? '';
    }
    fetchPhotos();
  }

  // ── State ────────────────────────────────────────────
  RxList<TripPhoto> get currentUploaded => uploaded[selected.value]!;
  RxList<File> get currentPending => pending[selected.value]!;

  bool get hasPending => pending.values.any((list) => list.isNotEmpty);

  bool get hasDrafts =>
      uploaded.values.any((list) => list.any((photo) => photo.isDraft));

  int countFor(PhotoCategory category) =>
      uploaded[category]!.length + pending[category]!.length;

  void selectCategory(PhotoCategory category) => selected.value = category;

  // ── Loading ──────────────────────────────────────────
  Future<void> fetchPhotos() async {
    if (tripId.isEmpty || isLoading.value) return;
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await _tripRepository.getDayPhotos(tripId, dayNumber);
      if (response.success != true) {
        hasError.value = true;
        return;
      }
      for (final category in PhotoCategory.values) {
        uploaded[category]!.assignAll(response.categories[category] ?? []);
      }
    } catch (e) {
      hasError.value = true;
      handleException(e, context: 'Day Photos');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Picking ──────────────────────────────────────────
  Future<void> pickImages() async {
    if (isSaving.value || isFinalizing.value) return;
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );
      if (picked.isEmpty) return;
      final known = currentPending.map((f) => f.path).toSet();
      currentPending.addAll(
        picked.where((f) => !known.contains(f.path)).map((f) => File(f.path)),
      );
    } catch (_) {
      globalSnackBar(
        title: 'Oops',
        message: 'Could not open the gallery. Please try again.',
      );
    }
  }

  void removePending(File file) {
    if (!isSaving.value) currentPending.remove(file);
  }

  // ── Delete ───────────────────────────────────────────
  final deletingId = RxnString();

  void onPhotoLongPress(TripPhoto photo) {
    if (photo.id == null || deletingId.value != null) return;
    AppBottomSheet.show(
      sticker: Assets.images.crySticker.path,
      title: 'Delete This Photo?',
      description:
          'It will be removed from this day and from your photo chapter.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Keep',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: () {
                if (deletingId.value == null) Get.back();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => GlobalButton(
                text: 'Delete',
                color: AppColor.error,
                onTap: () => _deletePhoto(photo),
                widget: deletingId.value == photo.id
                    ? GlobalLoading(size: 22.sp, color: AppColor.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(TripPhoto photo) async {
    final photoId = photo.id;
    if (photoId == null || deletingId.value != null) return;
    try {
      deletingId.value = photoId;
      final response = await _tripRepository.deletePhoto(tripId, photoId);
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Deleted',
          message: response.message ?? 'Unable to delete the photo.',
        );
        return;
      }

      for (final list in uploaded.values) {
        list.removeWhere((p) => p.id == photoId);
      }
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      if (Get.isBottomSheetOpen == true) Get.back();
      globalSnackBar(
        title: 'Photo Deleted',
        message: response.message ?? 'Photo removed.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Delete Photo');
    } finally {
      deletingId.value = null;
    }
  }

  // ── Save as Draft ────────────────────────────────────
  Future<void> saveAsDraft() async {
    if (!hasPending || isSaving.value) return;
    try {
      isSaving.value = true;
      var total = 0;
      for (final category in PhotoCategory.values) {
        final files = pending[category]!;
        if (files.isEmpty) continue;

        final response = await _tripRepository.uploadDayPhotos(
          tripId: tripId,
          day: dayNumber,
          category: category,
          files: files.toList(),
        );
        if (response.success != true) {
          globalSnackBar(
            title: 'Upload Failed',
            message: response.message ??
                'Unable to upload ${category.label} photos.',
          );
          return;
        }
        uploaded[category]!.addAll(response.photos);
        total += files.length;
        files.clear();
      }
      globalSnackBar(
        title: 'Saved as Draft',
        message: '$total photo${total == 1 ? '' : 's'} uploaded.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Upload Day Photos');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Finalize ─────────────────────────────────────────
  void onContinue() {
    if (!hasDrafts || hasPending) return;
    UploadSummarySheet.show();
  }

  Future<void> finalize() async {
    if (isFinalizing.value) return;
    try {
      isFinalizing.value = true;
      final response =
          await _tripRepository.finalizeDayPhotos(tripId, dayNumber);
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Finalized',
          message: response.message ?? 'Unable to finalize the photos.',
        );
        return;
      }

      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      if (Get.isBottomSheetOpen == true) Get.back();
      await fetchPhotos();
      _showSuccessSheet(response.message);
    } catch (e) {
      handleException(e, context: 'Finalize Day Photos');
    } finally {
      isFinalizing.value = false;
    }
  }

  void cancelSummary() {
    if (!isFinalizing.value) Get.back();
  }

  void _showSuccessSheet(String? message) {
    AppBottomSheet.show(
      sticker: Assets.images.excitedSticker.path,
      title: 'Yey! Upload Completed',
      description:
          '${message ?? 'Your memory is now available on photo chapter.'} Click continue to view directly.',
      isDismissible: false,
      enableDrag: false,
      actionWidget: GlobalButton(
        text: 'Continue',
        color: AppColor.primary,
        onTap: () {
          Get.back(); // close sheet
          Get.back(result: true); // return to itinerary details
        },
      ),
    );
  }
}
