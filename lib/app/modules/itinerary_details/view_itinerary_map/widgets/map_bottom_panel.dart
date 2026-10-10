import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/view_itinerary_map_controller.dart';

/// Floating card over the map: day switcher, then either a trip summary or
/// the selected day's checkpoints and actions. Collapses to a compact header
/// while the map is being explored; tap or swipe up to expand.
class MapBottomPanel extends GetView<ViewItineraryMapController> {
  const MapBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.panelExpanded.value;
      final day = controller.currentDay;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: expanded ? null : controller.expandPanel,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -100) controller.expandPanel();
          if (velocity > 100) controller.collapsePanel();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          padding: EdgeInsets.only(top: 10.h, bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryDisable,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                12.height,
                if (!controller.isSingleDay) ...[
                  const _DayChips(),
                  14.height,
                ],
                if (!expanded)
                  _CollapsedHeader(day: day)
                else if (day == null)
                  const _TripSummary()
                else
                  _DayDetails(day: day),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _CollapsedHeader extends GetView<ViewItineraryMapController> {
  const _CollapsedHeader({required this.day});

  final TripMapDay? day;

  @override
  Widget build(BuildContext context) {
    final day = this.day;
    final count = day?.checkpoints.length ?? controller.totalCheckpoints;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              day == null
                  ? controller.tripTitle
                  : '${controller.dayLabel(day)} · ${controller.dayDate(day)}',
              style: context.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          8.width,
          AppText(
            '$count ${count == 1 ? 'checkpoint' : 'checkpoints'}',
            style: context.bodySmall.copyWith(color: AppColor.hintText),
          ),
          4.width,
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: AppColor.primary,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}

class _DayChips extends GetView<ViewItineraryMapController> {
  const _DayChips();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedDay.value;
      return SizedBox(
        height: 34.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _chip(context, 'All Days', selected == null, null),
            for (final day in controller.days)
              _chip(
                context,
                controller.dayLabel(day),
                selected == day.dayNumber,
                day.dayNumber,
              ),
          ],
        ),
      );
    });
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool isSelected,
    int? dayNumber,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          controller.expandPanel();
          controller.selectDay(dayNumber);
        },
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        selectedColor: AppColor.primary,
        backgroundColor: AppColor.white,
        labelStyle: context.labelLarge.copyWith(
          color: isSelected ? AppColor.white : const Color(0xFF2D2D2D),
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected ? AppColor.primary : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

class _TripSummary extends GetView<ViewItineraryMapController> {
  const _TripSummary();

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final days = controller.days.length;
    final checkpoints = controller.totalCheckpoints;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            controller.tripTitle,
            style: context.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          4.height,
          AppText(
            '$days ${days == 1 ? 'day' : 'days'} · '
            '$checkpoints ${checkpoints == 1 ? 'checkpoint' : 'checkpoints'}',
            style: context.bodyMedium.copyWith(color: AppColor.hintText),
          ),
          8.height,
          AppText(
            checkpoints == 0
                ? 'No checkpoints yet. Pick a day to mark one.'
                : 'Tap a day marker to see its route and checkpoints.',
            style: context.bodySmall.copyWith(color: AppColor.hintText),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _DayDetails extends GetView<ViewItineraryMapController> {
  const _DayDetails({required this.day});

  final TripMapDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              AppText(
                controller.dayLabel(day),
                style: context.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              AppText(
                controller.dayDate(day),
                style: context.bodyMedium.copyWith(color: AppColor.hintText),
              ),
            ],
          ),
        ),
        12.height,
        Divider(height: 1, color: AppColor.primaryDisable),
        12.height,
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 0.24.sh),
          child: day.checkpoints.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: AppText(
                    'No checkpoints for this day yet.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: day.checkpoints.length,
                  itemBuilder: (_, i) => _CheckpointTile(
                    number: i + 1,
                    checkpoint: day.checkpoints[i],
                    isLast: i == day.checkpoints.length - 1,
                  ),
                ),
        ),
        16.height,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              if (controller.canMarkCheckpoint) ...[
                Expanded(
                  child: GlobalButton(
                    text: 'Mark Checkpoint',
                    color: AppColor.primaryDisable,
                    textColor: AppColor.primary,
                    fontSize: 14.sp,
                    onTap: () => controller.onMarkCheckpoint(day),
                  ),
                ),
                12.width,
              ],
              Expanded(
                child: GlobalButton(
                  text: 'Upload Photos',
                  fontSize: 14.sp,
                  onTap: () => controller.onUploadPhotos(day),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckpointTile extends GetView<ViewItineraryMapController> {
  const _CheckpointTile({
    required this.number,
    required this.checkpoint,
    required this.isLast,
  });

  final int number;
  final Checkpoint checkpoint;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.focusCheckpoint(checkpoint),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: AppText(
                    '$number',
                    style: context.labelSmall.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: AppColor.primary.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
            12.width,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      checkpoint.title ?? 'Checkpoint $number',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((checkpoint.address ?? '').isNotEmpty) ...[
                      2.height,
                      AppText(
                        checkpoint.address!,
                        style: context.bodySmall.copyWith(
                          color: AppColor.hintText,
                        ),
                      ),
                    ],
                    4.height,
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15.sp,
                          color: AppColor.hintText,
                        ),
                        6.width,
                        AppText(
                          controller.checkpointTime(checkpoint),
                          style: context.bodySmall.copyWith(
                            color: AppColor.hintText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
