import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adventureme/app/core/utils/dialog_utils.dart';
import 'package:adventureme/app/modules/archive/views/archive_view.dart';
import 'package:adventureme/app/modules/itinerary/views/itinerary_view.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/routes/app_pages.dart';

import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';

class MainPageController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedIndex = 0.obs;
  final drawerSelectedIndex = (-1).obs;

  final List<Widget> pages = const [
    HomeView(),
    ItineraryView(),
    ArchiveView(),
    ProfileView(),
  ];

  void changePage(int index) => selectedIndex.value = index;

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  bool _isExitDialogOpen = false;

  /// Hardware/gesture back on the main page: close the drawer if it's open,
  /// otherwise confirm before exiting the app.
  void onBackPressed() {
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      closeDrawer();
      return;
    }
    if (_isExitDialogOpen) return;
    _isExitDialogOpen = true;

    DialogUtils.showDialog(
      context: Get.context!,
      dialogType: DialogType.question,
      title: 'Exit App',
      description: 'Are you sure you want to exit the app?',
      okText: 'Exit',
      cancelText: 'Cancel',
      okOnPress: SystemNavigator.pop,
      cancelOnPress: () {},
      onDismiss: () => _isExitDialogOpen = false,
    );
  }

  void onDrawerItemTap(int index) {
    drawerSelectedIndex.value = index;
    closeDrawer();

    switch (index) {
      case 0:
        Get.toNamed(Routes.SAVED_ITINERARIES);
      case 1:
        Get.toNamed(Routes.SETTINGS);
      case 2:
        Get.toNamed(Routes.PRIVACY_POLICY);
    }
  }
}
