import 'package:get/get.dart';

import '../controllers/saved_itineraries_controller.dart';

class SavedItinerariesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavedItinerariesController>(
      () => SavedItinerariesController(),
    );
  }
}
