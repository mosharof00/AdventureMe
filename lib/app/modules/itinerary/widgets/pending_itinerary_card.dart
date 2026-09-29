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

import '../controllers/itinerary_controller.dart';

class PendingItineraryCard extends GetView<ItineraryController> {
  const PendingItineraryCard({
    super.key,
    required this.item,
    this.statusColor = const Color(0xFF8B6914),
    this.statusBgColor = const Color(0xFFF5E6C8),
    this.primaryLabel = 'Start Tracking',
    this.onPrimaryTap,
    this.onDetailsTap,
  });

  final PendingItinerary item;
  final Color statusColor;
  final Color statusBgColor;
  final String primaryLabel;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  item.title,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  item.status,
                  style: context.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          14.height,
          _IconRow(icon: Assets.icons.locationIcon, text: item.route),
          10.height,
          _IconRow(icon: Assets.icons.calendarIcon, text: item.dateRange),
          16.height,
          Row(
            children: [
              Expanded(
                child: GlobalButton(
                  text: primaryLabel,
                  onTap: onPrimaryTap ?? controller.onStartTracking,
                  height: 35.h,
                ),
              ),
              12.width,
              Expanded(
                child: GlobalButton(
                  text: 'View Details',
                  onTap: onDetailsTap ?? () {},
                  height: 35.h,
                  color: AppColor.primaryDisable,
                  textColor: const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ],
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
          ),
        ),
      ],
    );
  }
}
