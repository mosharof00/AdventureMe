import 'package:get/get.dart';

import '../controllers/archive_details_controller.dart';

class ArchiveDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchiveDetailsController>(() => ArchiveDetailsController());
  }
}
