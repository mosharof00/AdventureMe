import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/routes/app_pages.dart';

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

  // ── Stats (no API yet) ───────────────────────────────
  final countriesVisited = 32;
  final totalCountries = 195;

  double get worldPercent => countriesVisited / totalCountries;
  int get worldPercentLabel => (worldPercent * 100).round();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: ItineraryTab.values.length, vsync: this)
      ..addListener(_onTabChanged);
    _loadIfNeeded(selectedTab.value);
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

  /// Reloads every tab (e.g. after a trip was created).
  void refreshAll() => _resetAll();

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
  String dateRange(TripListItem trip) {
    final start = trip.startingDate;
    final end = trip.endingDate;
    if (start == null && end == null) return '--';
    if (start == null) return _dayMonthYear.format(end!);
    if (end == null) return _dayMonthYear.format(start);
    final startText = start.year == end.year
        ? _dayMonth.format(start)
        : _dayMonthYear.format(start);
    return '$startText to ${_dayMonthYear.format(end)}';
  }

  String route(TripListItem trip) =>
      'Starting: ${trip.startingPlace ?? '--'} | Destined: ${trip.destinedPlace ?? '--'}';

  // ── Actions ──────────────────────────────────────────
  void onStartTracking(TripListItem trip) {}
  void onTrackLive(TripListItem trip) {}
  void onViewDetails(TripListItem trip) =>
      Get.toNamed(Routes.ITINERARY_DETAILS, arguments: trip);
  void onShare(TripListItem trip) {}
  void onScan(TripListItem trip) {}
  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

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
