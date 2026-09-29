import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/manage_day_photos_controller.dart';

class PhotoGrid extends GetView<ManageDayPhotosController> {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.currentImages;

      if (images.isEmpty) {
        return Column(
          children: [
            _UploadButton(onTap: controller.pickImages),
            60.height,
            _EmptyState(),
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final tile = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final item in images)
                _ImageCell(
                  item: item,
                  size: tile,
                  onRemove: () => controller.removeImage(item),
                ),
              _UploadTile(size: tile, onTap: controller.pickImages),
            ],
          );
        },
      );
    });
  }
}

class _ImageCell extends StatelessWidget {
  const _ImageCell({
    required this.item,
    required this.size,
    required this.onRemove,
  });

  final PhotoItem item;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: item.isLocal
                  ? Image.file(File(item.file!.path), fit: BoxFit.cover)
                  : CachedImage(imgUrl: item.url!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 6.w,
            right: 6.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: const BoxDecoration(
                  color: AppColor.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 13.sp, color: AppColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _DashedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, size: 22.sp, color: AppColor.primary),
            6.height,
            AppText(
              'Upload Image',
              style: context.labelSmall.copyWith(color: AppColor.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _DashedBox(
        width: double.infinity,
        height: 76.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, size: 22.sp, color: AppColor.primary),
            6.height,
            AppText(
              'Upload Image',
              style: context.bodySmall.copyWith(
                color: const Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          Assets.images.emptyBox.path,
          width: 64.w,
          height: 64.w,
          fit: BoxFit.contain,
        ),
        14.height,
        AppText(
          'You have no image uploaded yet!\nClick "Upload Image" to get started!',
          style: context.bodySmall.copyWith(color: AppColor.hintText),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _DashedBox extends StatelessWidget {
  const _DashedBox({
    required this.child,
    required this.width,
    required this.height,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColor.hintText.withValues(alpha: 0.5),
        radius: 12.r,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColor.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
