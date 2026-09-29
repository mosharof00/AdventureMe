import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/user_models/user_model.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/routes/app_pages.dart';

class ProfileBadge {
  const ProfileBadge({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final int color;
}

class SavedItinerary {
  const SavedItinerary({
    required this.title,
    required this.location,
    required this.imageUrl,
  });

  final String title;
  final String location;
  final String imageUrl;
}

class ProfileController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  // ── User (from /auth/me) ─────────────────────────────
  final user = Rxn<UserData>();
  final isLoading = false.obs;

  /// Kept separate from [user] because Edit Profile reads and updates them.
  final userName = ''.obs;
  final bio = ''.obs;

  String get avatarUrl => user.value?.hasAvatar == true
      ? user.value!.avatar!
      : HelperUtils.defaultProfileImage;

  bool get isVerified => user.value?.emailVerified == true;

  String get joinedYear => user.value?.createdAt?.year.toString() ?? '--';

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final response = await _authRepository.getMe();
      final data = response.data;
      if (response.success == true && data != null) applyUser(data);
    } catch (e) {
      handleException(e, context: 'Profile - Get Me');
    } finally {
      isLoading.value = false;
    }
  }

  /// Also used by Edit Profile after a successful update. The update response
  /// omits some fields (e.g. created_at, email_verified), so those are kept
  /// from the current user.
  void applyUser(UserData data) {
    final current = user.value;
    user.value = current == null ? data : current.merge(data);
    userName.value = user.value?.name ?? '';
    bio.value = user.value?.about ?? '';
  }

  // ── Mock data (no API yet) ───────────────────────────
  final adventureStreak = 43;

  final upcomingAdventure = 3;
  final storiesCreated = 12;
  final completedItinerary = 20;

  final yearsSinceTrip = '00';
  final monthsSinceTrip = '03';
  final daysSinceTrip = '60';

  final storyViews = '18k';
  final storyShares = '56';
  final itinerarySaves = '480';

  final hasNotification = true.obs;

  final badges = const <ProfileBadge>[
    ProfileBadge(
      title: 'Beginner',
      subtitle: 'Below 10 Post',
      color: 0xFFE8B923,
    ),
    ProfileBadge(
      title: 'Intermediate',
      subtitle: '20+ Itinerary Post',
      color: 0xFFF08A24,
    ),
    ProfileBadge(
      title: 'Advanced',
      subtitle: '50+ Stories',
      color: 0xFF3BE2E8,
    ),
  ];

  final savedItineraries = const <SavedItinerary>[
    SavedItinerary(
      title: 'Chasing Sunsets Along the Amalfi Coast!',
      location: 'Mount Fuji, Japan',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    ),
    SavedItinerary(
      title: 'A Day In North Korea...',
      location: 'Nuclear Beach, North Korea',
      imageUrl:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
    ),
  ];

  void onEditProfile() => Get.toNamed(Routes.EDIT_PROFILE);

  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  void onViewAllItineraries() => Get.toNamed(Routes.SAVED_ITINERARIES);
}
