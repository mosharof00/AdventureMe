import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../global/widgets/app_text.dart';
import '../../global/widgets/global_button.dart';
import '../extensions/sizedbox_extension.dart';
import '../extensions/text_style_extension.dart';
import '../theme/app_color.dart';

/// Central place for everything Google-Maps related so the multiple map
/// screens in the app share the same permission / settings handling.
class MapService extends GetxService {
  /// Google Maps API key sourced from the `.env` file (loaded via dotenv).
  String get apiKey => dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';

  bool get hasApiKey => apiKey.isNotEmpty;

  /// Ensures location services are enabled and permission is granted.
  ///
  /// Shows a settings dialog when GPS is off or permission is permanently
  /// denied. Returns `true` only when the device location can be read.
  Future<bool> ensureLocationPermission({bool showDialogs = true}) async {
    // 1) Are location services (GPS) turned on?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (showDialogs) {
        await _showSettingsDialog(
          title: 'Location Services Off',
          message:
              'Turn on location services so we can show your position on the map.',
          confirmText: 'Open Settings',
          onConfirm: Geolocator.openLocationSettings,
        );
      }
      return false;
    }

    // 2) Do we have permission?
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (showDialogs) {
        await _showSettingsDialog(
          title: 'Location Permission Needed',
          message:
              'Location permission is permanently denied. Enable it from the app '
              'settings to use the map features.',
          confirmText: 'Open App Settings',
          onConfirm: Geolocator.openAppSettings,
        );
      }
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Rasterizes an SVG asset into a Google Maps [BitmapDescriptor] marker
  /// icon. [width] is the logical size the marker should appear at.
  Future<BitmapDescriptor> markerIconFromSvg(
    String assetPath, {
    double width = 42,
  }) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final scale = (width * dpr) / pictureInfo.size.width;
    final targetWidth = (pictureInfo.size.width * scale).round();
    final targetHeight = (pictureInfo.size.height * scale).round();

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..scale(scale)
      ..drawPicture(pictureInfo.picture);
    final image = await recorder.endRecording().toImage(
      targetWidth,
      targetHeight,
    );
    pictureInfo.picture.dispose();

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  /// Called once at app startup (splash). Shows a friendly rationale dialog
  /// first, then triggers the OS permission prompt so the map screens later
  /// open instantly with permission already resolved.
  Future<bool> requestLocationOnStartup() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    final proceed = await _showRationaleDialog();
    if (proceed != true) return false;

    return ensureLocationPermission(showDialogs: true);
  }

  /// Returns the current device position, or `null` if it can't be resolved.
  Future<Position?> currentPosition({bool showDialogs = true}) async {
    final granted = await ensureLocationPermission(showDialogs: showDialogs);
    if (!granted) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Friendly rationale shown before the OS prompt. Resolves `true` when the
  /// user chooses to continue.
  Future<bool?> _showRationaleDialog() {
    return _showDialog(
      title: 'Enable Location',
      message:
          'Superjet uses your location to place you on the map and track your '
          'trip checkpoints in real time. You can change this anytime in '
          'settings.',
      confirmText: 'Allow',
      cancelText: 'Not Now',
    );
  }

  Future<bool?> _showSettingsDialog({
    required String title,
    required String message,
    required String confirmText,
    required Future<bool> Function() onConfirm,
  }) {
    return _showDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: 'Cancel',
      onConfirm: onConfirm,
    );
  }

  Future<bool?> _showDialog({
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Cancel',
    Future<bool> Function()? onConfirm,
  }) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: const BoxDecoration(
                  color: AppColor.primaryDisable,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColor.primary,
                  size: 28.sp,
                ),
              ),
              16.height,
              AppText(
                title,
                style: Get.context!.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              10.height,
              AppText(
                message,
                style: Get.context!.bodyMedium.copyWith(
                  color: AppColor.hintText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              20.height,
              Row(
                children: [
                  Expanded(
                    child: GlobalButton(
                      text: cancelText,
                      color: AppColor.primaryDisable,
                      textColor: AppColor.primary,
                      onTap: () => Get.back<bool>(result: false),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: GlobalButton(
                      text: confirmText,
                      onTap: () async {
                        Get.back<bool>(result: true);
                        if (onConfirm != null) await onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
