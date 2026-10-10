import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../global/widgets/app_text.dart';
import '../../global/widgets/global_button.dart';
import '../extensions/sizedbox_extension.dart';
import '../extensions/text_style_extension.dart';
import '../theme/app_color.dart';

/// App-wide permission handling (location for now), shared by maps,
/// manual check-ins and the upcoming automatic check-ins.
class PermissionService extends GetxService {
  Future<bool> hasLocation() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> hasBackgroundLocation() async =>
      await Geolocator.checkPermission() == LocationPermission.always;

  /// Ensures location services are on and "while in use" permission is
  /// granted. With [showDialogs], guides the user to Settings when blocked.
  Future<bool> ensureLocation({bool showDialogs = true}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (showDialogs) {
        await _showSettingsDialog(
          title: 'Location Services Off',
          message:
              'Turn on location services so we can show your position and '
              'mark your checkpoints.',
          confirmText: 'Open Settings',
          onConfirm: Geolocator.openLocationSettings,
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (showDialogs) {
        await _showSettingsDialog(
          title: 'Location Permission Needed',
          message:
              'Location permission is permanently denied. Enable it from the '
              'app settings to use the map and checkpoint features.',
          confirmText: 'Open App Settings',
          onConfirm: Geolocator.openAppSettings,
        );
      }
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// "Always" permission, needed for automatic check-ins while the app is in
  /// the background. The OS only offers it after "while in use" is granted.
  Future<bool> ensureBackgroundLocation({bool showDialogs = true}) async {
    if (!await ensureLocation(showDialogs: showDialogs)) return false;
    if (await hasBackgroundLocation()) return true;

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always) return true;

    if (showDialogs) {
      await _showSettingsDialog(
        title: 'Allow Location All the Time',
        message:
            'To check you in automatically during your trip, set location '
            'access to "Always" in the app settings.',
        confirmText: 'Open App Settings',
        onConfirm: Geolocator.openAppSettings,
      );
    }
    return false;
  }

  /// Called once at startup: a friendly rationale first, then the OS prompt,
  /// so map screens later open with permission already resolved.
  Future<bool> requestLocationOnStartup() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    if (permission == LocationPermission.deniedForever) return false;

    final proceed = await _showDialog(
      title: 'Enable Location',
      message:
          'AdventuresMe uses your location to place you on the map and track '
          'your trip checkpoints. You can change this anytime in settings.',
      confirmText: 'Allow',
      cancelText: 'Not Now',
    );
    if (proceed != true) return false;

    return ensureLocation();
  }

  /// Current device position, or `null` if it can't be resolved.
  Future<Position?> currentPosition({bool showDialogs = true}) async {
    if (!await ensureLocation(showDialogs: showDialogs)) return null;
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
