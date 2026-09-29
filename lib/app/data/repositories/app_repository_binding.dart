import 'package:get/get.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/services/map_service.dart';
import 'auth_repository.dart';
import 'product_repository.dart';
import 'trip_repository.dart';

class AppRepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient — permanent, created immediately, shared by all repositories
    Get.put<ApiClient>(ApiClient(), permanent: true);

    // MapService — permanent, shared by every map screen in the app
    Get.put<MapService>(MapService(), permanent: true);

    // Repositories — lazy, created only when first Get.find() is called
    Get.lazyPut<IAuthRepository>(
          () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ITripRepository>(
          () => TripRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<IProductRepository>(
          () => ProductRepository(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}