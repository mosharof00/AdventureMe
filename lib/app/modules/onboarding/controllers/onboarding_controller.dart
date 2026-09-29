import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../../../core/services/local_store_service.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  static const int totalPages = 4;

  final pageController = PageController();
  final currentPage = 0.obs;

  final List<AssetGenImage> onboardingImages = [
    Assets.images.onboarding1,
    Assets.images.onboarding2,
    Assets.images.onboarding3,
    Assets.images.onboarding4,
  ];

  void onPageChanged(int index) => currentPage.value = index;

  Future<void> nextPage() async {
    if (currentPage.value < totalPages - 1) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await completeOnboarding();
    }
  }

  Future<void> completeOnboarding() async {
    HiveService.setOnBoardShowed(true);
    HelperUtils.isOnboard = true;
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
