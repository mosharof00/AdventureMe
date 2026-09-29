import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/modules/itinerary_details/controllers/itinerary_details_controller.dart';
import 'package:adventureme/app/modules/itinerary_details/view_itinerary_map/controllers/view_itinerary_map_controller.dart';

class MapDayDetailsSheet extends StatelessWidget {
  const MapDayDetailsSheet({
    super.key,
    required this.mapDay,
    required this.onMarkCheckpoint,
    required this.onUploadPhotos,
  });

  final MapDay mapDay;
  final VoidCallback onMarkCheckpoint;
  final VoidCallback onUploadPhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.72.sh),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.height,
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColor.primaryDisable,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          16.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                AppText(
                  mapDay.dayLabel,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                AppText(
                  mapDay.date,
                  style: context.bodyMedium.copyWith(
                    color: AppColor.hintText,
                  ),
                ),
              ],
            ),
          ),
          16.height,
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: mapDay.checkpoints.length,
              itemBuilder: (_, i) => _CheckpointTile(
                checkpoint: mapDay.checkpoints[i],
                isLast: i == mapDay.checkpoints.length - 1,
              ),
            ),
          ),
          16.height,
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: GlobalButton(
                    text: 'Mark Checkpoint',
                    color: AppColor.primaryDisable,
                    textColor: AppColor.primary,
                    onTap: onMarkCheckpoint,
                  ),
                ),
                12.width,
                Expanded(
                  child: GlobalButton(
                    text: 'Upload Photos',
                    onTap: onUploadPhotos,
                  ),
                ),
              ],
            ),
          ),
          MediaQuery.of(context).padding.bottom.height,
        ],
      ),
    );
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
                decoration: const BoxDecoration(
                  color: AppColor.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: AppColor.secondary.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          12.width,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          checkpoint.title,
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      8.width,
                      AppText(
                        checkpoint.label,
                        style: context.bodySmall.copyWith(
                          color: AppColor.hintText,
                        ),
                      ),
                    ],
                  ),
                  6.height,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15.sp,
                        color: AppColor.hintText,
                      ),
                      6.width,
                      AppText(
                        '${checkpoint.time} • ${checkpoint.duration}',
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
    );
  }
}
