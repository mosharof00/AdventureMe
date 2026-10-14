import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/services/photo_viewer_service.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/day_photos_model.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_details_controller.dart';
import 'trip_info_card.dart';

/// Photo moments for the selected day (Day 1 by default).
class PhotoChapterTab extends StatefulWidget {
  const PhotoChapterTab({super.key});

  @override
  State<PhotoChapterTab> createState() => _PhotoChapterTabState();
}

class _PhotoChapterTabState extends State<PhotoChapterTab> {
  final controller = Get.find<ItineraryDetailsController>();

  @override
  void initState() {
    super.initState();
    // First open of this tab: show Day 1 unless View Details already chose one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final day = controller.selectedChapterDayNumber.value > 0
          ? controller.selectedChapterDayNumber.value
          : (controller.days.isEmpty ? 1 : controller.days.first.dayNumber);
      controller.openPhotoChapter(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => controller.loadPhotoChapter(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TripInfoCard(showActions: false),
            24.height,
            Obx(() {
              final day = controller.selectedChapterDay.value;
              final moments = controller.chapterMoments;
              if (moments.isEmpty) {
                if (controller.isChapterLoading.value) {
                  return Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: const Center(child: GlobalLoading()),
                  );
                }
                return _EmptyState(
                  error: controller.chapterError.value,
                  dayLabel: day?.dayLabel,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AppText(
                        '${day.dayLabel}  ·  ${day.date}',
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    16.height,
                  ],
                  for (final moment in moments) ...[
                    _MomentBlock(day: day, moment: moment),
                    28.height,
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.error, this.dayLabel});

  final bool error;
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final day = dayLabel ?? 'this day';
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
              error
                  ? 'Couldn\'t load photos for $day.\nPull down to try again.'
                  : 'No memories for $day yet!\nUpload photos to see them here.',
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

class _MomentBlock extends StatelessWidget {
  const _MomentBlock({required this.day, required this.moment});

  final TrackingDay? day;
  final TripMoment moment;

  @override
  Widget build(BuildContext context) {
    final title = moment.title?.trim() ?? '';
    final quote = moment.quote?.trim() ?? '';
    final address = moment.address?.trim() ?? '';
    final dayNumber = day?.dayNumber;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title.isNotEmpty
                ? title
                : 'Memories from day ${dayNumber ?? ''}'.trim(),
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
            maxLines: 2,
          ),
          if (quote.isNotEmpty) ...[
            10.height,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: AppText(
                      '"$quote"',
                      style: context.bodySmall.copyWith(
                        color: AppColor.hintText,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          12.height,
          _Collage(
            photos: [
              for (final p in moment.photos)
                if (p.viewUrl.isNotEmpty) p.viewUrl,
            ],
          ),
          8.height,
          AppText(
            [
              if (day != null) '${day!.dayLabel} | ${day!.date}',
              if (address.isNotEmpty) address,
            ].join('  ·  '),
            style: context.labelSmall.copyWith(
              color: AppColor.hintText,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// 1 photo: full width. 2+: big left, up to two stacked right; "+N" on the
/// last tile when there are more. Tap opens the full gallery.
class _Collage extends StatelessWidget {
  const _Collage({required this.photos});

  final List<String> photos;

  void _open(int index) {
    Get.find<PhotoViewerService>().open(photos, index: index);
  }

  @override
  Widget build(BuildContext context) {
    final urls = photos.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    final radius = 14.r;
    final height = 220.h;

    Widget tile(String url, {required int index, Widget? overlay}) =>
        GestureDetector(
          onTap: () => _open(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imgUrl: url,
                width: double.infinity,
                height: double.infinity,
                borderRadius: radius,
                fit: BoxFit.cover,
              ),
              if (overlay != null) overlay,
            ],
          ),
        );

    if (urls.length == 1) {
      return SizedBox(
        height: height,
        child: tile(urls.first, index: 0),
      );
    }

    final extra = urls.length - 3;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: tile(urls[0], index: 0)),
          8.width,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tile(urls[1], index: 1)),
                if (urls.length > 2) ...[
                  8.height,
                  Expanded(
                    child: tile(
                      urls[2],
                      index: 2,
                      overlay: extra > 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(radius),
                              ),
                              alignment: Alignment.center,
                              child: AppText(
                                '+$extra',
                                style: context.titleLarge.copyWith(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
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
