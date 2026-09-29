import 'package:get/get.dart';
import 'package:adventureme/app/modules/itinerary_details/controllers/itinerary_details_controller.dart';
import 'package:adventureme/app/routes/app_pages.dart';

enum ItineraryTab { all, pending, ongoing, completed }

class PendingItinerary {
  const PendingItinerary({
    required this.title,
    required this.route,
    required this.dateRange,
    this.status = 'Pending',
  });

  final String title;
  final String route;
  final String dateRange;
  final String status;
}

class CompletedItinerary {
  const CompletedItinerary({
    required this.title,
    required this.location,
    required this.dateRange,
    required this.trackingHours,
    required this.imageUrl,
  });

  final String title;
  final String location;
  final String dateRange;
  final String trackingHours;
  final String imageUrl;
}

class ItineraryController extends GetxController {
  final selectedTab = ItineraryTab.all.obs;

  // ── Stats ────────────────────────────────────────────
  final countriesVisited = 32;
  final totalCountries = 195;

  double get worldPercent => countriesVisited / totalCountries;
  int get worldPercentLabel => (worldPercent * 100).round();

  void changeTab(ItineraryTab tab) => selectedTab.value = tab;

  // ── Pending list ─────────────────────────────────────
  final pendingList = const <PendingItinerary>[
    PendingItinerary(
      title: 'Florida Adventure',
      route: 'Starting: Florida | Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026',
    ),
    PendingItinerary(
      title: 'Miami Adventure',
      route: 'Starting: Florida | Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026',
    ),
  ];

  // ── Ongoing list (tracking started) ──────────────────
  final ongoingList = const <PendingItinerary>[
    PendingItinerary(
      title: 'Bali Adventure',
      route: 'Starting: Florida | Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026',
      status: 'Ongoing',
    ),
  ];

  // ── Completed list ───────────────────────────────────
  final completedList = const <CompletedItinerary>[
    CompletedItinerary(
      title: 'Florida Calling where!',
      location: 'Miami, Florida',
      dateRange: 'Mar 10 to Mar 17, 2026',
      trackingHours: '27 Hours Tracking',
      imageUrl:
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800',
    ),
    CompletedItinerary(
      title: 'Be the Bird and Enjoy the View!',
      location: 'Oceania, Italy',
      dateRange: 'Mar 22 to Mar 27, 2026',
      trackingHours: '27 Hours Tracking',
      imageUrl:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
    ),
    CompletedItinerary(
      title: 'Be the Bird and Enjoy the View!',
      location: 'Oceania, Italy',
      dateRange: 'Mar 22 to Mar 27, 2026',
      trackingHours: '27 Hours Tracking',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    ),
  ];

  void onStartTracking() {}
  void onTrackLive() {}
  void onViewDetails(TripStatus status) =>
      Get.toNamed(Routes.ITINERARY_DETAILS, arguments: status);
  void onShare() {}
  void onScan() {}
  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);
}
