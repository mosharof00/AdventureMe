import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

typedef IntentionSubmit =
    Future<bool> Function(
      IntentionType type,
      List<String> tags,
      String intention,
    );

/// Collects the trip's intention; pops `true` once [onSubmit] succeeds.
class TripIntentionDialog extends StatefulWidget {
  const TripIntentionDialog({super.key, required this.onSubmit});

  final IntentionSubmit onSubmit;

  static Future<bool> show({required IntentionSubmit onSubmit}) async {
    final saved = await Get.dialog<bool>(
      TripIntentionDialog(onSubmit: onSubmit),
      barrierDismissible: false,
    );
    return saved == true;
  }

  @override
  State<TripIntentionDialog> createState() => _TripIntentionDialogState();
}

class _TripIntentionDialogState extends State<TripIntentionDialog> {
  final _tagController = TextEditingController();
  final _tagFocus = FocusNode();
  final _intentionController = TextEditingController();

  IntentionType? _type;
  final List<String> _tags = [];
  bool _submitted = false;
  bool _saving = false;

  String? get _typeError => _submitted && _type == null
      ? 'Select why you are taking this trip'
      : null;

  String? get _tagsError =>
      _submitted && _tags.isEmpty ? 'Add at least one tag' : null;

  String? get _intentionError =>
      _submitted && _intentionController.text.trim().isEmpty
      ? 'Tell us a little about this trip'
      : null;

  void _addTag([String? raw]) {
    final tag = (raw ?? _tagController.text).trim();
    _tagController.clear();
    if (tag.isNotEmpty &&
        !_tags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
      setState(() => _tags.add(tag));
    }
    _tagFocus.requestFocus();
  }

  void _onTagChanged(String value) {
    if (value.endsWith(',')) _addTag(value.substring(0, value.length - 1));
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (_tagController.text.trim().isNotEmpty) _addTag();
    setState(() => _submitted = true);
    final type = _type;
    final intention = _intentionController.text.trim();
    if (type == null || _tags.isEmpty || intention.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    final ok = await widget.onSubmit(type, List.of(_tags), intention);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) _close(true);
  }

  void _cancel() {
    if (!_saving) _close(false);
  }

  /// While a snackbar is showing, `Get.back()` only closes the snackbar.
  void _close(bool saved) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.back(result: saved);
  }

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocus.dispose();
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AppText(
                    'Before You Go',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                6.height,
                Center(
                  child: AppText(
                    'Tell us why this trip matters. It helps us tell your story.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
                20.height,
                _Label('Why this trip?'),
                10.height,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final type in IntentionType.values)
                      ChoiceChip(
                        label: Text(type.label),
                        selected: _type == type,
                        onSelected: _saving
                            ? null
                            : (_) => setState(() => _type = type),
                        showCheckmark: false,
                        selectedColor: AppColor.primary,
                        backgroundColor: AppColor.white,
                        labelStyle: context.labelLarge.copyWith(
                          color: _type == type
                              ? AppColor.white
                              : const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _type == type
                              ? AppColor.primary
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                  ],
                ),
                if (_typeError != null) _Error(_typeError!),
                20.height,
                _Label('Tags'),
                10.height,
                if (_tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final tag in _tags)
                        InputChip(
                          label: Text(tag),
                          onDeleted: _saving
                              ? null
                              : () => setState(() => _tags.remove(tag)),
                          deleteIconColor: AppColor.primary,
                          backgroundColor: AppColor.primary.withValues(
                            alpha: 0.08,
                          ),
                          labelStyle: context.labelLarge.copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                    ],
                  ),
                  10.height,
                ],
                TextField(
                  controller: _tagController,
                  focusNode: _tagFocus,
                  enabled: !_saving,
                  textInputAction: TextInputAction.done,
                  onChanged: _onTagChanged,
                  onSubmitted: _addTag,
                  style: context.bodyMedium,
                  cursorColor: AppColor.primary,
                  decoration: buildAppInputDecoration(
                    context: context,
                    hintText: 'Type a tag and press enter',
                    errorText: _tagsError,
                    suffixIcon: IconButton(
                      onPressed: _saving ? null : _addTag,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColor.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
                20.height,
                _Label('Your intention'),
                10.height,
                TextField(
                  controller: _intentionController,
                  enabled: !_saving,
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_submitted) setState(() {});
                  },
                  style: context.bodyMedium,
                  cursorColor: AppColor.primary,
                  decoration: buildAppInputDecoration(
                    context: context,
                    hintText: 'e.g. Uninterrupted time together as a family…',
                    errorText: _intentionError,
                  ),
                ),
                24.height,
                Row(
                  children: [
                    Expanded(
                      child: GlobalButton(
                        text: 'Cancel',
                        color: const Color(0xFFD6E4F0),
                        textColor: const Color(0xFF2D2D2D),
                        isDisabled: _saving,
                        onTap: _cancel,
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: GlobalButton(
                        text: 'Continue',
                        onTap: _submit,
                        widget: _saving
                            ? GlobalLoading(size: 22.sp, color: AppColor.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          text,
          style: context.titleSmall.copyWith(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
        AppText(
          '*',
          style: context.titleSmall.copyWith(color: Colors.red.shade800),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 4.w),
      child: AppText(
        text,
        style: context.labelSmall.copyWith(color: AppColor.error),
      ),
    );
  }
}
