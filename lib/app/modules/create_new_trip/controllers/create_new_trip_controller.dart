import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

/// Pops with the created [TripData] as the route result so the opener can
/// refresh its list. Opened with a [TripData] argument it edits that trip
/// instead and pops with the update's [TripResponse]; the opener shows the
/// success message after its own navigation.
class CreateNewTripController extends GetxController {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  TripData? editingTrip;
  bool get isEditing => editingTrip != null;

  static const int totalSteps = 3;

  final currentStep = 0.obs;
  final isSubmitting = false.obs;

  // ── Step 1: Trip details ─────────────────────────────
  final detailsFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final startingPlaceController = TextEditingController();
  final startingCountryController = TextEditingController();
  final destinedPlaceController = TextEditingController();
  final destinedCountryController = TextEditingController();
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

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is TripData) _prefill(arg);
  }

  void _prefill(TripData trip) {
    editingTrip = trip;
    titleController.text = trip.title ?? '';
    startingPlaceController.text = trip.startingPlace ?? '';
    startingCountryController.text = trip.startingCountry ?? '';
    destinedPlaceController.text = trip.destinedPlace ?? '';
    destinedCountryController.text = trip.destinedCountry ?? '';
    final start = _dateOnly(trip.startingDate);
    final end = _dateOnly(trip.endingDate);
    if (start != null) {
      startDate.value = start;
      startDateController.text = _dateFormat.format(start);
    }
    if (end != null) {
      endDate.value = end;
      endDateController.text = _dateFormat.format(end);
    }
    travelTracker.value = trip.travelTrackerEnabled;
    anyoneCanSee.value = trip.isPublic;
    anyoneCanShare.value = trip.canShare;
  }

  /// API dates are day-only values sent as UTC midnight.
  DateTime? _dateOnly(DateTime? date) =>
      date == null ? null : DateTime(date.year, date.month, date.day);

  // ── Validators ───────────────────────────────────────
  String? validateTitle(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Trip title is required' : null;

  String? validateStartingPlace(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Starting place is required' : null;

  String? validateStartingCountry(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Starting country is required' : null;

  String? validateDestinedPlace(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Destined place is required' : null;

  String? validateDestinedCountry(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Destined country is required' : null;

  String? validateStartDate(String? _) =>
      startDate.value == null ? 'Select a start date' : null;

  String? validateEndDate(String? _) {
    final start = startDate.value;
    final end = endDate.value;
    if (end == null) return 'Select an end date';
    if (start != null && end.isBefore(start)) return 'Must be after start';
    return null;
  }

  // ── Country pickers ──────────────────────────────────
  void pickStartingCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        bottomSheetHeight: 520.h,
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
        searchTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
        inputDecoration: InputDecoration(
          hintText: 'Search country...',
          prefixIcon: const Icon(Icons.search, color: AppColor.hintText),
          filled: true,
          fillColor: const Color(0xFFFFFCF8),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.2),
          ),
        ),
      ),
      onSelect: (Country country) {
        startingCountryController.text = country.name;
        if (_detailsValidated) detailsFormKey.currentState?.validate();
      },
    );
  }

  void pickDestinedCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        bottomSheetHeight: 520.h,
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
        searchTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
        inputDecoration: InputDecoration(
          hintText: 'Search country...',
          prefixIcon: const Icon(Icons.search, color: AppColor.hintText),
          filled: true,
          fillColor: const Color(0xFFFFFCF8),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.2),
          ),
        ),
      ),
      onSelect: (Country country) {
        destinedCountryController.text = country.name;
        if (_detailsValidated) detailsFormKey.currentState?.validate();
      },
    );
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
    var first = firstDate ?? DateTime(now.year - 1);
    final original = editingTrip == null
        ? null
        : _dateOnly(editingTrip!.startingDate);
    if (firstDate == null && original != null && original.isBefore(first)) {
      first = original;
    }
    return showDatePicker(
      context: context,
      initialDate: initial ?? firstDate ?? now,
      firstDate: first,
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
      isEditing ? _updateTrip() : _createTrip();
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
        startingCountry: startingCountryController.text.trim(),
        destinedPlace: destinedPlaceController.text.trim(),
        destinedCountry: destinedCountryController.text.trim(),
        startingDate: startDate.value!,
        endingDate: endDate.value!,
        travelTrackerEnabled: travelTracker.value,
        isPublic: anyoneCanSee.value,
        canShare: anyoneCanShare.value,
      );

      if (response.success != true || response.data == null) {
        globalSnackBar(
          title: 'Trip Not Created',
          message:
              response.message ?? 'Unable to create trip. Please try again.',
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

  Future<void> _updateTrip() async {
    final tripId = editingTrip?.id;
    if (tripId == null) return;
    try {
      isSubmitting.value = true;
      final response = await _tripRepository.updateTrip(
        tripId: tripId,
        title: titleController.text.trim(),
        startingPlace: startingPlaceController.text.trim(),
        startingCountry: startingCountryController.text.trim(),
        destinedPlace: destinedPlaceController.text.trim(),
        destinedCountry: destinedCountryController.text.trim(),
        startingDate: startDate.value!,
        endingDate: endDate.value!,
        travelTrackerEnabled: travelTracker.value,
        isPublic: anyoneCanSee.value,
        canShare: anyoneCanShare.value,
      );

      if (response.success != true || response.data == null) {
        globalSnackBar(
          title: 'Trip Not Updated',
          message:
              response.message ?? 'Unable to update trip. Please try again.',
        );
        return;
      }

      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.back(result: response);
    } catch (e) {
      handleException(e, context: 'Update Trip');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _showSuccessSheet(String? message) async {
    await AppBottomSheet.show(
      sticker: Assets.images.decisionSticker.path,
      title: "Done! It's Ready now!",
      description:
          message ??
          'Your trip plan is ready. You can start tracking whenever you want!',
      isDismissible: false,
      enableDrag: false,
      actionWidget: GlobalButton(
        text: 'View Trip',
        color: AppColor.primary,
        onTap: () => Get.back(),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back(result: _createdTrip);
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(1);
    }
  }

  @override
  void onClose() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.dispose();
      startingPlaceController.dispose();
      startingCountryController.dispose();
      destinedPlaceController.dispose();
      destinedCountryController.dispose();
      startDateController.dispose();
      endDateController.dispose();
    });
    super.onClose();
  }
}

