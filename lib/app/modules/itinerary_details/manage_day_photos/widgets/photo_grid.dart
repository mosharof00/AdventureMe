import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/manage_day_photos_controller.dart';

class PhotoGrid extends GetView<ManageDayPhotosController> {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.currentUploaded.isEmpty &&
          controller.currentPending.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: const GlobalLoading(),
        );
      }

      final uploaded = controller.currentUploaded;
      final pending = controller.currentPending;

      if (uploaded.isEmpty && pending.isEmpty) {
        return Column(
          children: [
            _UploadButton(onTap: controller.pickImages),
            60.height,
            _EmptyState(),
          ],
        );
      }

      final grid = LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final tile = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final photo in uploaded)
                _ImageCell(
                  size: tile,
                  image: CachedImage(
                    imgUrl: photo.previewUrl,
                    fit: BoxFit.cover,
                  ),
                  isDraft: photo.isDraft,
                  isBusy: controller.deletingId.value == photo.id,
                  onLongPress: () => controller.onPhotoLongPress(photo),
                ),
              for (final file in pending)
                _ImageCell(
                  size: tile,
                  image: Image.file(file, fit: BoxFit.cover),
                  onRemove: () => controller.removePending(file),
                ),
              _UploadTile(size: tile, onTap: controller.pickImages),
            ],
          );
        },
      );

      if (uploaded.isEmpty) return grid;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          grid,
          10.height,
          AppText(
            'Long press a photo to delete it.',
            style: context.labelSmall.copyWith(color: AppColor.hintText),
          ),
        ],
      );
    });
  }
}

class _ImageCell extends StatelessWidget {
  const _ImageCell({
    required this.size,
    required this.image,
    this.isDraft = false,
    this.isBusy = false,
    this.onRemove,
    this.onLongPress,
  });

  final double size;
  final Widget image;
  final bool isDraft;
  final bool isBusy;

  /// Picked photos are removed with ✕; uploaded ones via long press.
  final VoidCallback? onRemove;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: image,
              ),
            ),
            if (isBusy)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: GlobalLoading(size: 22.sp, color: AppColor.white),
                ),
              ),
            if (isDraft)
              Positioned(
                left: 6.w,
                bottom: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppText(
                    'Draft',
                    style: context.labelSmall.copyWith(color: AppColor.white),
                  ),
                ),
              ),
            if (onRemove != null)
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
                    child: Icon(
                      Icons.close,
                      size: 13.sp,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
            AppSvgIcon(
              Assets.icons.uploadIcon,
              size: 22.sp,
              color: AppColor.primary,
            ),
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
            Icon(
              Icons.file_upload_outlined,
              size: 22.sp,
              color: AppColor.primary,
            ),
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
