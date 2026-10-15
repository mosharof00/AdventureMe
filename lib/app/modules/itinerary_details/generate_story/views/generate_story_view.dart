import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_story_model.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/show_empty_result.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/generate_story_controller.dart';

class GenerateStoryView extends GetView<GenerateStoryController> {
  const GenerateStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Itinerary Details',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: GlobalLoading());
        }

        if (controller.hasError.value) {
          return Center(
            child: ShowEmptyResult(
              title: "Couldn't load story",
              desc: controller.errorMessage.value,
              refreshOnTap: controller.fetchStory,
            ),
          );
        }

        final story = controller.storyData.value;
        if (story == null) {
          return Center(
            child: ShowEmptyResult(
              title: 'No story found',
              desc: 'Please generate a story first.',
              refreshOnTap: controller.fetchStory,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroGallery(images: controller.heroImages),
                    18.height,
                    const _AuthorHeader(),
                    18.height,
                    const _ActionRow(),
                    16.height,
                    const _CanShareToggle(),
                    18.height,
                    const _SummaryBadge(),
                    14.height,
                    _SummaryCard(summary: story.summary),
                    ..._buildDaysAndMoments(context, controller.displayDays),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: GlobalButton(
                text: 'Continue',
                color: AppColor.primary,
                onTap: () => Get.back(),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildDaysAndMoments(
    BuildContext context,
    List<StoryDay> days,
  ) {
    final widgets = <Widget>[];

    for (final day in days) {
      final hasHeader = (day.dateTimeLabel != null &&
              day.dateTimeLabel!.trim().isNotEmpty) ||
          (day.title != null &&
              day.title!.trim().isNotEmpty &&
              day.title != 'Day ${day.dayNumber}') ||
          (day.narrative != null && day.narrative!.trim().isNotEmpty);

      if (hasHeader) {
        widgets.add(const _TimelineDivider());
        widgets.add(_DayHeaderBlock(day: day));
      }

      for (final moment in day.moments) {
        widgets.add(const _TimelineDivider());
        widgets.add(_StoryMomentBlock(moment: moment));
      }
    }

    return widgets;
  }
}

// ── Hero Gallery (handles 0, 1, 2, or <= 3 cover images) ───────────────
class _HeroGallery extends StatelessWidget {
  const _HeroGallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return SizedBox(
        height: 155.h,
        child: Center(
          child: Container(
            width: 125.w,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColor.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13.r),
              child: Image.asset(
                Assets.images.itinearyBgImage.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    if (images.length == 1) {
      return SizedBox(
        height: 155.h,
        child: Center(
          child: _HeroImage(
            url: images[0],
            width: 130.w,
            height: 150.h,
            angle: 0,
          ),
        ),
      );
    }

    if (images.length == 2) {
      return SizedBox(
        height: 155.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 50.w,
              child: _HeroImage(
                url: images[0],
                width: 110.w,
                height: 140.h,
                angle: -0.07,
              ),
            ),
            Positioned(
              right: 50.w,
              child: _HeroImage(
                url: images[1],
                width: 110.w,
                height: 140.h,
                angle: 0.07,
              ),
            ),
          ],
        ),
      );
    }

    // 3 or more images: cap at 3 and fan out left, right, center
    return SizedBox(
      height: 155.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20.w,
            child: _HeroImage(
              url: images[0],
              width: 95.w,
              height: 130.h,
              angle: -0.09,
            ),
          ),
          Positioned(
            right: 20.w,
            child: _HeroImage(
              url: images[2],
              width: 95.w,
              height: 130.h,
              angle: 0.09,
            ),
          ),
          _HeroImage(
            url: images[1],
            width: 110.w,
            height: 150.h,
            angle: 0,
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.url,
    required this.width,
    required this.height,
    required this.angle,
  });

  final String url;
  final double width;
  final double height;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColor.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.r),
          child: CachedImage(imgUrl: url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ── Author Header ──────────────────────────────────────────────────────
class _AuthorHeader extends GetView<GenerateStoryController> {
  const _AuthorHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: CachedImage(
                imgUrl: controller.authorAvatar,
                width: 58.w,
                height: 58.w,
                fit: BoxFit.cover,
              ),
            ),
            if (controller.isAuthorVerified)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: AppColor.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.check, size: 10.sp, color: Colors.white),
                ),
              ),
          ],
        ),
        8.height,
        AppText(
          controller.authorName,
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

// ── Action Row (Share, QR code, Visibility) ────────────────────────────
class _ActionRow extends GetView<GenerateStoryController> {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            icon: Icons.ios_share_rounded,
            onTap: controller.onShare,
          ),
        ),
        10.width,
        Expanded(
          child: _PillButton(
            icon: Icons.qr_code_2_rounded,
            onTap: controller.onQrCode,
          ),
        ),
        10.width,
        Expanded(
          child: _PillButton(
            icon: controller.isPrivate
                ? Icons.lock_outline_rounded
                : Icons.public_rounded,
            label: controller.isPrivate ? 'Private' : 'Public',
            onTap: controller.onVisibilityTap,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5EFE6),
      borderRadius: BorderRadius.circular(28.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: const Color(0xFF2D2D2D)),
              if (label != null) ...[
                6.width,
                AppText(
                  label!,
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Can Share Toggle ───────────────────────────────────────────────────
class _CanShareToggle extends GetView<GenerateStoryController> {
  const _CanShareToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColor.hintText.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              'Anyone Can share',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          Obx(
            () => CupertinoSwitch(
              value: controller.canShare.value,
              onChanged: controller.toggleCanShare,
              activeTrackColor: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Badge & Card ───────────────────────────────────────────────
class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE6),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16.sp, color: const Color(0xFF2D2D2D)),
            8.width,
            AppText(
              'Summary',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({this.summary});

  final StorySummary? summary;

  @override
  Widget build(BuildContext context) {
    final items = summary?.items ?? const [];

    if (items.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE6),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _SummaryRow(label: items[i].label, value: items[i].value),
              if (i < items.length - 1) 14.height,
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Location Explored',
            value: summary?.locationsExplored ?? '--',
          ),
          14.height,
          _SummaryRow(
            label: 'Miles Traveled',
            value: summary?.milesTraveled ?? '--',
          ),
          14.height,
          _SummaryRow(
            label: 'Most Photographed Location',
            value: summary?.mostPhotographedLocation ?? '--',
          ),
          14.height,
          _SummaryRow(
            label: 'Total Duration',
            value: summary?.totalDuration ?? '--',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: AppText(
            label,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
            maxLines: 2,
          ),
        ),
        10.width,
        Expanded(
          child: AppText(
            value,
            style: context.bodySmall.copyWith(
              color: const Color(0xFF555555),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Timeline Divider (Horizontal line with center diamond node) ───────
class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22.h),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Color(0xFFE2D9CC), thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 7.w,
                height: 7.w,
                color: const Color(0xFFD4C8B8),
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: Color(0xFFE2D9CC), thickness: 1),
          ),
        ],
      ),
    );
  }
}

