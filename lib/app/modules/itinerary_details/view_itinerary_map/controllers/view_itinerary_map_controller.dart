import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/services/map_service.dart';
import 'package:adventureme/app/core/services/permission_service.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/itinerary_details/controllers/itinerary_details_controller.dart';
import 'package:adventureme/app/modules/itinerary_details/view_itinerary_map/widgets/mark_checkpoint_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';

class ViewItineraryMapController extends GetxController {
  final MapService _mapService = Get.find<MapService>();
  final PermissionService _permissions = Get.find<PermissionService>();
  final ITripRepository _tripRepository = Get.find<ITripRepository>();

  GoogleMapController? _map;

  String? tripId;
  String tripTitle = 'Trip Map';
  bool canMarkCheckpoint = false;
  List<TrackingDay> _tripDays = const [];

  final days = <TripMapDay>[].obs;
  final selectedDay = Rxn<int>();
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final hasError = false.obs;

  /// The [GoogleMap] is built once, after the data is ready, so the first
  /// camera already frames the trip. Rebuilding it on iOS blanks the map.
  final mapReady = false.obs;

  /// Non-reactive on purpose (changing it would rebuild the map).
  bool myLocationEnabled = false;

  final _icons = <String, BitmapDescriptor>{};
  GeoBounds? _tripBounds;

  /// Camera start when the trip has no checkpoints yet.
  LatLng? _userTarget;

