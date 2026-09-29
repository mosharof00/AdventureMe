import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/custom_icon_button.dart';

import '../controllers/notifications_controller.dart';
import '../widgets/notification_item.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: "Notifications",
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        itemCount: controller.sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = controller.sections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sectionIndex > 0) 28.height,
              AppText(
                section.label,
                style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              4.height,
              ...List.generate(section.items.length, (i) {
                final item = section.items[i];
                return NotificationItem(
                  notification: item,
                  showDivider: i < section.items.length - 1,
                  onTap: () => controller.onNotificationTap(item),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
