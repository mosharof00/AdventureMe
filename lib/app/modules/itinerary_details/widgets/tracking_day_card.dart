import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_details_controller.dart';

class TrackingDayCard extends GetView<ItineraryDetailsController> {
  const TrackingDayCard({
    super.key,
    required this.day,
    required this.isDone,
    this.onManagePhotos,
  });

  final TrackingDay day;
  final bool isDone;
  final VoidCallback? onManagePhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          16.height,
          if (isDone) ..._doneContent(context) else _emptyState(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText(
          day.dayLabel,
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        12.width,
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Divider(
                color: AppColor.hintText.withValues(alpha: 0.25),
                thickness: 1,
              ),
              Container(
                color: const Color(0xFFFFFCF8),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: AppText(
                  day.date,
                  style: context.bodySmall.copyWith(color: AppColor.hintText),
                ),
              ),
            ],
          ),
        ),
        12.width,
        _dayBadge(context),
      ],
    );
  }

  Widget _dayBadge(BuildContext context) {
    final bg = isDone ? const Color(0xFFDDF3E5) : const Color(0xFFF5E6C8);
    final fg = isDone ? const Color(0xFF1E8E5A) : const Color(0xFF8B6914);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        isDone ? 'Done' : 'Pending',
        style: context.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            Assets.images.emptyBox.path,
            width: 54.w,
            height: 54.w,
            fit: BoxFit.contain,
          ),
          12.height,
          AppText(
            'You have no tracking data yet!\nStart Tracking to see data.',
            style: context.bodySmall.copyWith(color: AppColor.hintText),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          6.height,
        ],
      ),
    );
  }

  List<Widget> _doneContent(BuildContext context) {
    return [
      for (var i = 0; i < day.checkpoints.length; i++)
        _CheckpointTile(
          checkpoint: day.checkpoints[i],
          isLast: i == day.checkpoints.length - 1,
        ),
      12.height,
      Row(
        children: [
          Expanded(
            child: GlobalButton(
              text: controller.photoActionLabel,
              height: 40.h,
              onTap: onManagePhotos ?? () {},
            ),
          ),
          12.width,
          Expanded(
            child: GlobalButton(
              text: 'View Details',
              height: 40.h,
              color: AppColor.primaryDisable,
              textColor: const Color(0xFF2D2D2D),
              onTap: controller.onCheckpointDetails,
            ),
          ),
        ],
      ),
    ];
  }
}

class _CheckpointTile extends StatelessWidget {
  const _CheckpointTile({required this.checkpoint, required this.isLast});

  final TripCheckpoint checkpoint;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.secondary,
                  border: Border.all(
                    color: AppColor.secondary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColor.secondary.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          12.width,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          checkpoint.title,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        4.height,
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.sp,
                              color: AppColor.hintText,
                            ),
                            5.width,
                            AppText(
                              '${checkpoint.time} • ${checkpoint.duration}',
                              style: context.labelSmall.copyWith(
                                color: AppColor.hintText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppText(
                    checkpoint.label,
                    style: context.labelSmall.copyWith(color: AppColor.hintText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
