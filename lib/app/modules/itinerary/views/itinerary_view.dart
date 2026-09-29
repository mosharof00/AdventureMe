import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../../itinerary_details/controllers/itinerary_details_controller.dart';
import '../controllers/itinerary_controller.dart';
import '../widgets/completed_itinerary_card.dart';
import '../widgets/itinerary_header.dart';
import '../widgets/itinerary_tabs.dart';
import '../widgets/pending_itinerary_card.dart';

class ItineraryView extends GetView<ItineraryController> {
  const ItineraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ItineraryHeader(),
            22.height,
            const ItineraryTabs(),
            20.height,
            Obx(() => _buildTabContent(controller.selectedTab.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ItineraryTab tab) {
    switch (tab) {
      case ItineraryTab.all:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Upcoming Adventure (${controller.pendingList.length})'),
            12.height,
            ..._pendingCards(),
            24.height,
            _SectionTitle('Ongoing Adventure (${controller.ongoingList.length})'),
            12.height,
            ..._ongoingCards(),
            24.height,
            _SectionTitle(
              'All Completed Itinerary (${controller.completedList.length})',
            ),
            12.height,
            ..._completedCards(),
          ],
        );
      case ItineraryTab.pending:
        return Column(children: _pendingCards());
      case ItineraryTab.ongoing:
        return Column(children: _ongoingCards());
      case ItineraryTab.completed:
        return Column(children: _completedCards());
    }
  }

  List<Widget> _ongoingCards() {
    final cards = <Widget>[];
    for (var i = 0; i < controller.ongoingList.length; i++) {
      cards.add(
        PendingItineraryCard(
          item: controller.ongoingList[i],
          statusColor: const Color(0xFF1E8E5A),
          statusBgColor: const Color(0xFFDDF3E5),
          primaryLabel: 'Track Live',
          onPrimaryTap: controller.onTrackLive,
          onDetailsTap: () => controller.onViewDetails(TripStatus.ongoing),
        ),
      );
      if (i != controller.ongoingList.length - 1) cards.add(16.height);
    }
    return cards;
  }

  List<Widget> _pendingCards() {
    final cards = <Widget>[];
    for (var i = 0; i < controller.pendingList.length; i++) {
      cards.add(
        PendingItineraryCard(
          item: controller.pendingList[i],
          onDetailsTap: () => controller.onViewDetails(TripStatus.pending),
        ),
      );
      if (i != controller.pendingList.length - 1) cards.add(16.height);
    }
    return cards;
  }

  List<Widget> _completedCards() {
    final cards = <Widget>[];
    for (var i = 0; i < controller.completedList.length; i++) {
      cards.add(
        CompletedItineraryCard(
          item: controller.completedList[i],
          onDetailsTap: () => controller.onViewDetails(TripStatus.completed),
        ),
      );
      if (i != controller.completedList.length - 1) cards.add(16.height);
    }
    return cards;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppText(
        title,
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColor.primary,
        ),
      ),
    );
  }
}
