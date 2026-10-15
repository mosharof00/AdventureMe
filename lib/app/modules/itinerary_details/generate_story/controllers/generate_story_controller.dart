import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/trip_models/trip_story_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';

class GenerateStoryController extends GetxController {
  final ITripRepository _repository = Get.find<ITripRepository>();

  String? tripId;

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final storyData = Rxn<TripStoryData>();
  final canShare = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map && arg['tripId'] != null) {
      tripId = arg['tripId'].toString();
    } else if (arg is String) {
      tripId = arg;
    }
    fetchStory();
  }

  Future<void> fetchStory() async {
    final id = tripId;
    if (id == null || id.isEmpty) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'Trip ID not found.';
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await _repository.getTripStory(id);
      if (response.success == true && response.data != null) {
        storyData.value = response.data;
        canShare.value = response.data?.canShare ?? false;
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? 'Unable to load your story.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load your story. Please try again.';
      handleException(e, context: 'Get Trip Story');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCanShare(bool value) => canShare.value = value;

  // ── Getters for UI ──────────────────────────────────
  String get title => storyData.value?.title ?? 'Itinerary Story';
  String get description => storyData.value?.description ?? '';

  List<String> get heroImages =>
      storyData.value?.effectiveCoverPhotos ?? const [];

  String get authorName => storyData.value?.author?.name ?? 'Explorer';
  String get authorAvatar =>
      storyData.value?.author?.avatarUrl ?? HelperUtils.defaultProfileImage;
  bool get isAuthorVerified => storyData.value?.author?.isVerified ?? false;

  bool get isPrivate => storyData.value?.isPrivate ?? true;
  String get visibility => storyData.value?.visibility ?? 'PRIVATE';

  StorySummary? get summary => storyData.value?.summary;

  List<StoryDay> get displayDays =>
      (storyData.value?.days ?? const []).where((d) => d.hasContent).toList();

  void onShare() {}
  void onQrCode() {}
  void onVisibilityTap() {}
}
