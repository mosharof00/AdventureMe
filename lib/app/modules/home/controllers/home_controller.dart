import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/user_models/user_model.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
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

  // ── User ─────────────────────────────────────────────
  final user = Rxn<UserData>();
  final isUserLoading = false.obs;

  String get avatarUrl => user.value?.hasAvatar == true
      ? user.value!.avatar!
      : HelperUtils.defaultProfileImage;

  @override
  void onInit() {
    super.onInit();
    fetchUser();
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

  // ── On This Day ──────────────────────────────────────
  final onThisDayDate = 'June 10, 2025';
  final onThisDayTitle = 'Remember the gelato you had in Florence?';
  final onThisDayDesc = 'Some moments stay with us forever!';
  final onThisDayImage =
      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400';

  // ── Latest Story ─────────────────────────────────────
  final latestStoryTitle = 'Our Amalfi Coast Story';
  final latestStoryDate = 'June 10, 2025';
  final latestStoryReadTime = '4 min read';
  final latestStoryDesc =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  final latestStoryImage =
      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600';
  final latestStoryStatus = 'Pending';

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

  // ── Current Itinerary ────────────────────────────────
  final currentItineraryTitle = 'Bali Visit';
  final currentItineraryDesc =
      'Track your current trip and progress in a live location model';
  final currentItineraryMapImage =
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400';

  // ── Upcoming Itinerary ───────────────────────────────
  final upcomingTitle = 'Florida Adventure';
  final upcomingStatus = 'Pending';
  final upcomingRoute = 'Starting: Florida | Destined: Brazil';
  final upcomingDates = 'May 7 to May 9, 2026';

  void onViewDetails() {}
  void onOpenStory() {}
  void onViewAll() {}
  void onCreateStory() => Get.toNamed(Routes.CREATE_NEW_TRIP);
  void onProfileTap() {}
}
