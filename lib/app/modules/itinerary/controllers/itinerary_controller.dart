import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/image_picker_helper.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/models/trip_models/visited_countries_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/itinerary/widgets/trip_thumbnail_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';
import 'package:adventureme/gen/assets.gen.dart';

/// List + cursor-pagination state of one tab.
class TripTabState {
  TripTabState(this.tab);

  final ItineraryTab tab;

  final items = <TripListItem>[].obs;

  /// First page (or a reset after search) is loading.
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;

  bool hasNextPage = true;
  String? cursor;

  /// Whether the first page was requested for the current search.
  bool loaded = false;

  /// Bumped on every reset; responses from an older generation are dropped.
  int generation = 0;
}

class ItineraryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  static const int pageSize = 5;

  late final TabController tabController;
  final selectedTab = ItineraryTab.all.obs;

  final tabs = {for (final tab in ItineraryTab.values) tab: TripTabState(tab)};

  final searchController = TextEditingController();
  String _search = '';
  Timer? _searchDebounce;

  // ── Stats (from /trips/visited-countries) ───────────
  final visitedCountries = Rxn<VisitedCountriesData>();
  final isLoadingVisitedCountries = false.obs;

  int get countriesVisited =>
      visitedCountries.value?.totalVisitedCountries ?? 0;
  int get totalCountries =>
      visitedCountries.value?.totalWorldCountries ?? 195;
  double get worldPercent {
    final pct = visitedCountries.value?.worldPercentage;
    if (pct != null) return (pct / 100.0).clamp(0.0, 1.0);
    return totalCountries > 0 ? ((countriesVisited / totalCountries).clamp(0.0, 1.0)) : 0.0;
  }
  int get worldPercentLabel =>
      visitedCountries.value?.worldPercentageRounded ??
      (worldPercent * 100).round();

  Future<void> fetchVisitedCountries() async {
    try {
      isLoadingVisitedCountries.value = true;
      final response = await _tripRepository.getVisitedCountries();
      if (response.success == true && response.data != null) {
        visitedCountries.value = response.data;
      }
    } catch (e) {
      handleException(e, context: 'Visited Countries');
    } finally {
      isLoadingVisitedCountries.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: ItineraryTab.values.length, vsync: this)
      ..addListener(_onTabChanged);
    _loadIfNeeded(selectedTab.value);
    fetchVisitedCountries();
  }

  TripTabState stateOf(ItineraryTab tab) => tabs[tab]!;

  void changeTab(ItineraryTab tab) => tabController.animateTo(tab.index);

  void _onTabChanged() {
    final tab = ItineraryTab.values[tabController.index];
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    _loadIfNeeded(tab);
  }

  void _loadIfNeeded(ItineraryTab tab) {
    if (!stateOf(tab).loaded) refreshTab(tab);
  }

  // ── Search ───────────────────────────────────────────
  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = value.trim();
      if (query == _search) return;
      _search = query;
      _resetAll();
    });
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  /// New search: every tab reloads, the visible one right away, the others
  /// when opened.
  void _resetAll() {
    for (final state in tabs.values) {
      state
        ..generation += 1
        ..loaded = false
        ..items.clear()
        ..isLoading.value = false
        ..isLoadingMore.value = false;
    }
    refreshTab(selectedTab.value);
  }

  /// Reloads every tab and refreshes visited countries (e.g. after a trip was created/updated).
  void refreshAll() {
    _resetAll();
    fetchVisitedCountries();
  }

  /// Pull-to-refresh on any tab: refreshes the tab data and the header stats.
  Future<void> refreshTabWithStats(ItineraryTab tab) async {
    await Future.wait([
      refreshTab(tab),
      fetchVisitedCountries(),
    ]);
  }

  // ── Loading ──────────────────────────────────────────
  Future<void> refreshTab(ItineraryTab tab) async {
    final state = stateOf(tab);
    final generation = ++state.generation;
    state
      ..loaded = true
      ..cursor = null
      ..hasNextPage = true
      ..hasError.value = false
      ..isLoadingMore.value = false;
    if (state.items.isEmpty) state.isLoading.value = true;

    try {
      final response = await _fetch(state, cursor: null);
      if (generation != state.generation) return;
      state.items.assignAll(response.data);
      _applyMeta(state, response);
    } catch (e) {
      if (generation != state.generation) return;
      state.hasError.value = true;
      handleException(e, context: 'Itinerary - ${tab.label}');
    } finally {
      if (generation == state.generation) state.isLoading.value = false;
    }
  }

  Future<void> loadMore(ItineraryTab tab) async {
    final state = stateOf(tab);
    if (!state.hasNextPage ||
        state.isLoading.value ||
        state.isLoadingMore.value ||
        state.items.isEmpty) {
      return;
    }

    final generation = state.generation;
    state.isLoadingMore.value = true;
    try {
      final response = await _fetch(state, cursor: state.cursor);
      if (generation != state.generation) return;
      final known = state.items.map((e) => e.id).toSet();
      state.items.addAll(response.data.where((e) => !known.contains(e.id)));
      _applyMeta(state, response);
    } catch (e) {
      if (generation != state.generation) return;
      handleException(e, context: 'Itinerary - ${tab.label} (more)');
    } finally {
      if (generation == state.generation) state.isLoadingMore.value = false;
    }
  }

  Future<TripListResponse> _fetch(TripTabState state, {String? cursor}) {
    return _tripRepository.getTrips(
      cursor: cursor,
      limit: pageSize,
      status: state.tab.status,
      search: _search,
    );
  }

  /// Uses the server's `nextCursor`, falling back to the last item's id.
  void _applyMeta(TripTabState state, TripListResponse response) {
    final meta = response.meta;
    state.hasNextPage =
        meta?.hasNextPage ?? response.data.length >= pageSize;
    state.cursor = meta?.nextCursor ??
        (state.items.isNotEmpty ? state.items.last.id : null);
    if (state.cursor == null) state.hasNextPage = false;
  }

  // ── Formatting ───────────────────────────────────────
  static final _dayMonth = DateFormat('MMM d');
  static final _dayMonthYear = DateFormat('MMM d, yyyy');

  /// e.g. "Mar 10 to Mar 17, 2026" (API dates are day-only, kept in UTC).
  String dateRange(TripListItem trip) =>
      formatDateRange(trip.startingDate, trip.endingDate);

  static String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '--';
    if (start == null) return _dayMonthYear.format(end!);
    if (end == null) return _dayMonthYear.format(start);
    final startText = start.year == end.year
        ? _dayMonth.format(start)
        : _dayMonthYear.format(start);
    return '$startText to ${_dayMonthYear.format(end)}';
  }

  String route(TripListItem trip) => formatRoute(
        trip.startingPlace,
        trip.destinedPlace,
        startingCountry: trip.startingCountry,
        destinedCountry: trip.destinedCountry,
      );

  String destination(TripListItem trip) {
    final dest = [trip.destinedPlace, trip.destinedCountry]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(', ');
    return dest.isEmpty ? '--' : dest;
  }

  static String formatRoute(
    String? starting,
    String? destined, {
    String? startingCountry,
    String? destinedCountry,
  }) {
    final start = [starting, startingCountry]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(', ');
    final dest = [destined, destinedCountry]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(', ');
    return 'Starting: ${start.isEmpty ? '--' : start} | Destined: ${dest.isEmpty ? '--' : dest}';
  }

  // ── Actions ──────────────────────────────────────────
  Future<void> onViewDetails(TripListItem trip) async {
    await Get.toNamed(Routes.ITINERARY_DETAILS, arguments: trip);
    refreshAll();
  }

  Future<void> onEditTrip(TripListItem trip) async {
    final id = trip.id;
    if (id == null) return;
    try {
      final details = await _tripRepository.getTripDetails(id);
      if (details.data != null) {
        final result = await Get.toNamed(
          Routes.CREATE_NEW_TRIP,
          arguments: details.data,
        );
        if (result is TripResponse) {
          refreshAll();
        }
      }
    } catch (e) {
      handleException(e, context: 'Edit Trip');
    }
  }

  Future<void> confirmDeleteTrip(TripListItem trip) async {
    final id = trip.id;
    if (id == null) return;

    AppBottomSheet.show(
      sticker: Assets.images.crySticker.path,
      title: 'Are You Sure You Want to Delete?',
      description:
          'Deleting your trip "${trip.title ?? 'Untitled Trip'}" will permanently remove all trip data.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Keep',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: () => Get.back(),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GlobalButton(
              text: 'Delete Trip',
              color: AppColor.error,
              onTap: () async {
                Get.back(); // close bottom sheet
                await _executeDeleteTrip(id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeleteTrip(String tripId) async {
    try {
      final response = await _tripRepository.deleteTrip(tripId);
      if (response.success == true) {
        refreshAll();
        globalSnackBar(
          title: 'Trip Deleted',
          message: response.message ?? 'Trip removed.',
          backgroundColor: AppColor.primary,
        );
      } else {
        globalSnackBar(
          title: 'Unable to Delete',
          message: response.message ?? 'Unable to delete the trip.',
        );
      }
    } catch (e) {
      handleException(e, context: 'Delete Trip');
    }
  }

  void onShare(TripListItem trip) {}
  void onScan(TripListItem trip) {}
  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  // ── Thumbnail ────────────────────────────────────────
  final pickedThumbnail = Rxn<File>();
  final isUploadingThumbnail = false.obs;

  void onEditThumbnail(TripListItem trip) {
    if (trip.id == null) return;
    pickedThumbnail.value = null;
    TripThumbnailDialog.show(trip);
  }

  Future<void> pickThumbnail(ImageSource source) async {
    final file = await ImagePickerHelper.pickSingleFile(
      imageSource: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (file != null) pickedThumbnail.value = File(file.path);
  }

  void closeThumbnailDialog() {
    if (isUploadingThumbnail.value) return;
    pickedThumbnail.value = null;
    Get.back();
  }

  Future<void> saveThumbnail(TripListItem trip) async {
    final file = pickedThumbnail.value;
    final tripId = trip.id;
    if (file == null || tripId == null || isUploadingThumbnail.value) return;

    try {
      isUploadingThumbnail.value = true;
      final response = await _tripRepository.uploadThumbnail(
        tripId: tripId,
        file: file,
      );
      final url = response.thumbnailUrl;
      if (response.success != true || url == null || url.isEmpty) {
        globalSnackBar(
          title: 'Update Failed',
          message: response.message ?? 'Unable to update the thumbnail.',
        );
        return;
      }

      _applyCover(tripId, url);
      isUploadingThumbnail.value = false;
      closeThumbnailDialog();
      globalSnackBar(
        title: 'Thumbnail Updated',
        message: response.message ?? 'Trip thumbnail updated.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Itinerary - Upload Thumbnail');
    } finally {
      isUploadingThumbnail.value = false;
    }
  }

  /// The same trip can appear in several tabs.
  void _applyCover(String tripId, String url) {
    for (final state in tabs.values) {
      final index = state.items.indexWhere((e) => e.id == tripId);
      if (index != -1) {
        state.items[index] = state.items[index].copyWith(coverUrl: url);
      }
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    searchController.dispose();
    super.onClose();
  }
}
