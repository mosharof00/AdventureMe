import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/itinerary_controller.dart';

class CompletedItineraryCard extends GetView<ItineraryController> {
  const CompletedItineraryCard({super.key, required this.trip});

  final TripListItem trip;

  @override
  Widget build(BuildContext context) {
    final tracking = trip.trackingDisplay;

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
              trip.hasCover
                  ? CachedImage(
                      imgUrl: trip.coverUrl!,
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      Assets.images.itinearyBgImage.path,
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
                      trip.title ?? 'Untitled Trip',
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
                            '${trip.destinedPlace ?? '--'}  -  ${controller.dateRange(trip)}',
                            style: context.labelSmall.copyWith(
                              color: AppColor.white,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    if (tracking != null && tracking.isNotEmpty) ...[
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
                            '$tracking Tracking',
                            style: context.labelSmall.copyWith(
                              color: AppColor.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () => controller.onEditThumbnail(trip),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: AppSvgIcon(
                      Assets.icons.editIcon,
                      size: 16.sp,
                      color: AppColor.white,
                    ),
                  ),
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
                  onTap: () => controller.onViewDetails(trip),
                  width: 130.w,
                  height: 35.h,
                ),
                const Spacer(),
                _CircleAction(
                  icon: Icons.share_outlined,
                  onTap: () => controller.onShare(trip),
                ),
                10.width,
                _CircleAction(
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: () => controller.onScan(trip),
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
