import 'package:get/get.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/services/map_service.dart';
import 'package:adventureme/app/core/services/permission_service.dart';
import 'package:adventureme/app/core/services/photo_viewer_service.dart';
import 'package:adventureme/app/core/services/trip_prompt_service.dart';
import 'auth_repository.dart';
import 'feed_repository.dart';
import 'home_repository.dart';
import 'product_repository.dart';
import 'trip_repository.dart';

class AppRepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient — permanent, created immediately, shared by all repositories
    Get.put<ApiClient>(ApiClient(), permanent: true);

    // PermissionService — permanent, shared wherever a permission is needed
    Get.put<PermissionService>(PermissionService(), permanent: true);

    // MapService — permanent, shared by every map screen in the app
    Get.put<MapService>(MapService(), permanent: true);

    // TripPromptService — permanent, asks the daily trip questions anywhere
    Get.put<TripPromptService>(TripPromptService(), permanent: true);

    // PhotoViewerService — permanent, opens one or many photos fullscreen
    Get.put<PhotoViewerService>(PhotoViewerService(), permanent: true);

    // Repositories — lazy, created only when first Get.find() is called
    Get.lazyPut<IAuthRepository>(
          () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ITripRepository>(
          () => TripRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<IHomeRepository>(
          () => HomeRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<IFeedRepository>(
          () => FeedRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<IProductRepository>(
          () => ProductRepository(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}