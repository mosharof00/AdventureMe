import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/itinerary/controllers/itinerary_controller.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/story_generating_dialog.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/trip_intention_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';
import 'package:adventureme/gen/assets.gen.dart';

class TripCheckpoint {
  const TripCheckpoint({
    required this.title,
    required this.time,
    required this.duration,
    required this.label,
    required this.quote,
    required this.photos,
  });

  final String title;
  final String time;
  final String duration;
  final String label;
  final String quote;
  final List<String> photos;
}

class TrackingDay {
  const TrackingDay({
    required this.dayLabel,
    required this.date,
    required this.checkpoints,
  });

  final String dayLabel;
  final String date;
  final List<TripCheckpoint> checkpoints;
}

/// Opened with a [TripListItem] (or a trip id) as the route argument.
class ItineraryDetailsController extends GetxController {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  String? tripId;

  final trip = Rxn<TripData>();
  final isLoading = false.obs;
  final hasError = false.obs;
  final isStarting = false.obs;
  final isCancelling = false.obs;

  /// Shown while the details request is in flight.
  TripListItem? _preview;

  final status = TripStatus.pending.obs;
  final days = <TrackingDay>[].obs;
  final elapsed = Duration.zero.obs;
  Timer? _ticker;

  static final _dayDate = DateFormat('MMM d, yyyy');

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is TripListItem) {
      _preview = arg;
      tripId = arg.id;
      status.value = arg.status;
    } else if (arg is String) {
      tripId = arg;
    }
    fetchDetails();
  }

  // ── Loading ──────────────────────────────────────────
  Future<void> fetchDetails() async {
    final id = tripId;
    if (id == null || isLoading.value) return;
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await _tripRepository.getTripDetails(id);
      final data = response.data;
      if (response.success == true && data != null) {
        _applyTrip(data);
      } else {
        hasError.value = trip.value == null;
        globalSnackBar(
          title: 'Trip Details',
          message: response.message ?? 'Unable to load trip details.',
        );
      }
    } catch (e) {
      hasError.value = trip.value == null;
      handleException(e, context: 'Itinerary Details');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyTrip(TripData data) {
    trip.value = data;
    status.value = data.tripStatus;
    days.assignAll([
      for (final interval in data.tripIntervals)
        TrackingDay(
          dayLabel: 'Day ${interval.dayNumber ?? '-'}',
          date: interval.date == null ? '--' : _dayDate.format(interval.date!),
          checkpoints: const [],
        ),
    ]);
    _syncTimer();
  }

  // ── Trip info ────────────────────────────────────────
  String get tripTitle =>
      trip.value?.title ?? _preview?.title ?? 'Untitled Trip';

  String get tripRoute => ItineraryController.formatRoute(
    trip.value?.startingPlace ?? _preview?.startingPlace,
    trip.value?.destinedPlace ?? _preview?.destinedPlace,
  );

  String get tripDates => ItineraryController.formatDateRange(
    trip.value?.startingDate ?? _preview?.startingDate,
    trip.value?.endingDate ?? _preview?.endingDate,
  );

  // ── Status helpers ───────────────────────────────────
  String get statusLabel =>
      status.value == TripStatus.active ? 'Ongoing' : status.value.label;

  bool get isPending =>
      status.value == TripStatus.pending || status.value == TripStatus.draft;
  bool get isOngoing =>
      status.value == TripStatus.active || status.value == TripStatus.paused;
  bool get isCompleted => status.value == TripStatus.completed;
  bool get isCancelled => status.value == TripStatus.cancelled;

  bool isDayDone(int index) => days[index].checkpoints.isNotEmpty;

  /// Label of the photo button on a completed day card.
  String get photoActionLabel => isCompleted ? 'Edit Photos' : 'Upload Photos';

  /// Days that already have tracked data (for the Photo Chapter tab).
  List<TrackingDay> get memoryDays => [
    for (var i = 0; i < days.length; i++)
      if (isDayDone(i)) days[i],
  ];

  // ── Timer ────────────────────────────────────────────
  String get timerText {
    final total = elapsed.value.inSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(total ~/ 3600)}:${two(total % 3600 ~/ 60)}:${two(total % 60)}';
  }

  Duration _computeElapsed() {
    final data = trip.value;
    final started = data?.startedAt;
    if (data == null) return Duration.zero;
    if (isCompleted && data.trackingDurationMinutes != null) {
      return Duration(minutes: data.trackingDurationMinutes!);
    }
    if (started == null) return Duration.zero;
    final until = switch (status.value) {
      TripStatus.active => DateTime.now(),
      TripStatus.paused => data.pausedAt ?? DateTime.now(),
      _ => data.endedAt ?? started,
    };
    final diff = until.difference(started);
    return diff.isNegative ? Duration.zero : diff;
  }

  void _syncTimer() {
    _ticker?.cancel();
    elapsed.value = _computeElapsed();
    if (status.value == TripStatus.active) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => elapsed.value = _computeElapsed(),
      );
    }
  }

  // ── Actions ──────────────────────────────────────────
  void onStartOrEnd() {
    if (isPending) _beginStartFlow();
  }

  /// Asks for the trip's intention first when it has none, then confirms.
  Future<void> _beginStartFlow() async {
    final current = trip.value;
    if (current == null || isStarting.value) return;

    String? intentionMessage;
    if (!current.hasIntention) {
      final saved = await TripIntentionDialog.show(
        onSubmit: (type, tags, intention) async {
          final message = await _saveIntention(type, tags, intention);
          intentionMessage = message;
          return message != null;
        },
      );
      if (!saved) return;
    }
    _confirmStart(intentionMessage);
  }

  /// Returns the server message on success, null on failure.
  Future<String?> _saveIntention(
    IntentionType type,
    List<String> tags,
    String intention,
  ) async {
    final id = tripId;
    if (id == null) return null;
    try {
      final response = await _tripRepository.saveIntention(
        tripId: id,
        type: type,
        tags: tags,
        intention: intention,
      );
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Saved',
          message: response.message ?? 'Unable to save your intention.',
        );
        return null;
      }
      trip.value = trip.value?.copyWith(
        intention: response.intention ?? intention,
        intentionType: response.intentionType ?? type.apiValue,
        intentionTags: response.intentionTags.isEmpty
            ? tags
            : response.intentionTags,
      );
      return response.message ?? '';
    } catch (e) {
      handleException(e, context: 'Save Trip Intention');
      return null;
    }
  }

  void _confirmStart(String? intentionMessage) {
    final thanks = (intentionMessage == null || intentionMessage.isEmpty)
        ? ''
        : '$intentionMessage\n';
    AppBottomSheet.show(
      sticker: Assets.images.excitedSticker.path,
      title: 'Ready to Start Your Trip?',
      description:
          '${thanks}Once started, your trip timer begins and tracking goes live.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Not Yet',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: () {
                if (!isStarting.value) Get.back();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => GlobalButton(
                text: 'Start Trip',
                onTap: _startTrip,
                widget: isStarting.value
                    ? GlobalLoading(size: 22.sp, color: AppColor.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startTrip() async {
    final id = tripId;
    if (id == null || isStarting.value) return;
    try {
      isStarting.value = true;
      final response = await _tripRepository.startTrip(id);
      final data = response.data;
      if (response.success != true || data == null) {
        globalSnackBar(
          title: 'Unable to Start',
          message: response.message ?? 'Unable to start the trip.',
        );
        return;
      }

      _closeSnackbars();
      if (Get.isBottomSheetOpen == true) Get.back();
      _applyTrip(
        data.tripIntervals.isEmpty
            ? data.copyWith(
                tripIntervals: trip.value?.tripIntervals ?? const [],
              )
            : data,
      );
      if (Get.isRegistered<ItineraryController>()) {
        Get.find<ItineraryController>().refreshAll();
      }
      globalSnackBar(
        title: 'Trip Started',
        message: response.message ?? 'Your adventure has started.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Start Trip');
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> onEditTrip() async {
    final current = trip.value;
    if (current == null) return;
    final result = await Get.toNamed(
      Routes.CREATE_NEW_TRIP,
      arguments: current,
    );
    if (result is! TripResponse) return;
    _returnToList();
    globalSnackBar(
      title: 'Trip Updated',
      message: result.message ?? 'Trip updated successfully.',
      backgroundColor: AppColor.primary,
    );
  }

  /// Leaves the details screen and reloads the Itinerary list.
  void _returnToList() {
    if (Get.isRegistered<ItineraryController>()) {
      Get.find<ItineraryController>().refreshAll();
    }
    _closeSnackbars();
    Get.back();
  }

  /// While a snackbar is showing, `Get.back()` only closes the snackbar.
  void _closeSnackbars() {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
  }

  void onViewMap() => Get.toNamed(
    Routes.VIEW_ITINERARY_MAP,
    arguments: {'days': days.toList(), 'title': tripTitle},
  );
  void onGenerateStory() => StoryGeneratingDialog.show();
  void onManageDayPhotos(int day, String date) => Get.toNamed(
    Routes.MANAGE_DAY_PHOTOS,
    arguments: {'day': day, 'date': date},
  );
  void onCheckpointDetails() {}

  void onCancelTrip() {
    AppBottomSheet.show(
      sticker: 'assets/images/cry_sticker.png',
      title: 'Are You Sure You Want to Delete?',
      description:
          'Deleting your trip will lose all the data from the beginning to the end.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Keep',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: keepTrip,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => GlobalButton(
                text: 'Cancel Trip',
                color: AppColor.error,
                onTap: confirmCancel,
                widget: isCancelling.value
                    ? GlobalLoading(size: 22.sp, color: AppColor.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmCancel() async {
    final id = tripId;
    if (id == null || isCancelling.value) return;
    try {
      isCancelling.value = true;
      final response = await _tripRepository.deleteTrip(id);
      if (response.success != true) {
        globalSnackBar(
          title: 'Unable to Cancel',
          message: response.message ?? 'Unable to cancel the trip.',
        );
        return;
      }

      isCancelling.value = false;
      _closeSnackbars();
      if (Get.isBottomSheetOpen == true) Get.back();
      _returnToList();
      globalSnackBar(
        title: 'Trip Cancelled',
        message: response.message ?? 'Trip removed.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Cancel Trip');
    } finally {
      isCancelling.value = false;
    }
  }

  void keepTrip() {
    if (!isCancelling.value) Get.back();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
