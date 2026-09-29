import 'package:get/get.dart';

import '../controllers/manage_day_photos_controller.dart';

class ManageDayPhotosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageDayPhotosController>(
      () => ManageDayPhotosController(),
    );
  }
}
