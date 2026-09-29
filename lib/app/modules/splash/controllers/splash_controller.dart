import 'package:get/get.dart';

import '../../../core/services/local_store_service.dart';
import '../../../core/services/map_service.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  Future<void> setupApp() async {
    await Future.delayed(const Duration(seconds: 1));

    // Ask for location up-front (nice rationale dialog + OS prompt) so map
    // screens later open instantly with permission already resolved.
    await Get.find<MapService>().requestLocationOnStartup();

    navigateToScreen();
  }

  Future<void> navigateToScreen() async {
    final onboardShowed = await HiveService.getOnBoardShowed();
    HelperUtils.isOnboard = onboardShowed;

    if (!onboardShowed) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }

    final isLoggedIn = await HelperUtils.checkLoginStatus()
        .timeout(const Duration(seconds: 15), onTimeout: () => false);

    Get.offAllNamed(isLoggedIn ? Routes.MAIN_PAGE : Routes.LOGIN);
  }

  @override
  void onInit() {
    setupApp();
    super.onInit();
  }
}
