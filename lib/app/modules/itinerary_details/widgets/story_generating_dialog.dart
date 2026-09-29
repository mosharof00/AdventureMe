import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/routes/app_pages.dart';
import 'package:adventureme/gen/assets.gen.dart';

/// Progress overlay shown while a story is generating.
/// Navigates to [Routes.GENERATE_STORY] when progress reaches 100%.
class StoryGeneratingDialog extends StatefulWidget {
  const StoryGeneratingDialog({super.key});

  static Future<void> show() {
    return Get.dialog(
      const StoryGeneratingDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  State<StoryGeneratingDialog> createState() => _StoryGeneratingDialogState();
}

class _StoryGeneratingDialogState extends State<StoryGeneratingDialog> {
  double _progress = 0.12;
  Timer? _timer;
  bool _navigating = false;

  int get _percent => (_progress * 100).round();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress >= 0.98) {
          _progress = 1.0;
          timer.cancel();
          _onFinished();
          return;
        }
        final remaining = 1.0 - _progress;
        _progress = (_progress + remaining * 0.035).clamp(0.0, 1.0);
      });
    });
  }

  void _onFinished() {
    if (_navigating) return;
    _navigating = true;
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      Get.back(); // close dialog
      Get.toNamed(Routes.GENERATE_STORY);
    });
  }

  void _onContinue() {
    if (_progress < 1.0) {
      Get.back();
      return;
    }
    _onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 22.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.images.robotSticker.path,
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
            22.height,
            AppText(
              'Yey! Your Story is Generating!',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            12.height,
            AppText(
              'We will notify you when your story is fully ready! Thanks for your patience!',
              style: context.bodyMedium.copyWith(
                color: AppColor.hintText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            28.height,
            _ProgressBar(progress: _progress, label: '$_percent%'),
            28.height,
            GlobalButton(
              text: 'Continue Exploring',
              onTap: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final fillWidth =
            (trackWidth * progress.clamp(0.0, 1.0)).clamp(48.0, trackWidth);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: SizedBox(
            height: 28.h,
            width: trackWidth,
            child: Stack(
              children: [
                Container(
                  width: trackWidth,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  width: fillWidth,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.secondary,
                        Color(0xFF5B9DE8),
                        AppColor.primary,
                      ],
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 12.w),
                  child: AppText(
                    label,
                    style: context.labelSmall.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
