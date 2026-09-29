import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/show_empty_result.dart';

import '../controllers/profile_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/badges_section.dart';
import '../widgets/last_trip_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_top_bar.dart';
import '../widgets/saved_itinerary_section.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: Obx(() {
                // Full-screen loader only on first load; pull-to-refresh keeps
                // the current content visible.
                if (controller.user.value == null) {
                  return controller.isLoading.value
                      ? const GlobalLoading()
                      : ShowEmptyResult(
                          title: 'Couldn\'t load your profile',
                          desc: 'Please check your connection and try again.',
                          refreshOnTap: controller.fetchProfile,
                        );
                }
                return const _ProfileContent();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends GetView<ProfileController> {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: controller.fetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          children: [
            8.height,
            const ProfileHeader(),
            16.height,
            const ProfileStatsCard(),
            16.height,
            const LastTripCard(),
            20.height,
            const ProfileInfoCard(),
            20.height,
            const ActivityCard(),
            20.height,
            const BadgesSection(),
            20.height,
            const SavedItinerarySection(),
          ],
        ),
      ),
    );
  }
}
