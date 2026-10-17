import 'package:get/get.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/data/repositories/home_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IHomeRepository>()) {
      Get.lazyPut<IHomeRepository>(
        () => HomeRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
