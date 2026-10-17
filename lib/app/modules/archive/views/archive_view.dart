import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/show_empty_result.dart';
import 'package:adventureme/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/archive_controller.dart';
import '../widgets/archive_story_card.dart';

class ArchiveView extends GetView<ArchiveController> {
  const ArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradient.appBgGradient),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.fetchFeed(refresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical &&
                  notification.metrics.extentAfter < 300) {
                controller.loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header that scrolls away
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ArchiveTopBar(),
                      16.height,
                      _buildTitle(context),
                      14.height,
                    ],
                  ),
                ),

                // Pinned search bar that stays on top when scrolling
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    height: 60.h,
                    child: Container(
                      color: AppColor.bgGradient1,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      child: const _SearchBar(),
                    ),
                  ),
                ),

                // Feeds list or loading / error states
                Obx(() {
                  if (controller.isLoading.value) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: const Center(child: GlobalLoading()),
                      ),
                    );
                  }

                  if (controller.hasError.value && controller.items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'Failed to load feeds.',
                              style: context.bodyMedium.copyWith(color: AppColor.hintText),
                              textAlign: TextAlign.center,
                            ),
                            16.height,
                            ElevatedButton(
                              onPressed: () => controller.fetchFeed(refresh: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: const ShowEmptyResult(
                          title: 'No adventures found',
                          desc: 'Try adjusting your search or filters',
                        ),
                      ),
                    );
                  }

                  final itemCount =
                      controller.items.length + (controller.isLoadingMore.value ? 1 : 0);

                  return SliverPadding(
                    padding: EdgeInsets.only(top: 14.h, bottom: 24.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.items.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          final item = controller.items[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: ArchiveStoryCard(story: item),
                          );
                        },
                        childCount: itemCount,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final base = context.headlineLarge.copyWith(fontWeight: FontWeight.w600);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text.rich(
          TextSpan(
            text: 'Get inspired for your \nnext ',
            style: base.copyWith(color: const Color(0xFF2D2D2D)),
            children: [
              TextSpan(
                text: 'adventure!',
                style: base.copyWith(color: AppColor.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SearchBarDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

class _ArchiveTopBar extends StatelessWidget {
  const _ArchiveTopBar();

  @override
  Widget build(BuildContext context) {
    final archiveController = Get.find<ArchiveController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.find<MainPageController>().openDrawer(),
            behavior: HitTestBehavior.opaque,
            child: AppSvgIcon(
              Assets.icons.menuIcon,
              size: 24.sp,
              color: AppColor.primary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: archiveController.onNotifications,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppSvgIcon(
                  Assets.icons.notificationFillIcon,
                  color: Colors.black,
                  size: 24.sp,
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8A3D),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends GetView<ArchiveController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return AppInputTextFormField(
      controller: controller.searchController,
      hintText: 'Search Itinerary',
      borderRadius: 30,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) => controller.onSearch(),
      enabledBorderColor: AppColor.hintText.withValues(alpha: 0.2),
      prefixIcon: GestureDetector(
        onTap: controller.onSearch,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 8.w),
          child: AppSvgIcon(Assets.icons.searchIcon, color: AppColor.hintText),
        ),
      ),
      suffixIcon: Obx(
        () => GestureDetector(
          onTap: controller.openFilterSheet,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(right: 16.w, left: 8.w),
            child: AppSvgIcon(
              Assets.icons.filterIcon,
              color: controller.isFilterActive ? AppColor.primary : AppColor.hintText,
            ),
          ),
        ),
      ),
    );
  }
}
