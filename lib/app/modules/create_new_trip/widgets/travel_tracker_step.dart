import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/create_new_trip_controller.dart';
import 'toggle_setting_card.dart';

class TravelTrackerStep extends GetView<CreateNewTripController> {
  const TravelTrackerStep({super.key});

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
        80.height,
        Obx(
          () => AppSvgIcon(
            controller.travelTracker.value
                ? Assets.icons.locationIcon
                : Assets.icons.locationCrossIcon,
            size: 90.sp,
            color: AppColor.primary,
          ),
        ),
      ],
    );
  }
}
