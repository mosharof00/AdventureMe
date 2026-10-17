import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';

import '../controllers/home_controller.dart';
import '../widgets/country_explored_section.dart';
import '../widgets/current_itinerary_section.dart';
import '../widgets/home_header.dart';
import '../widgets/latest_story_section.dart';
import '../widgets/on_this_day_section.dart';
import '../widgets/story_unfolding_card.dart';
import '../widgets/upcoming_itinerary_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      child: RefreshIndicator(
        onRefresh: controller.refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              const HomeHeader(),
              Obx(() => controller.hasOnThisDayMemory
                  ? Column(
                      children: [
                        24.height,
                        const OnThisDaySection(),
                      ],
                    )
                  : const SizedBox.shrink()),
              Obx(() => controller.hasLatestStory
                  ? Column(
                      children: [
                        24.height,
                        const LatestStorySection(),
                      ],
                    )
                  : const SizedBox.shrink()),
              24.height,
              const CountryExploredSection(),
              24.height,
              const StoryUnfoldingCard(),
              Obx(() => controller.hasCurrentItinerary
                  ? Column(
                      children: [
                        24.height,
                        const CurrentItinerarySection(),
                      ],
                    )
                  : const SizedBox.shrink()),
              Obx(() => controller.hasUpcomingItinerary
                  ? Column(
                      children: [
                        24.height,
                        const UpcomingItinerarySection(),
                      ],
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
