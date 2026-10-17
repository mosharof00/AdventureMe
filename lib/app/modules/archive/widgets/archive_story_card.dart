import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/data/models/feed_models/feed_model.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/archive_controller.dart';

class ArchiveStoryCard extends GetView<ArchiveController> {
  const ArchiveStoryCard({super.key, required this.story});

  final FeedItem story;

  static const String defaultCover =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800';

  @override
  Widget build(BuildContext context) {
    final coverImage =
        story.coverUrl?.isNotEmpty == true ? story.coverUrl! : defaultCover;
    final views = story.viewsDisplay ??
        (story.viewsCount != null ? '${story.viewsCount}' : '0');
    final subtitle = story.subtitle ??
        (story.placeDisplay != null
            ? '${story.placeDisplay}${story.dateRangeDisplay != null ? "  -  ${story.dateRangeDisplay}" : ""}'
            : (story.dateRangeDisplay ?? ''));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.onStoryTap(story),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Stack(
                children: [
                  CachedImage(
                    imgUrl: coverImage,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // View count badge
                  Positioned(
                    left: 12.w,
                    top: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 14.sp,
                            color: AppColor.white,
                          ),
                          5.width,
                          AppText(
                            views,
                            style: context.labelSmall.copyWith(
                              color: AppColor.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Title + subtitle
                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          story.title,
                          style: context.titleMedium.copyWith(
                            color: AppColor.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          8.height,
                          Row(
                            children: [
                              AppSvgIcon(
                                Assets.icons.locationIcon,
                                size: 13.sp,
                                color: AppColor.white,
                              ),
                              5.width,
                              Flexible(
                                child: AppText(
                                  subtitle,
                                  style: context.labelSmall.copyWith(
                                    color: AppColor.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          10.height,
          _AuthorRow(story: story),
        ],
      ),
    );
  }
}

class _AuthorRow extends GetView<ArchiveController> {
  const _AuthorRow({required this.story});

  final FeedItem story;

  @override
  Widget build(BuildContext context) {
    final avatar = story.author?.avatarUrl?.isNotEmpty == true
        ? story.author!.avatarUrl!
        : HelperUtils.defaultProfileImage;
    final authorName = story.author?.name?.isNotEmpty == true
        ? story.author!.name!
        : 'Unknown Explorer';

    return Row(
      children: [
        ClipOval(
          child: CachedImage(
            imgUrl: avatar,
            height: 28.w,
            width: 28.w,
            fit: BoxFit.cover,
          ),
        ),
        8.width,
        Expanded(
          child: AppText(
            authorName,
            style: context.bodySmall.copyWith(
              color: const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ),
        8.width,
        GestureDetector(
          onTap: () => controller.onShare(story),
          child: Icon(
            Icons.share_outlined,
            size: 20.sp,
            color: AppColor.primary,
          ),
        ),
        16.width,
        Obx(
          () => GestureDetector(
            onTap: () => controller.toggleBookmark(story),
            child: Icon(
              controller.isBookmarked(story.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              size: 20.sp,
              color: controller.isBookmarked(story.id)
                  ? AppColor.primary
                  : AppColor.primary,
            ),
          ),
        ),
      ],
    );
  }
}
