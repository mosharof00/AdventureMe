import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/modules/itinerary/controllers/itinerary_controller.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/modules/itinerary_details/widgets/story_generating_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';

enum TripDetailsStatus { pending, ongoing, completed }

class TripCheckpoint {
  const TripCheckpoint({
    required this.title,
    required this.time,
    required this.duration,
    required this.label,
    required this.quote,
    required this.photos,
  });

  final String title;
  final String time;
  final String duration;
  final String label;
  final String quote;
  final List<String> photos;
}

class TrackingDay {
  const TrackingDay({
    required this.dayLabel,
    required this.date,
    required this.checkpoints,
  });

  final String dayLabel;
  final String date;
  final List<TripCheckpoint> checkpoints;
}

class ItineraryDetailsController extends GetxController {
  late final TripDetailsStatus status;

  /// Trip opened from the Itinerary list (details API not integrated yet).
  TripListItem? trip;

  // ── Trip info ────────────────────────────────────────
  String tripTitle = 'Florida Adventure';
  String tripRoute = 'Starting: Florida | Destined: Brazil';
  String tripDates = 'Mar 10 to Mar 13, 2026';

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is TripListItem) {
      trip = arg;
      status = switch (arg.status) {
        TripStatus.completed => TripDetailsStatus.completed,
        TripStatus.active || TripStatus.paused => TripDetailsStatus.ongoing,
        _ => TripDetailsStatus.pending,
      };
      if (Get.isRegistered<ItineraryController>()) {
        final itinerary = Get.find<ItineraryController>();
        tripTitle = arg.title ?? tripTitle;
        tripRoute = itinerary.route(arg);
        tripDates = itinerary.dateRange(arg);
      }
    } else {
      status = arg is TripDetailsStatus ? arg : TripDetailsStatus.pending;
    }
  }

  // ── Status helpers ───────────────────────────────────
  String get statusLabel => switch (status) {
    TripDetailsStatus.pending => 'Pending',
    TripDetailsStatus.ongoing => 'Ongoing',
    TripDetailsStatus.completed => 'Completed',
  };

  bool get isPending => status == TripDetailsStatus.pending;
  bool get isOngoing => status == TripDetailsStatus.ongoing;
  bool get isCompleted => status == TripDetailsStatus.completed;

  /// Elapsed / total time shown on the timer.
  String get timerText => switch (status) {
    TripDetailsStatus.pending => '00:00:00',
    TripDetailsStatus.ongoing => '32:12:54',
    TripDetailsStatus.completed => '72:12:54',
  };

  bool isDayDone(int index) => switch (status) {
    TripDetailsStatus.pending => false,
    TripDetailsStatus.ongoing => index < days.length - 1,
    TripDetailsStatus.completed => true,
  };

  /// Label of the photo button on a completed day card.
  String get photoActionLabel => isCompleted ? 'Edit Photos' : 'Upload Photos';

  // ── Tracking data ────────────────────────────────────
  final days = const <TrackingDay>[
    TrackingDay(
      dayLabel: 'Day 1',
      date: 'May 7, 2026',
      checkpoints: [
        TripCheckpoint(
          title: 'Landed in Naples',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 1',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=600',
            'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400',
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
          ],
        ),
        TripCheckpoint(
          title: 'Ferry to Positano',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 2',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600',
            'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400',
            'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
          ],
        ),
        TripCheckpoint(
          title: 'Sunset Walk',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 3',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1503803548695-c2a7b4a5b875?w=600',
            'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400',
            'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?w=400',
          ],
        ),
      ],
    ),
    TrackingDay(
      dayLabel: 'Day 2',
      date: 'May 8, 2026',
      checkpoints: [
        TripCheckpoint(
          title: 'Paths of the Gods Hike',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 1',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
            'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=400',
          ],
        ),
        TripCheckpoint(
          title: 'Lunch in Nocelle',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 2',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600',
            'https://images.unsplash.com/photo-1533777324565-a040eb52facd?w=400',
          ],
        ),
      ],
    ),
    TrackingDay(
      dayLabel: 'Day 3',
      date: 'May 9, 2026',
      checkpoints: [
        TripCheckpoint(
          title: 'Old Town Stroll',
          time: '10:30 AM',
          duration: '30 min',
          label: 'Checkpoint 1',
          quote:
              'Ceremonial umbrellas through the village as part of a communal journey to purify both the human soul and the universe.',
          photos: [
            'https://images.unsplash.com/photo-1499678329028-101435549a4e?w=600',
            'https://images.unsplash.com/photo-1513581166391-887a96ddeafd?w=400',
          ],
        ),
      ],
    ),
  ];

  /// Days that already have tracked data (for the Photo Chapter tab).
  List<TrackingDay> get memoryDays => [
    for (var i = 0; i < days.length; i++)
      if (isDayDone(i)) days[i],
  ];

  // ── Actions ──────────────────────────────────────────
  void onStartOrEnd() {}
  void onEditTrip() {}
  void onViewMap() => Get.toNamed(
    Routes.VIEW_ITINERARY_MAP,
    arguments: {'days': days, 'title': tripTitle},
  );
  void onGenerateStory() => StoryGeneratingDialog.show();
  void onManageDayPhotos(int day, String date) => Get.toNamed(
    Routes.MANAGE_DAY_PHOTOS,
    arguments: {'day': day, 'date': date},
  );
  void onCheckpointDetails() {}

  void onCancelTrip() {
    AppBottomSheet.show(
      sticker: 'assets/images/cry_sticker.png',
      title: 'Are You Sure You Want to Delete?',
      description:
          'Deleting your trip will lose all the data from the beginning to the end.',
      actionWidget: Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: 'Keep',
              color: AppColor.primaryDisable,
              textColor: AppColor.primary,
              onTap: keepTrip,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GlobalButton(
              text: 'Cancel Trip',
              color: AppColor.error,
              onTap: confirmCancel,
            ),
          ),
        ],
      ),
    );
  }

  void confirmCancel() {
    Get.back(); // close sheet
    Get.back(); // leave details screen
  }

  void keepTrip() => Get.back();
}
