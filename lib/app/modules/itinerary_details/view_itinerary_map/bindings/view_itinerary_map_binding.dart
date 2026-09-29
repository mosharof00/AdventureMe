import 'package:get/get.dart';

import '../controllers/view_itinerary_map_controller.dart';

class ViewItineraryMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewItineraryMapController>(
      () => ViewItineraryMapController(),
    );
  }
}
