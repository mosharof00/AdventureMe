import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/gen/assets.gen.dart';

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.editable = true,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onTap,
    this.hintText,
  });

  /// Makes the field read-only and tappable (e.g. to open a picker).
  final VoidCallback? onTap;
  final String? hintText;

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool editable;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  static const _dividerColor = Color(0xFFE8E8E8);
  static const _labelColor = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: context.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: _labelColor,
          ),
        ),
        6.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                readOnly: !editable || onTap != null,
                enabled: editable,
                onTap: onTap,
                maxLines: maxLines,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                validator: validator,
                style: context.bodyMedium.copyWith(
                  color: AppColor.hintText,
                  height: 1.4,
                ),
                cursorColor: AppColor.primary,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hintText,
                  hintStyle: context.bodyMedium.copyWith(
                    color: AppColor.hintText.withValues(alpha: 0.5),
                  ),
                  errorMaxLines: 2,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            if (editable && (focusNode != null || onTap != null)) ...[
              8.width,
              GestureDetector(
                onTap: onTap ?? () => focusNode!.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: AppSvgIcon(
                    Assets.icons.editIcon,
                    size: 16.sp,
                    color: const Color(0xFF25314C),
                  ),
                ),
              ),
            ],
          ],
        ),
        12.height,
        const Divider(height: 1, thickness: 1, color: _dividerColor),
      ],
    );
  }
}
