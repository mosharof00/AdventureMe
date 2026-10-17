import 'package:adventureme/app/modules/archive/controllers/archive_controller.dart';
import 'package:adventureme/app/modules/home/controllers/home_controller.dart';
import 'package:adventureme/app/modules/itinerary/controllers/itinerary_controller.dart';
import 'package:adventureme/app/modules/products/controllers/products_controller.dart';
import 'package:adventureme/app/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import '../controllers/main_page_controller.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPageController>(() => MainPageController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ItineraryController>(() => ItineraryController(), fenix: true);
    Get.lazyPut<ArchiveController>(() => ArchiveController(), fenix: true);
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
