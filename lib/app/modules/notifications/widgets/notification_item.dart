import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/notifications_controller.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    this.showDivider = true,
    this.onTap,
  });

  final AppNotification notification;
  final bool showDivider;
  final VoidCallback? onTap;

  static const _iconBg = Color(0xFFA8B8D8);
  static const _titleColor = Color(0xFF2D2D2D);
  static const _dividerColor = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: _iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.ssid_chart_rounded,
                    size: 18.sp,
                    color: AppColor.white,
                  ),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppText(
                              notification.title,
                              style: context.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _titleColor,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (notification.isUnread) ...[
                            8.width,
                            Container(
                              width: 8.w,
                              height: 8.w,
                              margin: EdgeInsets.only(top: 4.h),
                              decoration: const BoxDecoration(
                                color: AppColor.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      4.height,
                      AppText(
                        notification.body,
                        style: context.bodySmall.copyWith(
                          color: AppColor.hintText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                      ),
                      6.height,
                      AppText(
                        notification.timeAgo,
                        style: context.labelSmall.copyWith(
                          color: AppColor.grey410,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: _dividerColor,
            ),
        ],
      ),
    );
  }
}
