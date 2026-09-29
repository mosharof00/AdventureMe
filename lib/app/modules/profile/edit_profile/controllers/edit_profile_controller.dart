import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/utils/helper_utils.dart';
import 'package:adventureme/app/core/utils/image_picker_helper.dart';
import 'package:adventureme/app/data/models/user_models/user_model.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/modules/home/controllers/home_controller.dart';
import 'package:adventureme/app/modules/profile/controllers/profile_controller.dart';
import 'package:adventureme/app/modules/profile/edit_profile/widgets/delete_account_dialog.dart';
import 'package:adventureme/app/routes/app_pages.dart';

enum ProfileGender {
  female('FEMALE'),
  male('MALE'),
  others('OTHER');

  const ProfileGender(this.apiValue);

  final String apiValue;

  static ProfileGender? fromApi(String? value) {
    for (final gender in values) {
      if (gender.apiValue == value?.toUpperCase()) return gender;
    }
    return null;
  }
}

class EditProfileController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final bioController = TextEditingController();

  final fullNameFocus = FocusNode();
  final usernameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final bioFocus = FocusNode();

  final selectedGender = Rxn<ProfileGender>();
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final avatarUrl = HelperUtils.defaultProfileImage.obs;
  final Rxn<File> localAvatar = Rxn<File>();
  final isSaving = false.obs;

  /// Snapshot of the loaded user, used to send only changed fields.
  UserData? _original;

  static final _displayDate = DateFormat('MMM d, yyyy');
  static final _username = RegExp(r'^[a-zA-Z0-9_.]{3,30}$');
  static final _phone = RegExp(r'^\+?[0-9]{7,15}$');

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    final user = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().user.value
        : null;
    _original = user;
    if (user == null) return;

    fullNameController.text = user.name ?? '';
    usernameController.text = user.plainUsername;
    emailController.text = user.email ?? '';
    phoneController.text = user.phoneNumber ?? '';
    bioController.text = user.about ?? '';
    selectedGender.value = ProfileGender.fromApi(user.gender);
    if (user.hasAvatar) avatarUrl.value = user.avatar!;

    final dob = user.dateOfBirth;
    if (dob != null) _setDateOfBirth(DateTime(dob.year, dob.month, dob.day));
  }

  // ── Validators ───────────────────────────────────────
  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateUsername(String? value) {
    final username = (value ?? '').trim().replaceFirst(RegExp(r'^@'), '');
    if (username.isEmpty) return 'Username is required';
    if (!_username.hasMatch(username)) {
      return '3–30 characters: letters, numbers, underscore or dot';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final phone = _normalizePhone(value);
    if (phone.isEmpty) return null;
    if (!_phone.hasMatch(phone)) return 'Enter a valid phone number, e.g. +8801712345678';
    return null;
  }

  String _normalizePhone(String? value) =>
      (value ?? '').replaceAll(RegExp(r'[\s()-]'), '');

  // ── Pickers ──────────────────────────────────────────
  void selectGender(ProfileGender gender) => selectedGender.value = gender;

  void focusField(FocusNode node) => node.requestFocus();

  Future<void> pickDateOfBirth(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final latest = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth.value ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: latest,
    );
    if (picked != null) _setDateOfBirth(picked);
  }

  void _setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
    dateOfBirthController.text = _displayDate.format(date);
  }

  Future<void> onChangePhoto() async {
    final source = await _pickImageSource();
    if (source == null) return;

    final file = await ImagePickerHelper.pickSingleFile(imageSource: source);
    if (file == null) return;

    localAvatar.value = File(file.path);
  }

  Future<ImageSource?> _pickImageSource() {
    return Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const AppText('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const AppText('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const AppText('Cancel'),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // ── Save ─────────────────────────────────────────────
  Future<void> onSave() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final original = _original;
    String? changed(String value, String? before) =>
        value == (before ?? '') ? null : value;

    final name = changed(fullNameController.text.trim(), original?.name);
    final username = changed(
      usernameController.text.trim().replaceFirst(RegExp(r'^@'), ''),
      original?.plainUsername,
    );
    final about = changed(bioController.text.trim(), original?.about);
    final phone = _normalizePhone(phoneController.text);
    final phoneNumber =
        phone.isEmpty ? null : changed(phone, original?.phoneNumber);
    final gender = selectedGender.value?.apiValue;
    final genderChanged = gender != null && gender != original?.gender;
    final dob = dateOfBirth.value;
    final originalDob = original?.dateOfBirth;
    final dobChanged = dob != null &&
        (originalDob == null ||
            dob.year != originalDob.year ||
            dob.month != originalDob.month ||
            dob.day != originalDob.day);
    final avatar = localAvatar.value;

    final hasChanges = name != null ||
        username != null ||
        about != null ||
        phoneNumber != null ||
        genderChanged ||
        dobChanged ||
        avatar != null;
    if (!hasChanges) {
      Get.back();
      return;
    }

    try {
      isSaving.value = true;
      final response = await _authRepository.updateProfile(
        name: name,
        username: username,
        about: about,
        gender: genderChanged ? gender : null,
        dateOfBirth: dobChanged ? dob : null,
        phoneNumber: phoneNumber,
        avatar: avatar,
      );

      final data = response.data;
      if (response.success != true || data == null) {
        globalSnackBar(
          title: 'Update Failed',
          message: response.message ?? 'Unable to update profile.',
        );
        return;
      }

      _applyUpdatedUser(data);
      Get.back();
      globalSnackBar(
        title: 'Profile Updated',
        message: response.message ?? 'Your profile has been saved successfully.',
        backgroundColor: AppColor.primary,
      );
    } catch (e) {
      handleException(e, context: 'Update Profile');
    } finally {
      isSaving.value = false;
    }
  }

  void _applyUpdatedUser(UserData data) {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().applyUser(data);
    }
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      final current = home.user.value;
      home.user.value = current == null ? data : current.merge(data);
    }
  }

  void onDeleteAccount() {
    DeleteAccountDialog.show(
      onCancel: () => Get.back(),
      onDelete: confirmDelete,
    );
  }

  void confirmDelete() {
    Get.back(); // close dialog
    globalSnackBar(
      title: 'Account Deleted',
      message: 'Your account has been deleted.',
      backgroundColor: AppColor.error,
    );
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    bioController.dispose();
    fullNameFocus.dispose();
    usernameFocus.dispose();
    phoneFocus.dispose();
    bioFocus.dispose();
    super.onClose();
  }
}
