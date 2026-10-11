import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_controller.dart';

/// Card for every non-completed trip; tapping it opens the trip details.
class PendingItineraryCard extends GetView<ItineraryController> {
  const PendingItineraryCard({super.key, required this.trip});

  final TripListItem trip;

  @override
  Widget build(BuildContext context) {
    final status = trip.status;

    return GestureDetector(
      onTap: () => controller.onViewDetails(trip),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    trip.title ?? 'Untitled Trip',
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                    maxLines: 1,
                  ),
                ),
                8.width,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    status.label,
                    style: context.labelSmall.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            14.height,
            _IconRow(
              icon: Assets.icons.locationIcon,
              text: controller.route(trip),
            ),
            10.height,
            _IconRow(
              icon: Assets.icons.calendarIcon,
              text: controller.dateRange(trip),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSvgIcon(icon, size: 16.sp, color: AppColor.hintText),
        8.width,
        Expanded(
          child: AppText(
            text,
            style: context.bodySmall.copyWith(color: AppColor.hintText),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
