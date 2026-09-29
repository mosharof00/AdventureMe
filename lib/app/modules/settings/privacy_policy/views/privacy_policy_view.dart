import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/custom_icon_button.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Privacy Policy',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    controller.intro,
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                      height: 1.55,
                    ),
                    softWrap: true,
                  ),
                  28.height,
                  AppText(
                    'Information We Collect',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  20.height,
                  ...controller.sections.map(
                    (section) => Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${section.title}: ',
                              style: context.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2D2D),
                                height: 1.55,
                              ),
                            ),
                            TextSpan(
                              text: section.body,
                              style: context.bodyMedium.copyWith(
                                color: AppColor.hintText,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            child: GlobalButton(
              text: 'Back to Home',
              color: AppColor.primaryDisable,
              textColor: const Color(0xFF2D2D2D),
              onTap: controller.onBackToHome,
            ),
          ),
        ],
      ),
    );
  }
}
