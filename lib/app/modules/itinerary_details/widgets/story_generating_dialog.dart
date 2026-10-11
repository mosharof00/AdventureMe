import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/logger.dart';
import 'package:adventureme/app/data/models/trip_models/story_status_model.dart';
import 'package:adventureme/app/data/repositories/trip_repository.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/routes/app_pages.dart';
import 'package:adventureme/gen/assets.gen.dart';

/// Starts the AI story for [tripId] and shows its progress by polling
/// `story/status`. Opens [Routes.GENERATE_STORY] once the story is READY.
/// Closing it doesn't cancel the job; opening it again picks the job back up.
class StoryGeneratingDialog extends StatefulWidget {
  const StoryGeneratingDialog({super.key, required this.tripId});

  final String tripId;

  static Future<void> show(String tripId) {
    return Get.dialog(
      StoryGeneratingDialog(tripId: tripId),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  State<StoryGeneratingDialog> createState() => _StoryGeneratingDialogState();
}

class _StoryGeneratingDialogState extends State<StoryGeneratingDialog> {
  static const _pollEvery = Duration(seconds: 2);
  static const _maxFailedPolls = 3;

  final ITripRepository _repository = Get.find<ITripRepository>();

  /// 0–100 from the server; never moves backwards on screen.
  int _progress = 0;
  String? _error;
  String? _itineraryId;
  Timer? _poller;
  int _failedPolls = 0;
  bool _navigating = false;

  String get _stepText {
    if (_progress >= 100) return 'Your story is ready!';
    if (_progress >= 85) return 'Adding the final touches…';
    if (_progress >= 55) return 'Writing your story…';
    if (_progress >= 25) return 'Finding the moments that mattered…';
    return 'Reading your memories…';
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _error = null;
      _failedPolls = 0;
    });
    try {
      final response = await _repository.generateStory(widget.tripId);
      if (!mounted) return;
      if (response.success != true || response.isFailed) {
        _fail(response.message ?? 'Unable to start your story.');
        return;
      }
      _apply(response);
      if (!response.isReady) _poll();
    } catch (e) {
      Log.e('[Generate Story] $e');
      if (mounted) _fail('Unable to start your story. Please try again.');
    }
  }

  void _poll() {
    _poller?.cancel();
    _poller = Timer(_pollEvery, () async {
      try {
        final response = await _repository.getStoryStatus(widget.tripId);
        if (!mounted) return;
        _failedPolls = 0;
        if (response.isFailed) {
          _fail(response.message ?? 'We couldn\'t write your story this time.');
          return;
        }
        _apply(response);
      } catch (e) {
        Log.e('[Story Status] $e');
        if (!mounted) return;
        if (++_failedPolls >= _maxFailedPolls) {
          _fail('Lost connection while writing your story.');
          return;
        }
      }
      if (mounted && !_navigating && _error == null) _poll();
    });
  }

  void _apply(StoryStatusResponse response) {
    _itineraryId = response.itineraryId ?? _itineraryId;
    final next = response.isReady ? 100 : (response.progress ?? _progress);
    setState(() => _progress = math.max(_progress, next.clamp(0, 100)));
    if (response.isReady) _onFinished();
  }

  void _fail(String message) {
    _poller?.cancel();
    setState(() => _error = message);
  }

  void _onFinished() {
    if (_navigating) return;
    _navigating = true;
    _poller?.cancel();
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.back();
      Get.toNamed(
        Routes.GENERATE_STORY,
        arguments: {'tripId': widget.tripId, 'itineraryId': _itineraryId},
      );
    });
  }

  void _onContinue() {
    if (_navigating) return;
    _poller?.cancel();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.back();
  }

  @override
  void dispose() {
    _poller?.cancel();
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
              _error == null
                  ? 'Yey! Your Story is Generating!'
                  : 'Story Paused',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            12.height,
            AppText(
              _error ??
                  'You can keep exploring. Your story keeps writing in the background.',
              style: context.bodyMedium.copyWith(
                color: _error == null ? AppColor.hintText : AppColor.error,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (_error == null) ...[
              28.height,
              _ProgressBar(progress: _progress / 100, label: '$_progress%'),
              10.height,
              AppText(
                _stepText,
                style: context.labelSmall.copyWith(color: AppColor.hintText),
                textAlign: TextAlign.center,
              ),
              24.height,
              GlobalButton(
                text: 'Continue Exploring',
                onTap: _onContinue,
              ),
            ] else ...[
              28.height,
              Row(
                children: [
                  Expanded(
                    child: GlobalButton(
                      text: 'Close',
                      color: const Color(0xFFD6E4F0),
                      textColor: const Color(0xFF2D2D2D),
                      onTap: _onContinue,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: GlobalButton(text: 'Try Again', onTap: _start),
                  ),
                ],
              ),
            ],
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
