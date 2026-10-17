import 'package:get/get.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/data/repositories/feed_repository.dart';

import '../controllers/archive_controller.dart';

class ArchiveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IFeedRepository>()) {
      Get.lazyPut<IFeedRepository>(
        () => FeedRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<ArchiveController>(
      () => ArchiveController(),
      fenix: true,
    );
  }
}
