import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/services/map_service.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/gen/assets.gen.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/modules/itinerary_details/controllers/itinerary_details_controller.dart';
import 'package:adventureme/app/modules/itinerary_details/view_itinerary_map/widgets/map_day_details_sheet.dart';
import 'package:adventureme/app/routes/app_pages.dart';

/// A single day plotted on the map.
class MapDay {
  const MapDay({
    required this.index,
    required this.day,
    required this.position,
  });

  final int index;
  final TrackingDay day;
  final LatLng position;

  String get dayLabel => day.dayLabel;
  String get date => day.date;
  List<TripCheckpoint> get checkpoints => day.checkpoints;
}

class ViewItineraryMapController extends GetxController {
  final MapService _mapService = Get.find<MapService>();

  final Completer<GoogleMapController> _mapCompleter =
      Completer<GoogleMapController>();

  String tripTitle = 'Trip Map';

  final Set<Marker> markers = <Marker>{};
  final Set<Polyline> polylines = <Polyline>{};

  /// Whether the map is allowed to build. The [GoogleMap] widget must be built
  /// exactly once — rebuilding it on iOS tears down the native view (black map),
  /// so we resolve the location permission first and only then render it.
  final RxBool mapReady = false.obs;

  /// Non-reactive on purpose (changing it would rebuild the map).
  bool myLocationEnabled = false;

  final List<MapDay> mapDays = <MapDay>[];

  /// Fallback route (Foz do Iguaçu region) used when days have no coordinates.
  static const List<LatLng> _fallbackRoute = [
    LatLng(-25.4265, -54.5836),
    LatLng(-25.3650, -54.5200),
    LatLng(-25.4010, -54.4450),
    LatLng(-25.4700, -54.5000),
    LatLng(-25.5200, -54.5600),
  ];

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _buildPolylines();
    _prepareMap();
  }

  /// Loads custom marker icons + resolves permission, then unlocks the map
  /// for a single build.
  Future<void> _prepareMap() async {
    await _buildMarkers();
    myLocationEnabled = await _mapService.ensureLocationPermission(
      showDialogs: false,
    );
    mapReady.value = true;
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['title'] is String) tripTitle = args['title'] as String;
      final days = args['days'];
      if (days is List<TrackingDay>) {
        for (var i = 0; i < days.length; i++) {
          mapDays.add(
            MapDay(
              index: i,
              day: days[i],
              position: _fallbackRoute[i % _fallbackRoute.length],
            ),
          );
        }
      }
    }
  }

  Future<void> _buildMarkers() async {
    if (mapDays.isEmpty) return;

    final redIcon = await _mapService.markerIconFromSvg(
      Assets.icons.radioRedIcon,
    );
    final blueIcon = await _mapService.markerIconFromSvg(
      Assets.icons.radioBlueIcon,
    );

    markers
      ..clear()
      ..addAll({
        for (final mapDay in mapDays)
          Marker(
            markerId: MarkerId('day_${mapDay.index}'),
            position: mapDay.position,
            icon: mapDay.index == 0 ? redIcon : blueIcon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: mapDay.checkpoints.isNotEmpty
                  ? mapDay.checkpoints.first.title
                  : mapDay.dayLabel,
              snippet: mapDay.checkpoints.isNotEmpty
                  ? mapDay.checkpoints.first.time
                  : mapDay.date,
            ),
            onTap: () => showDayDetails(mapDay),
          ),
      });
  }

  void _buildPolylines() {
    if (mapDays.isEmpty) return;

    polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('trip_route'),
          points: mapDays.map((d) => d.position).toList(),
          color: const Color(0xFF054480),
          width: 4,
          geodesic: true,
        ),
      );
  }

  CameraPosition get initialCamera => CameraPosition(
    target: mapDays.isNotEmpty ? mapDays.first.position : _fallbackRoute.first,
    zoom: 11,
  );

  Future<void> onMapCreated(GoogleMapController controller) async {
    if (!_mapCompleter.isCompleted) _mapCompleter.complete(controller);
    _fitToRoute();
  }

  Future<void> _fitToRoute() async {
    if (mapDays.length < 2) return;
    final controller = await _mapCompleter.future;
    final bounds = _boundsFromPoints(mapDays.map((d) => d.position).toList());
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Requests permission (with dialogs) and centers on the user.
  Future<void> goToMyLocation() async {
    final position = await _mapService.currentPosition();
    if (position == null) return;
    final controller = await _mapCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  // ── Bottom sheets / actions ─────────────────────────────
  void showDayDetails(MapDay mapDay) {
    Get.bottomSheet(
      MapDayDetailsSheet(
        mapDay: mapDay,
        onMarkCheckpoint: () => onMarkCheckpoint(mapDay),
        onUploadPhotos: () => onUploadPhotos(mapDay),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onUploadPhotos(MapDay mapDay) {
    Get.back(); // close the day sheet
    Get.toNamed(
      Routes.MANAGE_DAY_PHOTOS,
      arguments: {'day': mapDay.index + 1, 'date': mapDay.date},
    );
  }

  void onMarkCheckpoint(MapDay mapDay) {
    AppBottomSheet.show(
      sticker: Assets.images.robotSticker.path,
      title: 'Hey! Confirm Your Checkpoint!',
      description:
          'Are you sure you want to confirm ${mapDay.dayLabel} as your checkpoint!',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Cancel',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: () => Get.back(),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GlobalButton(
              text: 'Confirm',
              onTap: () {
                Get.back(); // confirm sheet
                Get.back(); // day sheet
              },
            ),
          ),
        ],
      ),
    );
  }
}