// ── Day Header Block ───────────────────────────────────────────────────
class _DayHeaderBlock extends StatelessWidget {
  const _DayHeaderBlock({required this.day});

  final StoryDay day;

  @override
  Widget build(BuildContext context) {
    final dateLabel = day.dateTimeLabel ?? day.formattedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dateLabel != null && dateLabel.trim().isNotEmpty) ...[
          AppText(
            dateLabel,
            style: context.labelSmall.copyWith(
              color: AppColor.hintText,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.height,
        ],
        if (day.title != null && day.title!.trim().isNotEmpty) ...[
          AppText(
            day.title!,
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          8.height,
        ],
        if (day.narrative != null && day.narrative!.trim().isNotEmpty) ...[
          AppText(
            day.narrative!,
            style: context.bodyMedium.copyWith(
              color: const Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Story Moment Block ─────────────────────────────────────────────────
class _StoryMomentBlock extends StatelessWidget {
  const _StoryMomentBlock({required this.moment});

  final StoryMoment moment;

  @override
  Widget build(BuildContext context) {
    final category = moment.categoryLabel ?? moment.category;
    final photos = moment.allPhotoUrls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null && category.trim().isNotEmpty) ...[
          AppText(
            category.toUpperCase(),
            style: context.labelSmall.copyWith(
              color: const Color(0xFF8B6914),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          4.height,
        ],
        if (moment.title != null && moment.title!.trim().isNotEmpty) ...[
          AppText(
            moment.title!,
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ],
        if (moment.quote != null && moment.quote!.trim().isNotEmpty) ...[
          10.height,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: AppColor.secondary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                12.width,
                Expanded(
                  child: AppText(
                    '“${moment.quote!}”',
                    style: context.bodyMedium.copyWith(
                      color: const Color(0xFF2D2D2D),
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (moment.bodyText != null &&
            moment.bodyText!.trim().isNotEmpty &&
            moment.bodyText != moment.quote) ...[
          10.height,
          AppText(
            moment.bodyText!,
            style: context.bodyMedium.copyWith(
              color: const Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
        if (photos.isNotEmpty) ...[
          14.height,
          _ImageCarousel(images: photos),
        ],
      ],
    );
  }
}

// ── Image Carousel with Dots Indicator ─────────────────────────────────
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            height: 195.h,
            width: double.infinity,
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CachedImage(
                imgUrl: widget.images[i],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _index
                      ? AppColor.secondary
                      : AppColor.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
