import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:adventureme/app/core/services/map_service.dart';
import 'package:adventureme/app/core/services/permission_service.dart';
import 'package:adventureme/app/data/models/picked_location.dart';
import 'package:adventureme/app/routes/app_pages.dart';

/// Pick a point by moving the map under a fixed center pin, or by search.
/// Open it with [SelectLocationController.pick]; it pops a [PickedLocation].
class SelectLocationController extends GetxController {
  final _map = Get.find<MapService>();
  final _permissions = Get.find<PermissionService>();

  /// Opens the screen; returns `null` when the user backs out.
  static Future<PickedLocation?> pick({
    PickedLocation? initial,
    String title = 'Select Location',
  }) async {
    final result = await Get.toNamed(
      Routes.SELECT_LOCATION,
      arguments: {'initial': initial, 'title': title},
    );
    return result is PickedLocation ? result : null;
  }

  static const _fallback = LatLng(23.8103, 90.4125);

  String title = 'Select Location';
  late LatLng initialTarget = _fallback;
  double initialZoom = 15;

  final mapReady = false.obs;
  final myLocationEnabled = false.obs;

  /// The point under the pin.
  late final target = Rx<LatLng>(_fallback);
  final address = RxnString();
  final isMoving = false.obs;
  final isResolving = false.obs;

  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  final results = <PickedLocation>[].obs;
  final isSearching = false.obs;
  final searchText = ''.obs;

  /// The last search finished without any place.
  final noResults = false.obs;

  GoogleMapController? _mapController;
  Timer? _searchDebounce;
  int _resolveId = 0;

  /// Set after a search pick, so the camera stop doesn't overwrite its name.
  String? _knownAddress;

  bool get canConfirm => !isMoving.value && !isResolving.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    PickedLocation? initial;
    if (args is Map) {
      title = args['title']?.toString() ?? title;
      if (args['initial'] is PickedLocation) initial = args['initial'];
    }
    _start(initial);
  }

  Future<void> _start(PickedLocation? initial) async {
    myLocationEnabled.value = await _permissions.hasLocation();
    if (initial != null) {
      initialTarget = LatLng(initial.lat, initial.lng);
      _knownAddress = initial.address;
    } else {
      final position = await _permissions.currentPosition(showDialogs: false);
      if (position != null) {
        initialTarget = LatLng(position.latitude, position.longitude);
      } else {
        initialZoom = 11;
      }
    }
    target.value = initialTarget;
    mapReady.value = true;
    _resolveAddress();
  }

  // ── Map ──────────────────────────────────────────────
  void onMapCreated(GoogleMapController controller) =>
      _mapController = controller;

  void onCameraMove(CameraPosition position) {
    target.value = position.target;
    isMoving.value = true;
  }

  void onCameraIdle() {
    if (!isMoving.value) return;
    isMoving.value = false;
    _resolveAddress();
  }

  Future<void> _resolveAddress() async {
    final known = _knownAddress;
    if (known != null) {
      _knownAddress = null;
      address.value = known;
      return;
    }
    final id = ++_resolveId;
    final point = target.value;
    isResolving.value = true;
    final value = await _map.addressFrom(point.latitude, point.longitude);
    if (id != _resolveId || isClosed) return;
    address.value = value;
    isResolving.value = false;
  }

  Future<void> goToMyLocation() async {
    final position = await _permissions.currentPosition();
    if (position == null || isClosed) return;
    myLocationEnabled.value = true;
    _moveTo(LatLng(position.latitude, position.longitude));
  }

  void _moveTo(LatLng point) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
  }

  // ── Search ───────────────────────────────────────────
  void onSearchChanged(String value) {
    searchText.value = value;
    noResults.value = false;
    _searchDebounce?.cancel();
    if (value.trim().length < 2) {
      results.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final query = value;
      final found = await _map.searchPlaces(query);
      if (isClosed || query != searchText.value) return;
      results.assignAll(found);
      noResults.value = found.isEmpty;
      isSearching.value = false;
    });
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  void selectResult(PickedLocation place) {
    searchFocus.unfocus();
    searchController.text = place.label;
    searchText.value = place.label;
    results.clear();
    noResults.value = false;
    _knownAddress = place.address;
    _moveTo(LatLng(place.lat, place.lng));
  }

  // ── Confirm ──────────────────────────────────────────
  void confirm() {
    if (!canConfirm) return;
    final point = target.value;
    Get.back(
      result: PickedLocation(
        lat: point.latitude,
        lng: point.longitude,
        address: address.value,
      ),
    );
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
