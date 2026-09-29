import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/generate_story_controller.dart';

class GenerateStoryView extends GetView<GenerateStoryController> {
  const GenerateStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Itinerary Details',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeroGallery(),
                  16.height,
                  const _AuthorHeader(),
                  18.height,
                  const _ActionRow(),
                  16.height,
                  const _DaywiseToggle(),
                  12.height,
                  const _PreviewButton(),
                  16.height,
                  const _SummaryCard(),
                  24.height,
                  ...controller.sections.map(
                    (section) => Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: _StorySectionBlock(section: section),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: GlobalButton(
              text: 'Generate Story',
              onTap: controller.onRegenerateStory,
              gradient: const LinearGradient(
                colors: [AppColor.secondary, Color(0xFF8A7CFF)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGallery extends GetView<GenerateStoryController> {
  const _HeroGallery();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24.w,
            child: _HeroImage(
              url: controller.heroImages[0],
              width: 95.w,
              height: 130.h,
              angle: -0.08,
            ),
          ),
          Positioned(
            right: 24.w,
            child: _HeroImage(
              url: controller.heroImages[2],
              width: 95.w,
              height: 130.h,
              angle: 0.08,
            ),
          ),
          _HeroImage(
            url: controller.heroImages[1],
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
          borderRadius: BorderRadius.circular(14.r),
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
          borderRadius: BorderRadius.circular(11.r),
          child: CachedImage(imgUrl: url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _AuthorHeader extends GetView<GenerateStoryController> {
  const _AuthorHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: CachedImage(
            imgUrl: HelperUtils.defaultProfileImage,
            width: 56.w,
            height: 56.w,
            fit: BoxFit.cover,
          ),
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
            icon: Icons.calendar_month_outlined,
            onTap: controller.onCalendar,
          ),
        ),
        10.width,
        Expanded(
          child: _PillButton(
            icon: Icons.folder_outlined,
            label: 'Stories',
            onTap: controller.onStories,
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

class _DaywiseToggle extends GetView<GenerateStoryController> {
  const _DaywiseToggle();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppText(
              'Daywise Itinerary',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          CupertinoSwitch(
            value: controller.daywiseItinerary.value,
            onChanged: controller.toggleDaywise,
            activeTrackColor: AppColor.primary,
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends GetView<GenerateStoryController> {
  const _PreviewButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5EFE6),
      borderRadius: BorderRadius.circular(28.r),
      child: InkWell(
        onTap: controller.onPreview,
        borderRadius: BorderRadius.circular(28.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                size: 18.sp,
                color: const Color(0xFF2D2D2D),
              ),
              8.width,
              AppText(
                'Preview',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends GetView<GenerateStoryController> {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Place visited', value: controller.placeVisited),
          12.height,
          _SummaryRow(label: 'Most visited', value: controller.mostVisited),
          12.height,
          _SummaryRow(
            label: 'Total distance travel',
            value: controller.totalDistance,
          ),
          12.height,
          _SummaryRow(
            label: 'Total duration',
            value: controller.totalDuration,
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
        8.width,
        Expanded(
          child: AppText(
            value,
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              height: 1.35,
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class _StorySectionBlock extends StatelessWidget {
  const _StorySectionBlock({required this.section});

  final StorySection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          section.title,
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
          maxLines: 3,
        ),
        if (section.body != null) ...[
          10.height,
          AppText(
            section.body!,
            style: context.bodyMedium.copyWith(
              color: AppColor.hintText,
              height: 1.5,
            ),
            maxLines: 8,
            softWrap: true,
          ),
        ],
        if (section.quote != null) ...[
          10.height,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                10.width,
                Expanded(
                  child: AppText(
                    section.quote!,
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (section.images.isNotEmpty) ...[
          14.height,
          _ImageCarousel(images: section.images),
        ],
      ],
    );
  }
}

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
            height: 190.h,
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
