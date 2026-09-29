import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_scaffold.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/cached_image.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/edit_profile_controller.dart';
import '../widgets/edit_profile_field.dart';
import '../widgets/gender_selector.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: 'Profile Edit',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _InfoCard(controller: controller),
              20.height,
              GestureDetector(
                onTap: controller.onDeleteAccount,
                child: AppText(
                  'Delete Account',
                  style: context.bodyMedium.copyWith(
                    color: const Color(0xFFE57373),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Your Info',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          22.height,
          const _AvatarPicker(),
          28.height,
          EditProfileField(
            label: 'Full Name',
            controller: controller.fullNameController,
            focusNode: controller.fullNameFocus,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: controller.validateName,
          ),
          18.height,
          EditProfileField(
            label: 'Username',
            hintText: 'e.g. john_ryan',
            controller: controller.usernameController,
            focusNode: controller.usernameFocus,
            textInputAction: TextInputAction.next,
            validator: controller.validateUsername,
          ),
          18.height,
          EditProfileField(
            label: 'Email',
            controller: controller.emailController,
            editable: false,
            keyboardType: TextInputType.emailAddress,
          ),
          18.height,
          EditProfileField(
            label: 'Phone Number',
            hintText: '+8801712345678',
            controller: controller.phoneController,
            focusNode: controller.phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: controller.validatePhone,
          ),
          18.height,
          EditProfileField(
            label: 'Date of Birth',
            hintText: 'Select your date of birth',
            controller: controller.dateOfBirthController,
            onTap: () => controller.pickDateOfBirth(context),
          ),
          18.height,
          EditProfileField(
            label: 'Bio',
            hintText: 'Tell others a little about yourself',
            controller: controller.bioController,
            focusNode: controller.bioFocus,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          22.height,
          Obx(
            () => GenderSelector(
              selected: controller.selectedGender.value,
              onChanged: controller.selectGender,
            ),
          ),
          28.height,
          Obx(
            () => GlobalButton(
              text: 'Save Update',
              onTap: controller.onSave,
              widget: controller.isSaving.value
                  ? GlobalLoading(size: 24.sp, color: AppColor.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends GetView<EditProfileController> {
  const _AvatarPicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            final local = controller.localAvatar.value;
            return Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.secondary.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: local != null
                    ? Image.file(
                        local,
                        width: 110.w,
                        height: 110.w,
                        fit: BoxFit.cover,
                      )
                    : CachedImage(
                        imgUrl: controller.avatarUrl.value,
                        width: 110.w,
                        height: 110.w,
                        fit: BoxFit.cover,
                      ),
              ),
            );
          }),
          Positioned(
            right: 2.w,
            bottom: 2.w,
            child: GestureDetector(
              onTap: controller.onChangePhoto,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColor.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16.sp,
                  color: AppColor.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
