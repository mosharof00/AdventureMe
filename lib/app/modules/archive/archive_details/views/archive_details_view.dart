import 'package:adventureme/app/global/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/archive_details_controller.dart';

const _textDark = Color(0xFF2D2D2D);
const _peach = Color(0xFFFCE7D8);
const _cream = Color(0xFFFFF8EE);

class ArchiveDetailsView extends GetView<ArchiveDetailsController> {
  const ArchiveDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(
        title: 'Itinerary Details',
        showBackButton: true,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GlobalButton(
        text: 'View Details',
        width: 180.w,
        onTap: controller.onViewDetails,
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthorHeader(),
            14.height,
            const _ActionRow(),
            14.height,
            const _SummaryToggle(),
            const _SummaryCard(),
            14.height,
            GlobalButton(
              text: 'View Locations',
              height: 42.h,
              fontSize: 14.sp,
              onTap: controller.onViewLocations,
            ),
            20.height,
            for (var i = 0; i < controller.sections.length; i++) ...[
              if (i > 0) const _SectionDivider(),
              _StorySectionBlock(section: controller.sections[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthorHeader extends GetView<ArchiveDetailsController> {
  const _AuthorHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.secondary, width: 2.5),
              ),
              child: ClipOval(
                child:CachedImage(
                  imgUrl: controller.authorAvatar,
                  width: 55.w,
                  height: 55.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: -18.w,
              bottom: -8.w,
              child:  controller.isVerified
                    ? AppSvgIcon(
                  Assets.icons.verifiedBadgeIcon,
                  height: 40.w,
                  width: 40.w,
                )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
        8.height,
        AppText(
          controller.authorName,
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends GetView<ArchiveDetailsController> {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleIconButton(
          icon: Assets.icons.shareIcon,
          onTap: controller.onShare,
        ),
        14.width,
        _CircleIconButton(
          icon: Assets.icons.scanIcon,
          onTap: controller.onScan,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _peach,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(
            child: AppSvgIcon(icon, size: 20.sp, color: _textDark),
          ),
        ),
      ),
    );
  }
}

class _SummaryToggle extends GetView<ArchiveDetailsController> {
  const _SummaryToggle();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cream,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: controller.toggleSummary,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                child: Obx(
                  () => AppSvgIcon(
                    controller.isSummaryExpanded.value
                        ? Assets.icons.arrowsUpIcon
                        : Assets.icons.arrowsDownIcon,
                    size: 14.sp,
                    color: _textDark,
                  ),
                ),
              ),
              8.width,
              AppText(
                'Summary',
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends GetView<ArchiveDetailsController> {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: controller.isSummaryExpanded.value
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 20.h),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    for (
                      var i = 0;
                      i < controller.summaryItems.length;
                      i++
                    ) ...[
                      if (i > 0) 24.height,
                      _SummaryRow(item: controller.summaryItems[i]),
                    ],
                  ],
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.item});

  final ArchiveSummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: AppText(
            item.label,
            style: context.labelSmall.copyWith(color: AppColor.hintText),
            maxLines: 2,
          ),
        ),
        12.width,
        Expanded(
          child: AppText(
            item.value,
            style: context.bodySmall.copyWith(color: _textDark, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: AppColor.hintText.withValues(alpha: 0.2)),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        children: [
          line,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 6.w,
                height: 6.w,
                color: AppColor.hintText.withValues(alpha: 0.3),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _StorySectionBlock extends StatelessWidget {
  const _StorySectionBlock({required this.section});

  final ArchiveStorySection section;

  @override
  Widget build(BuildContext context) {
    final metaStyle = context.labelSmall.copyWith(color: AppColor.hintText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.dateTime != null) ...[
          AppText(section.dateTime!, style: metaStyle),
          6.height,
        ],
        if (section.tag != null) ...[
          AppText(section.tag!, style: metaStyle.copyWith(letterSpacing: 0.5)),
          6.height,
        ],
        AppText(
          section.title,
          style: context.headlineMedium.copyWith(color: _textDark),
        ),
        if (section.body != null) ...[
          12.height,
          AppText(
            section.body!,
            style: context.bodySmall.copyWith(
              color: AppColor.hintText,
              height: 1.6,
            ),
          ),
        ],
        if (section.quote != null) ...[
          14.height,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.w, color: AppColor.primary),
                12.width,
                Expanded(
                  child: AppText(
                    section.quote!,
                    style: context.titleMedium.copyWith(
                      color: _textDark,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (section.images.isNotEmpty) ...[
          16.height,
          _ImageCarousel(images: section.images),
        ],
        if (section.caption != null) ...[
          10.height,
          AppText(section.caption!, style: metaStyle),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 280.h,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CachedImage(
                imgUrl: widget.images[i],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _index ? 18.w : 6.w,
                      height: 6.w,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.r),
                        color: i == _index
                            ? AppColor.secondary
                            : AppColor.white.withValues(alpha: 0.7),
                      ),
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
