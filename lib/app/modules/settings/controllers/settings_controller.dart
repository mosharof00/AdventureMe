import 'package:get/get.dart';
import 'package:adventureme/app/routes/app_pages.dart';

class SettingsController extends GetxController {
  final newItineraryNotification = true.obs;
  final trackerNotification = true.obs;
  final anyoneCanSeeItinerary = false.obs;
  final travelTracker = false.obs;

  void toggleNewItinerary(bool value) => newItineraryNotification.value = value;

  void toggleTrackerNotification(bool value) =>
      trackerNotification.value = value;

  void toggleAnyoneCanSee(bool value) => anyoneCanSeeItinerary.value = value;

  void toggleTravelTracker(bool value) => travelTracker.value = value;

  void onChangePassword() => Get.toNamed(Routes.CHANGE_PASSWORD);
}
