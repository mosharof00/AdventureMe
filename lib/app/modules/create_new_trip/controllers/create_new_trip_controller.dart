import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/gen/assets.gen.dart';

/// Pops with the created [TripData] as the route result so the opener can
/// refresh its list.
class CreateNewTripController extends GetxController {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  static const int totalSteps = 3;

  final currentStep = 0.obs;
  final isSubmitting = false.obs;

  // ── Step 1: Trip details ─────────────────────────────
  final detailsFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final startingPlaceController = TextEditingController();
  final destinedPlaceController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  // ── Step 2 & 3: Preferences ──────────────────────────
  final travelTracker = false.obs;
  final anyoneCanSee = false.obs;
  final anyoneCanShare = false.obs;

  TripData? _createdTrip;

  /// Date fields are read-only, so they don't revalidate on their own; once
  /// the user has tried to continue, picking a date refreshes the errors.
  bool _detailsValidated = false;

  void _revalidateDates() {
    if (_detailsValidated) detailsFormKey.currentState?.validate();
  }

  double get progress => (currentStep.value + 1) / totalSteps;

  bool get isLastStep => currentStep.value == totalSteps - 1;

  final _dateFormat = DateFormat('MM/dd/yyyy');

  // ── Validators ───────────────────────────────────────
  String? validateTitle(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Trip title is required' : null;

  String? validateStartingPlace(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Starting place is required' : null;

  String? validateDestinedPlace(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Destined place is required' : null;

  String? validateStartDate(String? _) =>
      startDate.value == null ? 'Select a start date' : null;

  String? validateEndDate(String? _) {
    final start = startDate.value;
    final end = endDate.value;
    if (end == null) return 'Select an end date';
    if (start != null && end.isBefore(start)) return 'Must be after start';
    return null;
  }

  // ── Date pickers ─────────────────────────────────────
  Future<void> pickStartDate(BuildContext context) async {
    final picked = await _showPicker(context, startDate.value);
    if (picked == null) return;
    startDate.value = picked;
    startDateController.text = _dateFormat.format(picked);

    final end = endDate.value;
    if (end != null && end.isBefore(picked)) {
      endDate.value = null;
      endDateController.clear();
    }
    _revalidateDates();
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await _showPicker(
      context,
      endDate.value ?? startDate.value,
      firstDate: startDate.value,
    );
    if (picked != null) {
      endDate.value = picked;
      endDateController.text = _dateFormat.format(picked);
      _revalidateDates();
    }
  }

  Future<DateTime?> _showPicker(
    BuildContext context,
    DateTime? initial, {
    DateTime? firstDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? firstDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
  }

  void toggleTravelTracker(bool value) => travelTracker.value = value;
  void toggleAnyoneCanSee(bool value) => anyoneCanSee.value = value;
  void toggleAnyoneCanShare(bool value) => anyoneCanShare.value = value;

  // ── Navigation ───────────────────────────────────────
  void onBack() {
    if (isSubmitting.value) return;
    if (currentStep.value == 0) {
      Get.back();
    } else {
      currentStep.value--;
    }
  }

  void onContinue() {
    if (isSubmitting.value) return;
    if (currentStep.value == 0) {
      _detailsValidated = true;
      if (!(detailsFormKey.currentState?.validate() ?? false)) return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLastStep) {
      _createTrip();
    } else {
      currentStep.value++;
    }
  }

  Future<void> _createTrip() async {
    try {
      isSubmitting.value = true;
      final response = await _tripRepository.createTrip(
        title: titleController.text.trim(),
        startingPlace: startingPlaceController.text.trim(),
        destinedPlace: destinedPlaceController.text.trim(),
        startingDate: startDate.value!,
        endingDate: endDate.value!,
        travelTrackerEnabled: travelTracker.value,
        isPublic: anyoneCanSee.value,
        canShare: anyoneCanShare.value,
      );

      if (response.success != true || response.data == null) {
        globalSnackBar(
          title: 'Trip Not Created',
          message: response.message ?? 'Unable to create trip. Please try again.',
        );
        return;
      }

      _createdTrip = response.data;
      _showSuccessSheet(response.message);
    } catch (e) {
      handleException(e, context: 'Create Trip');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// The trip already exists, so closing the sheet in any way (button or
  /// system back) leaves the flow; staying could create a duplicate.
  Future<void> _showSuccessSheet(String? message) async {
    await AppBottomSheet.show(
      sticker: Assets.images.decisionSticker.path,
      title: "Done! It's Ready now!",
      description: message ??
          'Your trip plan is ready. You can start tracking whenever you want!',
      isDismissible: false,
      enableDrag: false,
      actionWidget: GlobalButton(
        text: 'View Trip',
        color: AppColor.primary,
        onTap: () => Get.back(),
      ),
    );
    Get.back(result: _createdTrip);
  }

  @override
  void onClose() {
    titleController.dispose();
    startingPlaceController.dispose();
    destinedPlaceController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
