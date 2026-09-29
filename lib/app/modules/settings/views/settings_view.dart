import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Setting',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _NavRow(
                label: 'Change Password',
                onTap: controller.onChangePassword,
              ),
              const Divider(height: 1, color: Color(0xFFE8E8E8)),
              Obx(
                () => _ToggleRow(
                  label: 'New Itinerary Notification',
                  value: controller.newItineraryNotification.value,
                  onChanged: controller.toggleNewItinerary,
                ),
              ),
              Obx(
                () => _ToggleRow(
                  label: 'Tracker Notification',
                  value: controller.trackerNotification.value,
                  onChanged: controller.toggleTrackerNotification,
                ),
              ),
              Obx(
                () => _ToggleRow(
                  label: 'Anyone can see your Itinerary',
                  value: controller.anyoneCanSeeItinerary.value,
                  onChanged: controller.toggleAnyoneCanSee,
                ),
              ),
              8.height,
              Obx(
                () => _TravelTrackerCard(
                  value: controller.travelTracker.value,
                  onChanged: controller.toggleTravelTracker,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                label,
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColor.hintText,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              label,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColor.primary,
          ),
        ],
      ),
    );
  }
}

class _TravelTrackerCard extends StatelessWidget {
  const _TravelTrackerCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Travel Tracker',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColor.primary,
              ),
            ],
          ),
          10.height,
          AppText(
            "This feature is for tracking your every checkpoints. Without turning on the Travel Tracker, there won't be any track record.",
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              height: 1.45,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
