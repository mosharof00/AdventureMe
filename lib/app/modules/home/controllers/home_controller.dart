import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/home_models/current_itinerary_model.dart';
import 'package:adventureme/app/data/models/home_models/latest_story_model.dart';
import 'package:adventureme/app/data/models/home_models/on_this_day_model.dart';
import 'package:adventureme/app/data/models/home_models/upcoming_itinerary_model.dart';
import 'package:adventureme/app/data/models/user_models/user_model.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/data/repositories/home_repository.dart';
import 'package:adventureme/app/modules/itinerary/controllers/itinerary_controller.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/app/routes/app_pages.dart';

class CountryExploredItem {
  const CountryExploredItem({
    required this.title,
    required this.location,
    required this.imageUrl,
  });

  final String title;
  final String location;
  final String imageUrl;
}

class HomeController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();
  final IHomeRepository _homeRepository = Get.find<IHomeRepository>();

  // ── User ─────────────────────────────────────────────
  final user = Rxn<UserData>();
  final isUserLoading = false.obs;

  String get avatarUrl => user.value?.hasAvatar == true
      ? user.value!.avatar!
      : HelperUtils.defaultProfileImage;

  // ── On This Day ──────────────────────────────────────
  final onThisDayData = Rxn<OnThisDayData>();
  final isOnThisDayLoading = false.obs;

  static const String defaultOnThisDayImage =
      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400';

  bool get hasOnThisDayMemory {
    final data = onThisDayData.value;
    if (data == null) return false;
    return data.hasMemory == true;
  }

  String get onThisDayDate => onThisDayData.value?.formattedDate ?? '';
  String get onThisDayTitle => onThisDayData.value?.title ?? '';
  String get onThisDayDesc =>
      onThisDayData.value?.subtitle ??
      onThisDayData.value?.memory?.text ??
      '';
  String get onThisDayImage {
    final url = onThisDayData.value?.imageUrl;
    if (url != null && url.trim().isNotEmpty) {
      return url.trim();
    }
    return defaultOnThisDayImage;
  }

  // ── Latest Story ─────────────────────────────────────
  final latestStoryData = Rxn<HomeLatestStoryData>();
  final isLatestStoryLoading = false.obs;

  bool get hasLatestStory {
    final data = latestStoryData.value;
    if (data == null) return false;
    return data.hasStory == true && data.story != null;
  }

  HomeStory? get latestStory => latestStoryData.value?.story;

  String get latestStoryTitle => latestStory?.title ?? '';
  String get latestStoryDate => latestStory?.formattedDate ?? '';
  String get latestStoryReadTime => latestStory?.readTime ?? '';
  String get latestStoryDesc => latestStory?.snippet ?? '';
  String get latestStoryImage => latestStory?.coverUrl ?? '';
  String get latestStoryStatus =>
      latestStory?.isPublished == true ? 'Published' : 'Draft';

  // ── Current Itinerary ────────────────────────────────
  final currentItineraryData = Rxn<CurrentItineraryData>();
  final isCurrentItineraryLoading = false.obs;

  bool get hasCurrentItinerary {
    final data = currentItineraryData.value;
    if (data == null) return false;
    return data.hasCurrentTrip == true && data.trip != null;
  }

  CurrentItineraryTrip? get currentTrip => currentItineraryData.value?.trip;
  String get currentItineraryTitle => currentTrip?.title ?? '';
  String get currentItineraryDesc => currentTrip?.description ?? '';
  String get currentItineraryMapImage => currentTrip?.thumbnailUrl ?? '';

  // ── Upcoming Itinerary ───────────────────────────────
  final upcomingItineraryData = Rxn<UpcomingItineraryData>();
  final isUpcomingItineraryLoading = false.obs;

  bool get hasUpcomingItinerary {
    final data = upcomingItineraryData.value;
    if (data == null) return false;
    return data.hasUpcoming == true &&
        (data.featured != null || data.items.isNotEmpty);
  }

  UpcomingItineraryItem? get upcomingFeatured =>
      upcomingItineraryData.value?.featured ??
      (upcomingItineraryData.value?.items.isNotEmpty == true
          ? upcomingItineraryData.value!.items.first
          : null);

  String get upcomingTitle => upcomingFeatured?.title ?? '';
  String get upcomingStatus =>
      upcomingFeatured?.statusLabel ?? upcomingFeatured?.status ?? '';
  String get upcomingRoute =>
      upcomingFeatured?.routeDisplay ??
      (upcomingFeatured != null
          ? 'Starting: ${upcomingFeatured?.startingPlace ?? ""} | Destined: ${upcomingFeatured?.destinedPlace ?? ""}'
          : '');
  String get upcomingDates => upcomingFeatured?.dateDisplay ?? '';

  // ── Country Explored ─────────────────────────────────
  final countries = const <CountryExploredItem>[
    CountryExploredItem(
      title: 'Chasing Sunsets Along the Amalfi Coast',
      location: 'Amalfi Coast, Italy',
      imageUrl:
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=600',
    ),
    CountryExploredItem(
      title: 'A Day In North Korea...',
      location: 'Nuclear Beach, North Korea',
      imageUrl:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=600',
    ),
  ];

  // ── Story Unfolding ──────────────────────────────────
  final unfoldingImages = const [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200',
    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=200',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUser();
    fetchOnThisDay();
    fetchLatestStory();
    fetchCurrentItinerary();
    fetchUpcomingItinerary();
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchUser(),
      fetchOnThisDay(),
      fetchLatestStory(),
      fetchCurrentItinerary(),
      fetchUpcomingItinerary(),
    ]);
  }

  Future<void> fetchUser() async {
    if (isUserLoading.value) return;
    try {
      isUserLoading.value = true;
      final response = await _authRepository.getMe();
      if (response.success == true) user.value = response.data;
    } catch (e) {
      handleException(e, context: 'Home - Get Me');
    } finally {
      isUserLoading.value = false;
    }
  }

  String _getOneYearAgoDateString() {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    return DateFormat('yyyy-MM-dd').format(oneYearAgo);
  }

  Future<void> fetchOnThisDay() async {
    try {
      isOnThisDayLoading.value = true;
      final dateStr = _getOneYearAgoDateString();
      final response = await _homeRepository.getOnThisDay(dateStr);
      if (response.success == true && response.data != null) {
        onThisDayData.value = response.data;
      } else {
        onThisDayData.value = null;
      }
    } catch (e) {
      onThisDayData.value = null;
    } finally {
      isOnThisDayLoading.value = false;
    }
  }

  Future<void> fetchLatestStory() async {
    try {
      isLatestStoryLoading.value = true;
      final response = await _homeRepository.getLatestStory();
      if (response.success == true && response.data != null) {
        latestStoryData.value = response.data;
      } else {
        latestStoryData.value = null;
      }
    } catch (e) {
      latestStoryData.value = null;
    } finally {
      isLatestStoryLoading.value = false;
    }
  }

  Future<void> fetchCurrentItinerary() async {
    try {
      isCurrentItineraryLoading.value = true;
      final response = await _homeRepository.getCurrentItinerary();
      if (response.success == true && response.data != null) {
        currentItineraryData.value = response.data;
      } else {
        currentItineraryData.value = null;
      }
    } catch (e) {
      currentItineraryData.value = null;
    } finally {
      isCurrentItineraryLoading.value = false;
    }
  }

  Future<void> fetchUpcomingItinerary() async {
    try {
      isUpcomingItineraryLoading.value = true;
      final response = await _homeRepository.getUpcomingItinerary();
      if (response.success == true && response.data != null) {
        upcomingItineraryData.value = response.data;
      } else {
        upcomingItineraryData.value = null;
      }
    } catch (e) {
      upcomingItineraryData.value = null;
    } finally {
      isUpcomingItineraryLoading.value = false;
    }
  }

  void onViewDetails() {
    final tripId = onThisDayData.value?.trip?.id;
    if (tripId != null && tripId.isNotEmpty) {
      Get.toNamed(Routes.ITINERARY_DETAILS, arguments: tripId);
    }
  }

  void onViewCurrentDetails() {
    final tripId = currentTrip?.id;
    if (tripId != null && tripId.isNotEmpty) {
      Get.toNamed(Routes.ITINERARY_DETAILS, arguments: tripId);
    }
  }

  void onViewUpcomingDetails() {
    final tripId = upcomingFeatured?.id;
    if (tripId != null && tripId.isNotEmpty) {
      Get.toNamed(Routes.ITINERARY_DETAILS, arguments: tripId);
    }
  }

  void onOpenStory() {
    final tripId = latestStory?.tripId ?? latestStory?.trip?.id;
    if (tripId != null && tripId.isNotEmpty) {
      Get.toNamed(
        Routes.GENERATE_STORY,
        arguments: {'tripId': tripId},
      );
    }
  }

  void onViewAll() {
    onViewAllUpcoming();
  }

  void onViewAllUpcoming() {
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(1);
    } else {
      Get.toNamed(Routes.SAVED_ITINERARIES);
    }
  }

  Future<void> onCreateStory() async {
    final created = await Get.toNamed(Routes.CREATE_NEW_TRIP);
    if (created != null) {
      if (Get.isRegistered<MainPageController>()) {
        Get.find<MainPageController>().changePage(1);
      }
      if (Get.isRegistered<ItineraryController>()) {
        Get.find<ItineraryController>().refreshAll();
      }
    }
  }


  void onProfileTap() {}
}