  static final _time = DateFormat('h:mm a');
  static final _dayDate = DateFormat('MMM d, yyyy');
  static const _fallbackTarget = LatLng(40.8518, 14.2681);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      tripId = args['tripId'] as String?;
      if (args['title'] is String) tripTitle = args['title'] as String;
      if (args['days'] is List<TrackingDay>) _tripDays = args['days'];
      canMarkCheckpoint = args['canMarkCheckpoint'] == true;
    }
    _init();
  }

  Future<void> _init() async {
    myLocationEnabled = await _permissions.hasLocation();
    await loadMap();
    if (myLocationEnabled && totalCheckpoints == 0) {
      final position = await _permissions.currentPosition(showDialogs: false);
      if (position != null) {
        _userTarget = LatLng(position.latitude, position.longitude);
      }
    }
    mapReady.value = true;
  }

  // ── Data ─────────────────────────────────────────────
  Future<void> loadMap() async {
    final id = tripId;
    if (id == null) return;
    try {
      hasError.value = false;
      final response = await _tripRepository.getTripMap(id);
      if (response.success != true) {
        hasError.value = true;
        globalSnackBar(
          title: 'Trip Map',
          message: response.message ?? 'Unable to load the trip map.',
        );
        return;
      }
      _tripBounds = response.bounds;
      days.assignAll(response.days);
      if (isSingleDay) selectedDay.value = days.first.dayNumber;
      await _render();
      _fitCamera();
    } catch (e) {
      hasError.value = true;
      handleException(e, context: 'Trip Map');
    }
  }

  bool get isSingleDay => days.length == 1;

  TripMapDay? get currentDay =>
      days.firstWhereOrNull((d) => d.dayNumber == selectedDay.value);

  int get totalCheckpoints =>
      days.fold(0, (sum, d) => sum + d.checkpoints.length);

  String dayLabel(TripMapDay day) => 'Day ${day.dayNumber}';

  String dayDate(TripMapDay day) {
    final date = day.date ?? _tripDay(day.dayNumber)?.dateValue;
    return date == null ? '--' : _dayDate.format(date.toLocal());
  }

  String checkpointTime(Checkpoint c) {
    final time = c.enteredAt == null ? '--' : _time.format(c.enteredAt!.toLocal());
    final minutes = c.durationMinutes;
    if (minutes == null) return time;
    final duration = minutes >= 60
        ? '${minutes ~/ 60}h${minutes % 60 == 0 ? '' : ' ${minutes % 60}m'}'
        : '$minutes min';
    return '$time • $duration';
  }

  TrackingDay? _tripDay(int dayNumber) =>
      _tripDays.firstWhereOrNull((d) => d.dayNumber == dayNumber);

  // ── Selection ────────────────────────────────────────
  Future<void> selectDay(int? dayNumber) async {
    if (isSingleDay || selectedDay.value == dayNumber) return;
    selectedDay.value = dayNumber;
    await _render();
    _fitCamera();
  }

  void focusCheckpoint(Checkpoint checkpoint) {
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(checkpoint.lat, checkpoint.lng), 15),
    );
    _map?.showMarkerInfoWindow(MarkerId('cp_${checkpoint.id}'));
  }

  // ── Map overlays ─────────────────────────────────────
  /// Decoded routes, keyed by the encoded string (decoding is the costly part).
  final _decodedRoutes = <String, List<LatLng>>{};

  List<LatLng> _path(TripMapDay day) {
    final encoded = day.routePolyline;
    if (encoded != null && encoded.isNotEmpty) {
      return _decodedRoutes[encoded] ??= _mapService.decodePolyline(encoded);
    }
    return [for (final c in day.checkpoints) LatLng(c.lat, c.lng)];
  }

  Future<BitmapDescriptor> _icon(
    String key,
    Future<BitmapDescriptor> Function() build,
  ) async => _icons[key] ??= await build();

  int _renderId = 0;

  Future<void> _render() async {
    final renderId = ++_renderId;
    final selected = selectedDay.value;
    final newPolylines = <Polyline>{};
    final newMarkers = <Marker>{};

    final daysWithData = days.where((d) => d.checkpoints.isNotEmpty).toList();
    for (var i = 0; i < daysWithData.length - 1; i++) {
      final from = daysWithData[i].checkpoints.last;
      final to = daysWithData[i + 1].checkpoints.first;
      // Solid on purpose: dash patterns make the iOS Maps SDK build every
      // dash per zoom level, which exceeds the memory limit on long links.
      newPolylines.add(
        Polyline(
          polylineId: PolylineId('link_$i'),
          points: [LatLng(from.lat, from.lng), LatLng(to.lat, to.lng)],
          color: AppColor.secondary,
          width: 3,
        ),
      );
    }

    for (final day in days) {
      final isSelected = day.dayNumber == selected;
      final path = _path(day);
      if (path.length > 1) {
        newPolylines.add(
          Polyline(
            polylineId: PolylineId('day_${day.dayNumber}'),
            points: path,
            color: isSelected
                ? AppColor.primary
                : AppColor.primary.withValues(
                    alpha: selected == null ? 0.45 : 0.18,
                  ),
            width: isSelected ? 6 : 4,
            zIndex: isSelected ? 2 : 1,
            consumeTapEvents: true,
            onTap: () => selectDay(day.dayNumber),
          ),
        );
      }

      if (isSelected) {
        for (var i = 0; i < day.checkpoints.length; i++) {
          final c = day.checkpoints[i];
          newMarkers.add(
            Marker(
              markerId: MarkerId('cp_${c.id}'),
              position: LatLng(c.lat, c.lng),
              icon: await _icon(
                'cp_${i + 1}',
                () => _mapService.numberMarker(i + 1, color: AppColor.primary),
              ),
              anchor: const Offset(0.5, 0.5),
              zIndexInt: 3,
              infoWindow: InfoWindow(
                title: c.title,
                snippet: checkpointTime(c),
              ),
            ),
          );
        }
      } else if (day.anchor != null) {
        final dimmed = selected != null;
        newMarkers.add(
          Marker(
            markerId: MarkerId('day_${day.dayNumber}'),
            position: LatLng(day.anchor!.lat, day.anchor!.lng),
            icon: await _icon(
              'day_${day.dayNumber}_$dimmed',
              () => _mapService.labelMarker(
                dayLabel(day),
                color: dimmed ? AppColor.hintText : AppColor.primary,
              ),
            ),
            anchor: const Offset(0.5, 1),
            zIndexInt: 2,
            onTap: () => selectDay(day.dayNumber),
          ),
        );
      }
    }

    // A newer selection started while icons were being drawn; drop this one.
    if (renderId != _renderId || isClosed) return;
    polylines.assignAll(newPolylines);
    markers.assignAll(newMarkers);
  }

  // ── Bottom panel ─────────────────────────────────────
  /// Collapsed while the user explores the map; expanded on panel tap.
  final panelExpanded = true.obs;

  void collapsePanel() => panelExpanded.value = false;
  void expandPanel() => panelExpanded.value = true;

  // ── Camera ───────────────────────────────────────────
  /// Space kept clear for the bottom panel, so fitted content isn't hidden.
  EdgeInsets get mapPadding {
    final chips = isSingleDay ? 0.0 : 48.h;
    final double bottom = !panelExpanded.value
        ? 90.h + chips
        : currentDay == null
        ? 110.h + chips
        : 0.42.sh;
    return EdgeInsets.only(top: 8.h, bottom: bottom);
  }

  CameraPosition get initialCamera {
    final first = days
        .expand((d) => d.checkpoints)
        .map((c) => LatLng(c.lat, c.lng))
        .firstOrNull;
    return CameraPosition(
      target: first ?? _userTarget ?? _fallbackTarget,
      zoom: first == null && _userTarget != null ? 14 : 11,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _map = controller;
    _fitCamera();
  }

  void _fitCamera() {
    final map = _map;
    if (map == null) return;
    final day = currentDay;
    final points = [
      for (final d in day == null ? days.toList() : [day])
        for (final c in d.checkpoints) LatLng(c.lat, c.lng),
    ];
    if (points.isEmpty) return;

    final bounds = day == null ? _tripBounds : day.bounds;
    final update = points.length == 1
        ? CameraUpdate.newLatLngZoom(points.first, 14)
        : CameraUpdate.newLatLngBounds(
            bounds == null
                ? _mapService.boundsOf(points)
                : LatLngBounds(
                    southwest: LatLng(bounds.south, bounds.west),
                    northeast: LatLng(bounds.north, bounds.east),
                  ),
            60,
          );
    // Let the padding change from a new selection settle first.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!isClosed) map.animateCamera(update);
    });
  }

  /// Requests permission (with dialogs) and centers on the user.
  Future<void> goToMyLocation() async {
    final position = await _permissions.currentPosition();
    if (position == null) return;
    await _map?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────
  Future<Position?> currentPosition() => _permissions.currentPosition();

  Future<String?> addressFrom(double lat, double lng) =>
      _mapService.addressFrom(lat, lng);

  Future<void> onMarkCheckpoint(TripMapDay day) async {
    final saved = await MarkCheckpointDialog.show(
      dayNumber: day.dayNumber,
      date: day.date ?? _tripDay(day.dayNumber)?.dateValue,
    );
    if (saved) {
      globalSnackBar(
        title: 'Checkpoint Added',
        message: _checkpointMessage ?? 'Your checkpoint has been saved.',
        backgroundColor: AppColor.primary,
      );
    }
  }

  String? _checkpointMessage;

  /// Called by [MarkCheckpointDialog]; returns whether it was saved.
  Future<bool> saveCheckpoint({
    required int day,
    required String title,
    required String address,
    required double lat,
    required double lng,
    required DateTime enteredAt,
    required DateTime exitedAt,
  }) async {
    final id = tripId;
    if (id == null) return false;
    try {
      final response = await _tripRepository.addCheckpoint(
        tripId: id,
        day: day,
        title: title,
        address: address,
        lat: lat,
        lng: lng,
        enteredAt: enteredAt,
        exitedAt: exitedAt,
      );
      final checkpoint = response.data;
      if (response.success != true || checkpoint == null) {
        globalSnackBar(
          title: 'Not Saved',
          message: response.message ?? 'Unable to save the checkpoint.',
        );
        return false;
      }
      final index = days.indexWhere((d) => d.dayNumber == day);
      if (index != -1) days[index] = days[index].withCheckpoint(checkpoint);
      _tripBounds = null;
      await _render();
      _fitCamera();
      _checkpointMessage = response.message;
      return true;
    } catch (e) {
      handleException(e, context: 'Add Checkpoint');
      return false;
    }
  }

  void onUploadPhotos(TripMapDay day) {
    if (tripId == null) return;
    Get.toNamed(
      Routes.MANAGE_DAY_PHOTOS,
      arguments: {
        'tripId': tripId,
        'day': day.dayNumber,
        'date': dayDate(day),
      },
    );
  }
}
