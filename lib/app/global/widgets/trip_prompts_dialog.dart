import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/extensions/sizedbox_extension.dart';
import '../../core/extensions/text_style_extension.dart';
import '../../core/services/trip_prompt_service.dart';
import '../../core/theme/app_color.dart';
import '../../data/models/trip_models/trip_prompt_model.dart';
import 'app_input_text_form_field.dart';
import 'app_text.dart';
import 'global_button.dart';
import 'global_loading.dart';

/// The daily context questions of a trip; blank answers are skipped.
/// Pops `true` once answers are saved.
class TripPromptsDialog extends StatefulWidget {
  const TripPromptsDialog({
    super.key,
    required this.tripId,
    required this.prompts,
    this.phase,
  });

  final String tripId;
  final String? phase;
  final List<TripPrompt> prompts;

  static Future<bool> show({
    required String tripId,
    required List<TripPrompt> prompts,
    String? phase,
  }) async {
    final saved = await Get.dialog<bool>(
      TripPromptsDialog(tripId: tripId, phase: phase, prompts: prompts),
      barrierDismissible: false,
    );
    return saved == true;
  }

  @override
  State<TripPromptsDialog> createState() => _TripPromptsDialogState();
}

class _TripPromptsDialogState extends State<TripPromptsDialog> {
  late final _controllers = {
    for (final prompt in widget.prompts) prompt.id: TextEditingController(),
  };
  bool _saving = false;

  /// `AFTERNOON` → `Afternoon`.
  String get _phaseLabel {
    final phase = widget.phase;
    if (phase == null || phase.isEmpty) return 'Today';
    return phase[0].toUpperCase() + phase.substring(1).toLowerCase();
  }

  Future<void> _save() async {
    if (_saving) return;
    final answers = {
      for (final entry in _controllers.entries)
        if (entry.value.text.trim().isNotEmpty)
          entry.key: entry.value.text.trim(),
    };

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    final ok = await Get.find<TripPromptService>().submit(
      widget.tripId,
      answers,
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
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    '$_phaseLabel Moments',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                6.height,
                Center(
                  child: AppText(
                    'A few words now become your story later. '
                    'Leave any question blank to skip it.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
                for (final prompt in widget.prompts) ...[
                  20.height,
                  AppText(
                    prompt.text,
                    style: context.titleSmall.copyWith(
                      color: const Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                  ),
                  10.height,
                  TextField(
                    controller: _controllers[prompt.id],
                    enabled: !_saving,
                    minLines: 2,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: context.bodyMedium,
                    cursorColor: AppColor.primary,
                    decoration: buildAppInputDecoration(
                      context: context,
                      hintText: 'Write a little…',
                    ),
                  ),
                ],
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
                        onTap: _save,
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
