import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_details_controller.dart';

class TripInfoCard extends GetView<ItineraryDetailsController> {
  const TripInfoCard({super.key, this.showActions = true});

  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFE0),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  controller.tripTitle,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              _StatusBadge(status: controller.status),
            ],
          ),
          14.height,
          _InfoRow(icon: Assets.icons.locationIcon, text: controller.tripRoute),
          10.height,
          _InfoRow(icon: Assets.icons.calendarIcon, text: controller.tripDates),
          if (showActions) ...[
            16.height,
            Row(
              children: [
                Expanded(
                  child: GlobalButton(
                    text: 'Cancel Trip',
                    color: AppColor.primaryDisable,
                    textColor: AppColor.primary,
                    height: 42.h,
                    onTap: controller.onCancelTrip,
                  ),
                ),
                12.width,
                Expanded(
                  child: GlobalButton(
                    text: 'Edit Trip',
                    height: 42.h,
                    onTap: controller.onEditTrip,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      TripStatus.pending => (
        const Color(0xFFF5E6C8),
        const Color(0xFF8B6914),
        'Pending',
      ),
      TripStatus.ongoing => (
        const Color(0xFFDDF3E5),
        const Color(0xFF1E8E5A),
        'Ongoing',
      ),
      TripStatus.completed => (
        const Color(0xFFD5EEF0),
        AppColor.primary,
        'Completed',
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        label,
        style: context.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSvgIcon(icon, size: 16.sp, color: AppColor.primary),
        8.width,
        Expanded(
          child: AppText(
            text,
            style: context.bodySmall.copyWith(color: AppColor.hintText),
          ),
        ),
      ],
    );
  }
}
