import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/profile_controller.dart';

class ProfileInfoCard extends GetView<ProfileController> {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Personal Info',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          12.height,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              final user = controller.user.value;
              final rows = <(IconData, String, String?)>[
                (
                  Icons.alternate_email_rounded,
                  'Username',
                  user?.username == null ? null : '@${user!.username}',
                ),
                (Icons.mail_outline_rounded, 'Email', user?.email),
                (Icons.phone_outlined, 'Phone', user?.phoneNumber),
                (Icons.person_outline_rounded, 'Gender', _titleCase(user?.gender)),
                (
                  Icons.cake_outlined,
                  'Date of Birth',
                  user?.dateOfBirth == null
                      ? null
                      : DateFormat('MMM d, yyyy').format(user!.dateOfBirth!),
                ),
              ];

              return Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _InfoRow(
                      icon: rows[i].$1,
                      label: rows[i].$2,
                      value: rows[i].$3,
                    ),
                    if (i != rows.length - 1)
                      Divider(
                        height: 1,
                        color: AppColor.hintText.withValues(alpha: 0.15),
                      ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  static String? _titleCase(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColor.primary),
          12.width,
          AppText(
            label,
            style: context.bodyMedium.copyWith(color: AppColor.hintText),
          ),
          12.width,
          Expanded(
            child: AppText(
              (value == null || value!.isEmpty) ? '—' : value!,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
