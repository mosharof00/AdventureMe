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
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          children: [
            const HomeHeader(),
            24.height,
            const OnThisDaySection(),
            24.height,
            const LatestStorySection(),
            24.height,
            const CountryExploredSection(),
            24.height,
            const StoryUnfoldingCard(),
            24.height,
            const CurrentItinerarySection(),
            24.height,
            const UpcomingItinerarySection(),
          ],
        ),
      ),
    );
  }
}
