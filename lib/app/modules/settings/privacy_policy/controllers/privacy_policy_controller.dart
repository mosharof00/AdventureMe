import 'package:get/get.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';

class PrivacySection {
  const PrivacySection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class PrivacyPolicyController extends GetxController {
  final intro =
      'We may collect information about you in a variety of ways, specifically tailored to provide a seamless travel-tracking experience:';

  final sections = const <PrivacySection>[
    PrivacySection(
      title: 'Personal Data',
      body:
          'Demographic and other personally identifiable information (such as your name, email and profile picture) that you voluntarily give to us when choosing to participate in various activities related to the Application, such as registering an account.',
    ),
    PrivacySection(
      title: 'Geolocation Data',
      body:
          'We access your location-based information for the purpose of automated tracking and checkpoint creation while your Travel Tracker is active.',
    ),
    PrivacySection(
      title: 'User-Generated Content',
      body:
          'Data that you contribute, including trip titles, journal notes, photos, and manually edited checkpoints.',
    ),
    PrivacySection(
      title: 'Usage Data',
      body:
          'Information automatically collected when using the Application, such as your device type, operating system, and tracking settings (e.g., Battery Saver mode).',
    ),
  ];

  void onBackToHome() => HelperUtils.backToMain();
}
