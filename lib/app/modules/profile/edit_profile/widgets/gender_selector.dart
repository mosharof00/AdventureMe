import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/edit_profile_controller.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProfileGender? selected;
  final ValueChanged<ProfileGender> onChanged;

  static const _options = <(ProfileGender, String)>[
    (ProfileGender.female, 'Female'),
    (ProfileGender.male, 'Male'),
    (ProfileGender.others, 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Gender',
          style: context.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        12.height,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            children: [
              for (final (gender, label) in _options)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(gender),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected == gender
                            ? AppColor.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        label,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected == gender
                              ? AppColor.white
                              : const Color(0xFF5A5A5A),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
