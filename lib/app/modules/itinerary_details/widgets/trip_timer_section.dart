import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_details_controller.dart';

class TripTimerSection extends GetView<ItineraryDetailsController> {
  const TripTimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCancelled) return const SizedBox.shrink();
      if (controller.isCompleted) return const _CompletedCard();

      final isStarting = controller.isStarting.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TimerText(controller.timerText, fontSize: 40.sp),
          24.height,
          GestureDetector(
            onTap: isStarting ? null : controller.onStartOrEnd,
            child: SizedBox(
              width: 118.w,
              height: 118.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isStarting ? 0.5 : 1,
                    child: Image.asset(
                      controller.isOngoing
                          ? Assets.images.endButton.path
                          : Assets.images.startButton.path,
                      width: 118.w,
                      height: 118.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (isStarting) const GlobalLoading(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CompletedCard extends GetView<ItineraryDetailsController> {
  const _CompletedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            Assets.images.coolSticker.path,
            width: 84.w,
            height: 84.w,
            fit: BoxFit.contain,
          ),
          12.height,
          AppText(
            "Yay! You've Completed it!\nTotal Hours:",
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          10.height,
          Obx(() => _TimerText(controller.timerText, fontSize: 34.sp)),
        ],
      ),
    );
  }
}

class _TimerText extends StatelessWidget {
  const _TimerText(this.time, {required this.fontSize});

  final String time;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final splitIndex = time.lastIndexOf(':');
    final head = splitIndex == -1 ? time : time.substring(0, splitIndex + 1);
    final tail = splitIndex == -1 ? '' : time.substring(splitIndex + 1);

    final baseStyle = context.displayLarge.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    );

    return Text.rich(
      TextSpan(
        text: head,
        style: baseStyle.copyWith(color: const Color(0xFF2D2D2D)),
        children: [
          TextSpan(
            text: tail,
            style: baseStyle.copyWith(color: AppColor.secondary),
          ),
        ],
      ),
    );
  }
}
