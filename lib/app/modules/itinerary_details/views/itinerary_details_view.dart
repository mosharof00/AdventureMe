import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';

import '../controllers/itinerary_details_controller.dart';
import '../widgets/photo_chapter_tab.dart';
import '../widgets/timeline_tab.dart';

class ItineraryDetailsView extends GetView<ItineraryDetailsController> {
  const ItineraryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: CustomAppBar(
          title: 'Itinerary Details',
          showBackButton: true,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // const SizedBox(height: kToolbarHeight),
            TabBar(
              labelColor: AppColor.secondary,
              unselectedLabelColor: AppColor.hintText,
              indicatorColor: AppColor.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              dividerColor: AppColor.hintText.withValues(alpha: 0.15),
              labelStyle: context.titleSmall.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: context.titleSmall,
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Photo Chapter'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [TimelineTab(), PhotoChapterTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

