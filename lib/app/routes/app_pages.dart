import 'package:get/get.dart';

import '../modules/archive/archive_details/bindings/archive_details_binding.dart';
import '../modules/archive/archive_details/views/archive_details_view.dart';
import '../modules/archive/bindings/archive_binding.dart';
import '../modules/archive/views/archive_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/change_password/bindings/change_password_binding.dart';
import '../modules/auth/change_password/views/change_password_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/auth/verify_otp/bindings/verify_otp_binding.dart';
import '../modules/auth/verify_otp/views/verify_otp_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/create_new_trip/bindings/create_new_trip_binding.dart';
import '../modules/create_new_trip/views/create_new_trip_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/itinerary/bindings/itinerary_binding.dart';
import '../modules/itinerary/views/itinerary_view.dart';
import '../modules/itinerary_details/bindings/itinerary_details_binding.dart';
import '../modules/itinerary_details/generate_story/bindings/generate_story_binding.dart';
import '../modules/itinerary_details/generate_story/views/generate_story_view.dart';
import '../modules/itinerary_details/manage_day_photos/bindings/manage_day_photos_binding.dart';
import '../modules/itinerary_details/manage_day_photos/views/manage_day_photos_view.dart';
import '../modules/itinerary_details/view_itinerary_map/bindings/view_itinerary_map_binding.dart';
import '../modules/itinerary_details/view_itinerary_map/views/view_itinerary_map_view.dart';
import '../modules/itinerary_details/views/itinerary_details_view.dart';
import '../modules/main_page/bindings/main_page_binding.dart';
import '../modules/main_page/views/main_page_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/profile/edit_profile/views/edit_profile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/settings/privacy_policy/views/privacy_policy_view.dart';
import '../modules/settings/saved_itineraries/bindings/saved_itineraries_binding.dart';
import '../modules/settings/saved_itineraries/views/saved_itineraries_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_PAGE,
      page: () => const MainPageView(),
      binding: MainPageBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      children: [
        GetPage(
          name: _Paths.LOGIN,
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: _Paths.REGISTER,
          page: () => const RegisterView(),
          binding: RegisterBinding(),
        ),
        GetPage(
          name: _Paths.FORGOT_PASSWORD,
          page: () => const ForgotPasswordView(),
          binding: ForgotPasswordBinding(),
        ),
        GetPage(
          name: _Paths.VERIFY_OTP,
          page: () => const VerifyOtpView(),
          binding: VerifyOtpBinding(),
        ),
        GetPage(
          name: _Paths.CHANGE_PASSWORD,
          page: () => const ChangePasswordView(),
          binding: ChangePasswordBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.ITINERARY,
      page: () => const ItineraryView(),
      binding: ItineraryBinding(),
    ),
    GetPage(
      name: _Paths.ARCHIVE,
      page: () => const ArchiveView(),
      binding: ArchiveBinding(),
      children: [
        GetPage(
          name: _Paths.ARCHIVE_DETAILS,
          page: () => const ArchiveDetailsView(),
          binding: ArchiveDetailsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CREATE_NEW_TRIP,
      page: () => const CreateNewTripView(),
      binding: CreateNewTripBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.ITINERARY_DETAILS,
      page: () => const ItineraryDetailsView(),
      binding: ItineraryDetailsBinding(),
      children: [
        GetPage(
          name: _Paths.MANAGE_DAY_PHOTOS,
          page: () => const ManageDayPhotosView(),
          binding: ManageDayPhotosBinding(),
        ),
        GetPage(
          name: _Paths.VIEW_ITINERARY_MAP,
          page: () => const ViewItineraryMapView(),
          binding: ViewItineraryMapBinding(),
        ),
        GetPage(
          name: _Paths.GENERATE_STORY,
          page: () => const GenerateStoryView(),
          binding: GenerateStoryBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.SAVED_ITINERARIES,
      page: () => const SavedItinerariesView(),
      binding: SavedItinerariesBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
  ];
}
