import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/home_controller.dart';

class StoryUnfoldingCard extends GetView<HomeController> {
  const StoryUnfoldingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(180.w, 40.h),
                  painter: _WaveLinePainter(color: AppColor.secondary),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TiltedThumb(
                      url: controller.unfoldingImages[0],
                      angle: -0.18,
                    ),
                    10.width,
                    _TiltedThumb(
                      url: controller.unfoldingImages[1],
                      angle: 0.08,
                    ),
                    10.width,
                    _TiltedThumb(
                      url: controller.unfoldingImages[2],
                      angle: 0.2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          16.height,
          AppText(
            'Your Story is Still Unfolding',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
            textAlign: TextAlign.center,
          ),
          8.height,
          AppText(
            "Where will your next chapter begin? Let's capture your next adventure!",
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          16.height,
          GlobalButton(
            text: '',
            widget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColor.white, size: 20.sp),
                2.width,
                AppText(
                  'Create New Story',
                  style: context.titleSmall.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onTap: controller.onCreateStory,
            prefixWidget: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Icon(Icons.add, color: AppColor.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltedThumb extends StatelessWidget {
  const _TiltedThumb({required this.url, required this.angle});

  final String url;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CachedImage(
          imgUrl: url,
          width: 52.w,
          height: 52.w,
          borderRadius: 10.r,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _WaveLinePainter extends CustomPainter {
  _WaveLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.55);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.55 + math.sin(x / size.width * math.pi * 2) * 8;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
