import 'package:get/get.dart';

import '../controllers/generate_story_controller.dart';

class GenerateStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerateStoryController>(
      () => GenerateStoryController(),
    );
  }
}
