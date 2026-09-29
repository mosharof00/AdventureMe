import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/show_empty_result.dart';

import '../controllers/itinerary_controller.dart';
import '../widgets/completed_itinerary_card.dart';
import '../widgets/itinerary_header.dart';
import '../widgets/itinerary_tabs.dart';
import '../widgets/pending_itinerary_card.dart';

class ItineraryView extends GetView<ItineraryController> {
  const ItineraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBar = math.max(16.h, MediaQuery.paddingOf(context).top);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      // Pull-down overscroll lands on the outer scroll of a NestedScrollView,
      // so the indicator lives here and refreshes the visible tab.
      child: RefreshIndicator(
        color: AppColor.primary,
        edgeOffset: statusBar,
        notificationPredicate: (notification) => notification.depth == 0,
        onRefresh: () => controller.refreshTab(controller.selectedTab.value),
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _ItineraryHeaderDelegate(statusBar: statusBar),
              ),
            ),
          ],
          body: TabBarView(
            controller: controller.tabController,
            children: [
              for (final tab in ItineraryTab.values) _TripTabList(tab: tab),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header image scrolls away while search + tabs stay pinned below the
/// status bar.
class _ItineraryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ItineraryHeaderDelegate({required this.statusBar});

  final double statusBar;

  static double get _headerHeight => ItineraryHeader.height;
  static double get _gap => 12.h;
  static double get _content => ItinerarySearchAndTabs.contentHeight;

  @override
  double get maxExtent => _headerHeight + _gap + _content;

  @override
  double get minExtent => math.min(statusBar + _content, maxExtent);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final bandOpacity =
        ((shrinkOffset - (range - statusBar)) / statusBar).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColor.bgGradient1),
        Positioned(
          top: -shrinkOffset,
          left: 0,
          right: 0,
          height: _headerHeight,
          child: const ItineraryHeader(),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBar,
          child: IgnorePointer(
            child: Opacity(
              opacity: bandOpacity,
              child: const ColoredBox(color: AppColor.bgGradient1),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _content,
          child: const ItinerarySearchAndTabs(),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_ItineraryHeaderDelegate oldDelegate) =>
      oldDelegate.statusBar != statusBar;
}

class _TripTabList extends GetView<ItineraryController> {
  const _TripTabList({required this.tab});

  final ItineraryTab tab;

  @override
  Widget build(BuildContext context) {
    final state = controller.stateOf(tab);

    return Builder(
      builder: (context) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical &&
              notification.metrics.extentAfter < 300) {
            controller.loadMore(tab);
          }
          return false;
        },
        child: CustomScrollView(
          key: PageStorageKey<String>('itinerary_${tab.name}'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            Obx(() => _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TripTabState state) {
    final items = state.items;

    if (items.isEmpty) {
      if (state.isLoading.value) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: GlobalLoading()),
        );
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ShowEmptyResult(
          title: state.hasError.value ? "Couldn't load trips" : 'No trips found',
          desc: state.hasError.value
              ? 'Please check your connection and try again.'
              : controller.searchController.text.trim().isNotEmpty
                  ? 'Try a different search.'
                  : 'Your ${tab == ItineraryTab.all ? '' : '${tab.label.toLowerCase()} '}trips will show up here.',
          refreshOnTap: () => controller.refreshTab(tab),
        ),
      );
    }

    final showLoader = state.isLoadingMore.value;
    return SliverPadding(
      padding: EdgeInsets.only(top: 4.h, bottom: 24.h),
      sliver: SliverList.separated(
        itemCount: items.length + (showLoader ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (_, index) {
          if (index >= items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(child: GlobalLoading(size: 28.sp)),
            );
          }
          final trip = items[index];
          return trip.isCompleted
              ? CompletedItineraryCard(trip: trip)
              : PendingItineraryCard(trip: trip);
        },
      ),
    );
  }
}
