import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/global/widgets/global_snackbar.dart';
import 'package:adventureme/app/global/widgets/voice_player.dart';

import '../controllers/itinerary_details_controller.dart';

/// Captures a quick note or a voice memory; pops `true` once it is saved.
class AddMemoryDialog extends StatefulWidget {
  const AddMemoryDialog({super.key});

  static Future<bool> show() async {
    final saved = await Get.dialog<bool>(
      const AddMemoryDialog(),
      barrierDismissible: false,
    );
    return saved == true;
  }

  @override
  State<AddMemoryDialog> createState() => _AddMemoryDialogState();
}

class _AddMemoryDialogState extends State<AddMemoryDialog> {
  final _controller = Get.find<ItineraryDetailsController>();
  final _noteController = TextEditingController();
  final _recorder = AudioRecorder();

  MemorySource _source = MemorySource.quickNote;
  late int _day = _controller.todayDayNumber;

  bool _isRecording = false;
  File? _voice;
  Duration _recorded = Duration.zero;
  Timer? _ticker;

  /// 0–1 loudness samples taken while recording, drawn as the waveform.
  final _levels = <double>[];
  StreamSubscription<Amplitude>? _amplitudeSub;

  bool _submitted = false;
  bool _saving = false;

  String? get _error {
    if (!_submitted) return null;
    if (_source == MemorySource.quickNote) {
      return _noteController.text.trim().isEmpty ? 'Write a quick note' : null;
    }
    if (_isRecording) return 'Stop the recording first';
    return _voice == null ? 'Record a voice memory' : null;
  }

  // ── Recording ────────────────────────────────────────
  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      globalSnackBar(
        title: 'Microphone',
        message: 'Allow microphone access in Settings to record a memory.',
      );
      return;
    }
    if (!mounted) return;
    if (_voice != null) _discardVoice();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/memory_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recorded = Duration.zero;
      _levels.clear();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recorded += const Duration(seconds: 1));
    });
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
          // dBFS: about -50 is silence, 0 is the loudest.
          final level = ((amp.current + 50) / 50).clamp(0.08, 1.0);
          if (mounted) setState(() => _levels.add(level));
        });
  }

  Future<void> _stopRecording() async {
    _ticker?.cancel();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _voice = path == null ? null : File(path);
    });
  }

  void _discardVoice() {
    _deleteFile(_voice);
    setState(() {
      _voice = null;
      _recorded = Duration.zero;
      _levels.clear();
    });
  }

  void _deleteFile(File? file) {
    if (file != null && file.existsSync()) file.deleteSync();
  }

  // ── Submit ───────────────────────────────────────────
  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _submitted = true);
    if (_error != null) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    final isNote = _source == MemorySource.quickNote;
    final ok = await _controller.saveMemory(
      day: _day,
      source: _source,
      text: isNote ? _noteController.text.trim() : null,
      voice: isNote ? null : _voice,
    );
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
    _ticker?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _deleteFile(_voice);
    _noteController.dispose();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────
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
                    'Add a Memory',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                6.height,
                Center(
                  child: AppText(
                    'Capture how this moment feels. It helps us tell your story.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
                20.height,
                _sourceTabs(context),
                20.height,
                _Label('Day'),
                10.height,
                _dayDropdown(context),
                20.height,
                if (_source == MemorySource.quickNote) ...[
                  _Label('Quick note'),
                  10.height,
                  TextField(
                    controller: _noteController,
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
                      hintText: 'e.g. Dad laughed so hard he spilled his wine.',
                      errorText: _error,
                    ),
                  ),
                ] else ...[
                  _Label('Voice'),
                  10.height,
                  _voiceRecorder(context),
                  if (_error != null) _Error(_error!),
                ],
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
                        text: 'Submit',
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

  Widget _sourceTabs(BuildContext context) {
    final locked = _saving || _isRecording;
    return Row(
      children: [
        for (final source in MemorySource.values) ...[
          Expanded(
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      source == MemorySource.quickNote
                          ? Icons.edit_note_rounded
                          : Icons.mic_none_rounded,
                      size: 18.sp,
                      color: _source == source
                          ? AppColor.white
                          : AppColor.primary,
                    ),
                    6.width,
                    Text(source.label),
                  ],
                ),
              ),
              selected: _source == source,
              onSelected: locked
                  ? null
                  : (_) => setState(() {
                      _source = source;
                      _submitted = false;
                    }),
              showCheckmark: false,
              selectedColor: AppColor.primary,
              backgroundColor: AppColor.white,
              labelStyle: context.labelLarge.copyWith(
                color: _source == source
                    ? AppColor.white
                    : const Color(0xFF2D2D2D),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: _source == source
                    ? AppColor.primary
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          if (source != MemorySource.values.last) 12.width,
        ],
      ],
    );
  }

  Widget _dayDropdown(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _day,
      isExpanded: true,
      borderRadius: BorderRadius.circular(14.r),
      dropdownColor: AppColor.white,
      style: context.bodyMedium.copyWith(color: const Color(0xFF2D2D2D)),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColor.primary,
        size: 22.sp,
      ),
      decoration: buildAppInputDecoration(context: context),
      items: [
        for (final day in _controller.days)
          DropdownMenuItem(
            value: day.dayNumber,
            child: Text('${day.dayLabel}  ·  ${day.date}'),
          ),
      ],
      onChanged: _saving
          ? null
          : (value) {
              if (value != null) setState(() => _day = value);
            },
    );
  }

  Widget _voiceRecorder(BuildContext context) {
    final voice = _voice;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: voice != null && !_isRecording
          ? Row(
              children: [
                Expanded(
                  child: VoicePlayer(
                    key: ValueKey(voice.path),
                    path: voice.path,
                    levels: List.of(_levels),
                    initialDuration: _recorded,
                    enabled: !_saving,
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : _discardVoice,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColor.error,
                    size: 22.sp,
                  ),
                ),
              ],
            )
          : _recordingRow(context),
    );
  }

  /// Mic button before recording; stop button with live bars while recording.
  Widget _recordingRow(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: _saving
              ? null
              : _isRecording
              ? _stopRecording
              : _startRecording,
          child: Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColor.error : AppColor.primary,
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: AppColor.white,
              size: 26.sp,
            ),
          ),
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isRecording)
                SizedBox(
                  height: 32.h,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: VoiceWaveformPainter(
                      levels: _liveLevels,
                      progress: 1,
                      playedColor: AppColor.error,
                    ),
                  ),
                )
              else
                AppText(
                  'Tap the mic to start recording',
                  style: context.titleSmall.copyWith(
                    color: const Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              4.height,
              AppText(
                _isRecording
                    ? 'Recording  ${formatVoiceDuration(_recorded)}'
                    : formatVoiceDuration(_recorded),
                style: context.labelSmall.copyWith(
                  color: _isRecording ? AppColor.error : AppColor.hintText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The latest samples, padded on the left so new bars enter from the right.
  List<double> get _liveLevels {
    const count = 32;
    final recent = _levels.length > count
        ? _levels.sublist(_levels.length - count)
        : _levels;
    return [...List.filled(count - recent.length, 0.08), ...recent];
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
