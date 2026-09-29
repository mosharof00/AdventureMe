import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_controller.dart';

class CompletedItineraryCard extends GetView<ItineraryController> {
  const CompletedItineraryCard({
    super.key,
    required this.item,
    this.onDetailsTap,
  });

  final CompletedItinerary item;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColor.bgGradient2,
        borderRadius: BorderRadius.circular(18.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              CachedImage(
                imgUrl: item.imageUrl,
                width: double.infinity,
                height: 180.h,
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
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 12.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.title,
                      style: context.titleLarge.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                    ),
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
                            '${item.location}  -  ${item.dateRange}',
                            style: context.labelSmall.copyWith(
                              color: AppColor.white,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    5.height,
                    Row(
                      children: [
                        AppSvgIcon(
                          Assets.icons.clockIcon,
                          size: 13.sp,
                          color: AppColor.white,
                        ),
                        5.width,
                        AppText(
                          item.trackingHours,
                          style: context.labelSmall.copyWith(
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                GlobalButton(
                  text: 'View Details',
                  onTap: onDetailsTap ?? () {},
                  width: 130.w,
                  height: 35.h,
                ),
                const Spacer(),
                _CircleAction(
                  icon: Icons.share_outlined,
                  onTap: controller.onShare,
                ),
                10.width,
                _CircleAction(
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: controller.onScan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 35.w,
        decoration: const BoxDecoration(
          color: AppColor.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: AppColor.primary),
      ),
    );
  }
}
