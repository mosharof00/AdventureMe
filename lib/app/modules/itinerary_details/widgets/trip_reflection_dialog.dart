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

import '../controllers/itinerary_details_controller.dart';

/// Asks how a finished trip felt; pops `true` once it is saved.
class TripReflectionDialog extends StatefulWidget {
  const TripReflectionDialog({super.key, this.intention});

  /// What the user said before the trip, shown as a reminder.
  final String? intention;

  static Future<bool> show({String? intention}) async {
    final saved = await Get.dialog<bool>(
      TripReflectionDialog(intention: intention),
      barrierDismissible: false,
    );
    return saved == true;
  }

  @override
  State<TripReflectionDialog> createState() => _TripReflectionDialogState();
}

class _TripReflectionDialogState extends State<TripReflectionDialog> {
  final _reflectionController = TextEditingController();

  DominantEmotion? _emotion;
  bool _submitted = false;
  bool _saving = false;

  String? get _emotionError => _submitted && _emotion == null
      ? 'Pick the feeling that stayed with you'
      : null;

  String? get _reflectionError =>
      _submitted && _reflectionController.text.trim().isEmpty
      ? 'Tell us a little about how it went'
      : null;

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _submitted = true);
    final emotion = _emotion;
    final reflection = _reflectionController.text.trim();
    if (emotion == null || reflection.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    final ok = await Get.find<ItineraryDetailsController>().saveReflection(
      reflection,
      emotion,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) _close(true);
  }

  void _later() {
    if (!_saving) _close(false);
  }

  /// While a snackbar is showing, `Get.back()` only closes the snackbar.
  void _close(bool saved) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.back(result: saved);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intention = widget.intention?.trim() ?? '';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _later();
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
                    'Looking Back',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                6.height,
                Center(
                  child: AppText(
                    'Your adventure is complete. What stayed with you?',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
                if (intention.isNotEmpty) ...[
                  16.height,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Before this trip, you said',
                          style: context.labelSmall.copyWith(
                            color: AppColor.hintText,
                          ),
                        ),
                        4.height,
                        AppText(
                          '"$intention"',
                          style: context.bodyMedium.copyWith(
                            color: const Color(0xFF2D2D2D),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ],
                20.height,
                _Label('How did it feel?'),
                10.height,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final emotion in DominantEmotion.values)
                      ChoiceChip(
                        label: Text('${emotion.emoji}  ${emotion.label}'),
                        selected: _emotion == emotion,
                        onSelected: _saving
                            ? null
                            : (_) => setState(() => _emotion = emotion),
                        showCheckmark: false,
                        selectedColor: AppColor.primary,
                        backgroundColor: AppColor.white,
                        labelStyle: context.labelLarge.copyWith(
                          color: _emotion == emotion
                              ? AppColor.white
                              : const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _emotion == emotion
                              ? AppColor.primary
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                  ],
                ),
                if (_emotionError != null) _Error(_emotionError!),
                20.height,
                _Label('Your reflection'),
                10.height,
                TextField(
                  controller: _reflectionController,
                  enabled: !_saving,
                  minLines: 4,
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
                    hintText:
                        'e.g. We still laugh about the day it rained on us…',
                    errorText: _reflectionError,
                  ),
                ),
                24.height,
                Row(
                  children: [
                    Expanded(
                      child: GlobalButton(
                        text: 'Later',
                        color: const Color(0xFFD6E4F0),
                        textColor: const Color(0xFF2D2D2D),
                        isDisabled: _saving,
                        onTap: _later,
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: GlobalButton(
                        text: 'Save',
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
