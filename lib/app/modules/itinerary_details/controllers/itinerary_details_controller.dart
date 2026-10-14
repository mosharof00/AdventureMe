import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/services/trip_prompt_service.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/day_photos_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/itinerary/controllers/itinerary_controller.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/add_memory_dialog.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/story_generating_dialog.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/trip_intention_dialog.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/trip_reflection_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';
import 'package:adventureme/gen/assets.gen.dart';

class TripCheckpoint {
  const TripCheckpoint({
    required this.title,
    this.address,
    required this.time,
    this.duration = '',
    this.isCompleted = false,
  });

  final String title;
  final String? address;
  final String time;
  final String duration;
  final bool isCompleted;

  static final _time = DateFormat('h:mm a');

  factory TripCheckpoint.from(Checkpoint c) {
    final title = c.title?.trim() ?? '';
    final address = c.address?.trim() ?? '';
    final entered = c.enteredAt?.toLocal();
    final exited = c.exitedAt?.toLocal();
    final minutes =
        c.durationMinutes ??
        (entered != null && exited != null
            ? exited.difference(entered).inMinutes
            : null);
    return TripCheckpoint(
      title: title.isNotEmpty
          ? title
          : (address.isNotEmpty ? address : 'Checkpoint'),
      address: title.isNotEmpty && address.isNotEmpty ? address : null,
      time: entered == null
          ? '--'
          : exited == null
          ? _time.format(entered)
          : '${_time.format(entered)} - ${_time.format(exited)}',
      duration: minutes == null || minutes <= 0 ? '' : _formatMinutes(minutes),
      isCompleted: c.status == 'COMPLETED',
    );
  }

  /// `30` → `30 min`, `90` → `1h 30m`, `120` → `2h`.
  static String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class TrackingDay {
  const TrackingDay({
    this.dayNumber = 0,
    required this.dayLabel,
    required this.date,
    this.dateValue,
    required this.checkpoints,
  });

  final int dayNumber;
  final String dayLabel;
  final String date;
  final DateTime? dateValue;
  final List<TripCheckpoint> checkpoints;
}

/// Opened with a [TripListItem] (or a trip id) as the route argument.
class ItineraryDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  late final TabController tabController;

  String? tripId;

