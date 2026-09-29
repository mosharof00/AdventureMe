import 'package:get/get.dart';

import '../controllers/create_new_trip_controller.dart';

class CreateNewTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewTripController>(
      () => CreateNewTripController(),
    );
  }
}
