import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';

import '../controllers/create_new_trip_controller.dart';
import 'toggle_setting_card.dart';

class TripPrivacyStep extends GetView<CreateNewTripController> {
  const TripPrivacyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => ToggleSettingCard(
            title: 'Travel Tracker',
            description: 'Turn on your location to let the tracking happen!',
            value: controller.travelTracker.value,
            onChanged: controller.toggleTravelTracker,
          ),
        ),
        16.height,
        Obx(
          () => ToggleSettingCard(
            title: 'Anyone Can See',
            description:
                'Everyone who is using this app can see your itinerary details and tracking records.',
            value: controller.anyoneCanSee.value,
            onChanged: controller.toggleAnyoneCanSee,
          ),
        ),
        16.height,
        Obx(
          () => ToggleSettingCard(
            title: 'Anyone Can share',
            description:
                'This will let anyone can share your story on their social media.',
            value: controller.anyoneCanShare.value,
            onChanged: controller.toggleAnyoneCanShare,
          ),
        ),
      ],
    );
  }
}
