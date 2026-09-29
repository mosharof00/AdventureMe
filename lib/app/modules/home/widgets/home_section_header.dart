import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/gen/assets.gen.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.showViewAll = false,
  });

  final String title;
  final VoidCallback? onViewAll;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              title,
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  AppText(
                    'View All',
                    style: context.bodySmall.copyWith(
                      color: AppColor.hintText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  2.width,
                  AppSvgIcon(Assets.icons.arrowForwordIcon, size: 16.sp),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
