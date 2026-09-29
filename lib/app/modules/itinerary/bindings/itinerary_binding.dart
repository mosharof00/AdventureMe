import 'package:get/get.dart';

import '../controllers/itinerary_controller.dart';

class ItineraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItineraryController>(
      () => ItineraryController(),
    );
  }
}
