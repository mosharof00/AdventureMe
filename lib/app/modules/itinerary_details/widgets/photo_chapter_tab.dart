import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_details_controller.dart';
import 'trip_info_card.dart';

class PhotoChapterTab extends GetView<ItineraryDetailsController> {
  const PhotoChapterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _content(context, controller.memoryDays));
  }

  Widget _content(BuildContext context, List<TrackingDay> memoryDays) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TripInfoCard(showActions: false),
          24.height,
          if (memoryDays.isEmpty)
            _emptyState(context)
          else
            for (var d = 0; d < memoryDays.length; d++) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AppText(
                  'Memories from day ${d + 1}',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              16.height,
              for (final checkpoint in memoryDays[d].checkpoints) ...[
                _MemoryBlock(checkpoint: checkpoint),
                20.height,
              ],
            ],
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 60.h, 16.w, 0),
      child: Center(
        child: Column(
          children: [
            Image.asset(
              Assets.images.emptyBox.path,
              width: 64.w,
              height: 64.w,
              fit: BoxFit.contain,
            ),
            14.height,
            AppText(
              'No memories captured yet!\nYour photo chapters will appear here.',
              style: context.bodyMedium.copyWith(color: AppColor.hintText),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryBlock extends StatelessWidget {
  const _MemoryBlock({required this.checkpoint});

  final TripCheckpoint checkpoint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            checkpoint.title,
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          8.height,
          AppText(
            '"${checkpoint.quote}"',
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            maxLines: 4,
          ),
          12.height,
          _Collage(photos: checkpoint.photos),
          8.height,
          AppText(
            'Shot Xxx / 1976',
            style: context.labelSmall.copyWith(
              color: AppColor.hintText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    final radius = 14.r;
    final height = 200.h;

    if (photos.length == 1) {
      return CachedImage(
        imgUrl: photos.first,
        width: double.infinity,
        height: height,
        borderRadius: radius,
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: CachedImage(
              imgUrl: photos[0],
              borderRadius: radius,
              fit: BoxFit.cover,
            ),
          ),
          8.width,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedImage(
                    imgUrl: photos[1],
                    borderRadius: radius,
                    fit: BoxFit.cover,
                  ),
                ),
                if (photos.length > 2) ...[
                  8.height,
                  Expanded(
                    child: CachedImage(
                      imgUrl: photos[2],
                      borderRadius: radius,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