  final trip = Rxn<TripData>();
  final isLoading = false.obs;
  final hasError = false.obs;
  final isStarting = false.obs;
  final isEnding = false.obs;
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
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChanged);
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

  /// True while switching tabs from [onViewDayDetails], so the tab listener
  /// does not reset the day to Day 1.
  bool _fromViewDetails = false;

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    if (tabController.index != 1) return;
    if (_fromViewDetails) {
      _fromViewDetails = false;
      return;
    }
    // Tapping Photo Chapter always opens the first day.
    openPhotoChapter(days.isEmpty ? 1 : days.first.dayNumber);
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
        _askIntentionIfMissing(data).then((_) {
          _askDailyPrompts(data);
          _askReflectionIfMissing(data);
        });
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
          dayNumber: interval.dayNumber ?? 0,
          dayLabel: 'Day ${interval.dayNumber ?? '-'}',
          date: interval.date == null ? '--' : _dayDate.format(interval.date!),
          dateValue: interval.date,
          checkpoints: [
            for (final c in interval.checkPoints) TripCheckpoint.from(c),
          ],
        ),
    ]);
    _syncTimer();
    if (_chapterWanted) {
      openPhotoChapter(
        selectedChapterDayNumber.value > 0
            ? selectedChapterDayNumber.value
            : (days.isEmpty ? 1 : days.first.dayNumber),
        force: true,
      );
    }
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
  bool get isActive => status.value == TripStatus.active;
  bool get isCompleted => status.value == TripStatus.completed;
  bool get isCancelled => status.value == TripStatus.cancelled;

  bool isDayDone(int index) => days[index].checkpoints.isNotEmpty;

  /// Label of the photo button on a completed day card.
  String get photoActionLabel => isCompleted ? 'Edit Photos' : 'Upload Photos';

  // ── Photo Chapter ────────────────────────────────────
  /// Day currently shown on the Photo Chapter tab.
  final selectedChapterDayNumber = 0.obs;
  final selectedChapterDay = Rxn<TrackingDay>();
  final chapterMoments = <TripMoment>[].obs;
  final isChapterLoading = false.obs;
  final chapterError = false.obs;

  /// Last successfully loaded day; skip re-fetch unless [force].
  int? _loadedChapterDay;

  /// The tab has been opened; reload once trip days arrive.
  bool _chapterWanted = false;

  /// Opens / refreshes Photo Chapter for [dayNumber].
  Future<void> openPhotoChapter(int dayNumber, {bool force = false}) async {
    _chapterWanted = true;
    selectedChapterDayNumber.value = dayNumber;
    TrackingDay? day;
    for (final d in days) {
      if (d.dayNumber == dayNumber) {
        day = d;
        break;
      }
    }
    selectedChapterDay.value = day;
    await loadPhotoChapter(force: force);
  }

  /// Fetches published moments for [selectedChapterDayNumber].
  Future<void> loadPhotoChapter({bool force = false}) async {
    _chapterWanted = true;
    final id = tripId;
    final dayNumber = selectedChapterDayNumber.value > 0
        ? selectedChapterDayNumber.value
        : (days.isEmpty ? 1 : days.first.dayNumber);
    if (id == null || isChapterLoading.value) return;
    if (!force && _loadedChapterDay == dayNumber) return;
    if (days.isEmpty) return;

    selectedChapterDayNumber.value = dayNumber;
    TrackingDay? day;
    for (final d in days) {
      if (d.dayNumber == dayNumber) {
        day = d;
        break;
      }
    }
    selectedChapterDay.value = day;

    try {
      isChapterLoading.value = true;
      chapterError.value = false;
      final response = await _tripRepository.getDayPhotos(id, dayNumber);
      if (isClosed) return;
      if (response.success != true) {
        chapterError.value = true;
        chapterMoments.clear();
        return;
      }
      chapterMoments.assignAll(
        response.moments.where((m) => !m.isDraft && m.photos.isNotEmpty),
      );
      _loadedChapterDay = dayNumber;
    } catch (e) {
      chapterError.value = true;
      chapterMoments.clear();
      handleException(e, context: 'Photo Chapter');
    } finally {
      isChapterLoading.value = false;
    }
  }

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
    final tracked = data.trackingDurationMinutes ?? 0;
    if (isCompleted && tracked > 0) return Duration(minutes: tracked);
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
    if (trip.value == null || isStarting.value || isEnding.value) return;
    if (isPending) {
      _confirmStart();
    } else if (isOngoing) {
      _confirmEnd();
    }
  }

  void _confirmEnd() {
    AppBottomSheet.show(
      sticker: Assets.images.coolSticker.path,
      title: 'End Your Adventure?',
      description:
          'Tracking stops once the trip ends. You can still add photos and create your story.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Not Yet',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: () {
                if (!isEnding.value) Get.back();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => GlobalButton(
                text: 'End Trip',
                onTap: _endTrip,
                widget: isEnding.value
                    ? GlobalLoading(size: 22.sp, color: AppColor.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _endTrip() async {
    final id = tripId;
    if (id == null || isEnding.value) return;
    String? message;
    try {
      isEnding.value = true;
      final response = await _tripRepository.endTrip(id);
      final data = response.data;
      if (response.success != true || data == null) {
        globalSnackBar(
          title: 'Unable to End',
          message: response.message ?? 'Unable to end the trip.',
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
      message = response.message;
    } catch (e) {
      handleException(e, context: 'End Trip');
      return;
    } finally {
      isEnding.value = false;
    }

    _reflectionAsked = true;
    final reflected = await TripReflectionDialog.show(
      intention: trip.value?.intention,
    );
    if (reflected) {
      _showReflectionSaved();
    } else {
      globalSnackBar(
        title: 'Trip Completed',
        message: message ?? 'Your adventure is complete.',
        backgroundColor: AppColor.primary,
      );
    }
  }

  // ── Reflection ───────────────────────────────────────
  /// Asked at most once per visit, so a refresh doesn't re-open it.
  bool _reflectionAsked = false;
  String? _reflectionMessage;

  Future<void> _askReflectionIfMissing(TripData data) async {
    if (isClosed ||
        _reflectionAsked ||
        data.tripStatus != TripStatus.completed ||
        data.hasReflection) {
      return;
    }
    _reflectionAsked = true;
    if (await TripReflectionDialog.show(intention: data.intention)) {
      _showReflectionSaved();
    }
  }

  /// Called by [TripReflectionDialog]; returns whether it was saved.
  Future<bool> saveReflection(
    String reflection,
    DominantEmotion emotion,
  ) async {
    final id = tripId;
    if (id == null) return false;
    try {
      final response = await _tripRepository.saveReflection(
        tripId: id,
        reflection: reflection,
        emotion: emotion,
      );
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Saved',
          message: response.message ?? 'Unable to save your reflection.',
        );
        return false;
      }
      trip.value = trip.value?.copyWith(
        reflectedAt: response.reflectedAt ?? DateTime.now(),
      );
      _reflectionMessage = response.message;
      return true;
    } catch (e) {
      handleException(e, context: 'Save Trip Reflection');
      return false;
    }
  }

  void _showReflectionSaved() {
    globalSnackBar(
      title: 'Reflection Saved',
      message:
          _reflectionMessage ?? 'Thank you for sharing what stayed with you.',
      backgroundColor: AppColor.primary,
    );
  }

  // ── Intention ────────────────────────────────────────
  /// Asked at most once per visit, so a refresh doesn't re-open it.
  bool _intentionAsked = false;

  Future<void> _askIntentionIfMissing(TripData data) async {
    final needsIntention =
        data.tripStatus == TripStatus.pending ||
        data.tripStatus == TripStatus.active;
    if (isClosed || _intentionAsked || !needsIntention || data.hasIntention) {
      return;
    }
    _intentionAsked = true;

    final saved = await TripIntentionDialog.show();
    if (saved) {
      globalSnackBar(
        title: 'Intention Saved',
        message:
            _intentionMessage ??
            'Thank you. This will help us tell your story.',
        backgroundColor: AppColor.primary,
      );
    }
  }

  String? _intentionMessage;

  // ── Daily prompts ────────────────────────────────────
  void _askDailyPrompts(TripData data) {
    final id = tripId;
    if (isClosed || id == null || data.tripStatus != TripStatus.active) return;
    Get.find<TripPromptService>().askIfPending(id);
  }

  /// Called by [TripIntentionDialog]; returns whether it was saved.
  Future<bool> saveIntention(
    IntentionType type,
    List<String> tags,
    String intention,
  ) async {
    final id = tripId;
    if (id == null) return false;
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
        return false;
      }
      trip.value = trip.value?.copyWith(
        intention: response.intention ?? intention,
        intentionType: response.intentionType ?? type.apiValue,
        intentionTags: response.intentionTags.isEmpty
            ? tags
            : response.intentionTags,
      );
      _intentionMessage = response.message;
      return true;
    } catch (e) {
      handleException(e, context: 'Save Trip Intention');
      return false;
    }
  }

  void _confirmStart() {
    AppBottomSheet.show(
      sticker: Assets.images.excitedSticker.path,
      title: 'Ready to Start Your Trip?',
      description:
          'Once started, your trip timer begins and tracking goes live.',
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

  // ── Memories ─────────────────────────────────────────
  Future<void> onAddMemory() async {
    if (!isActive || days.isEmpty) return;
    final saved = await AddMemoryDialog.show();
    if (saved) {
      globalSnackBar(
        title: 'Memory Saved',
        message: _memoryMessage ?? 'Your memory has been saved.',
        backgroundColor: AppColor.primary,
      );
    }
  }

  /// Today's day of the trip, clamped to the first/last day.
  int get todayDayNumber {
    final numbers = days.map((d) => d.dayNumber).toList();
    if (numbers.isEmpty) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final interval
        in trip.value?.tripIntervals ?? const <TripInterval>[]) {
      final date = interval.date?.toLocal();
      if (date == null) continue;
      if (DateTime(date.year, date.month, date.day) == today) {
        return interval.dayNumber ?? numbers.first;
      }
    }
    final start = trip.value?.startingDate;
    if (start != null && today.isBefore(start)) return numbers.first;
    return numbers.last;
  }

  /// Called by [AddMemoryDialog]; returns whether it was saved.
  Future<bool> saveMemory({
    required int day,
    required MemorySource source,
    String? text,
    File? voice,
  }) async {
    final id = tripId;
    if (id == null) return false;
    try {
      final response = await _tripRepository.addMemory(
        tripId: id,
        day: day,
        source: source,
        text: text,
        voice: voice,
      );
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Saved',
          message: response.message ?? 'Unable to save your memory.',
        );
        return false;
      }
      _memoryMessage = response.message;
      return true;
    } catch (e) {
      handleException(e, context: 'Add Trip Memory');
      return false;
    }
  }

  String? _memoryMessage;

  void onViewMap() => Get.toNamed(
    Routes.VIEW_ITINERARY_MAP,
    arguments: {
      'tripId': tripId,
      'title': tripTitle,
      'days': days.toList(),
      'canMarkCheckpoint': isOngoing || isCompleted,
    },
  );
  void onGenerateStory() {
    final id = tripId;
    if (isCompleted && id != null) StoryGeneratingDialog.show(id);
  }

  Future<void> onManageDayPhotos(TrackingDay day) async {
    if (tripId == null) return;
    await Get.toNamed(
      Routes.MANAGE_DAY_PHOTOS,
      arguments: {'tripId': tripId, 'day': day.dayNumber, 'date': day.date},
    );
    if (_chapterWanted) {
      openPhotoChapter(
        selectedChapterDayNumber.value > 0
            ? selectedChapterDayNumber.value
            : day.dayNumber,
        force: true,
      );
    }
  }

  /// Timeline "View Details" → Photo Chapter for that day.
  void onViewDayDetails(TrackingDay day) {
    _fromViewDetails = true;
    openPhotoChapter(day.dayNumber);
    if (tabController.index != 1) tabController.animateTo(1);
  }

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
  @override
  void onClose() {
    _ticker?.cancel();
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
