import 'package:get/get.dart';

import '../controllers/itinerary_details_controller.dart';

class ItineraryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItineraryDetailsController>(
      () => ItineraryDetailsController(),
    );
  }
}
