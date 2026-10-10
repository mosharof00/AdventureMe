import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/view_itinerary_map_controller.dart';

/// Adds a manual checkpoint at the current location; pops `true` once saved.
class MarkCheckpointDialog extends StatefulWidget {
  const MarkCheckpointDialog({
    super.key,
    required this.dayNumber,
    this.date,
  });

  final int dayNumber;
  final DateTime? date;

  static Future<bool> show({required int dayNumber, DateTime? date}) async {
    final saved = await Get.dialog<bool>(
      MarkCheckpointDialog(dayNumber: dayNumber, date: date),
      barrierDismissible: false,
    );
    return saved == true;
  }

  @override
  State<MarkCheckpointDialog> createState() => _MarkCheckpointDialogState();
}

class _MarkCheckpointDialogState extends State<MarkCheckpointDialog> {
  final _controller = Get.find<ViewItineraryMapController>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();

  late final DateTime _day;
  late DateTime _enteredAt;
  late DateTime _exitedAt;

  double? _lat;
  double? _lng;
  bool _locating = true;

  bool _submitted = false;
  bool _saving = false;

  static final _time = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final date = widget.date?.toLocal() ?? now;
    _day = DateTime(date.year, date.month, date.day);

    final isToday = DateUtils.isSameDay(_day, now);
    _exitedAt = isToday ? now : _day.add(const Duration(hours: 10, minutes: 30));
    final entered = _exitedAt.subtract(const Duration(minutes: 30));
    _enteredAt = entered.isBefore(_day) ? _day : entered;

    _locate();
  }

  String? get _titleError => _submitted && _titleController.text.trim().isEmpty
      ? 'Name this checkpoint'
      : null;

  String? get _addressError =>
      _submitted && _addressController.text.trim().isEmpty
      ? 'Add the address'
      : null;

  String? get _locationError =>
      _submitted && _lat == null ? 'Location is required' : null;

  String? get _timeError => _submitted && !_exitedAt.isAfter(_enteredAt)
      ? 'Left time must be after arrival'
      : null;

  Future<void> _locate() async {
    if (!_locating) setState(() => _locating = true);
    final position = await _controller.currentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (position != null) {
        _lat = position.latitude;
        _lng = position.longitude;
      }
    });
    if (position != null) _fillAddress(position.latitude, position.longitude);
  }

  /// Last address filled in automatically; a user-edited address is kept.
  String? _autoAddress;
  bool _resolvingAddress = false;

  Future<void> _fillAddress(double lat, double lng) async {
    final current = _addressController.text.trim();
    if (current.isNotEmpty && current != _autoAddress) return;

    setState(() => _resolvingAddress = true);
    final address = await _controller.addressFrom(lat, lng);
    if (!mounted) return;
    setState(() {
      _resolvingAddress = false;
      final text = _addressController.text.trim();
      if (address != null && (text.isEmpty || text == _autoAddress)) {
        _addressController.text = address;
        _autoAddress = address;
      }
    });
  }

  Future<void> _pickTime(bool entered) async {
    final current = entered ? _enteredAt : _exitedAt;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null || !mounted) return;
    final value = _day.add(
      Duration(hours: picked.hour, minutes: picked.minute),
    );
    setState(() => entered ? _enteredAt = value : _exitedAt = value);
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _submitted = true);
    if (_titleError != null ||
        _addressError != null ||
        _locationError != null ||
        _timeError != null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    final ok = await _controller.saveCheckpoint(
      day: widget.dayNumber,
      title: _titleController.text.trim(),
      address: _addressController.text.trim(),
      lat: _lat!,
      lng: _lng!,
      enteredAt: _enteredAt,
      exitedAt: _exitedAt,
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
    _titleController.dispose();
    _addressController.dispose();
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
                    'Mark Checkpoint',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                6.height,
                Center(
                  child: AppText(
                    'Day ${widget.dayNumber} · '
                    '${DateFormat('MMM d, yyyy').format(_day)}',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.hintText,
                    ),
                  ),
                ),
                20.height,
                _Label('Title'),
                10.height,
                _field(
                  context,
                  controller: _titleController,
                  hint: 'e.g. Ferry to Positano',
                  error: _titleError,
                ),
                16.height,
                _Label('Address'),
                10.height,
                _field(
                  context,
                  controller: _addressController,
                  hint: _resolvingAddress
                      ? 'Finding address…'
                      : 'e.g. Molo Beverello, Naples',
                  error: _addressError,
                  maxLines: 3,
                  suffix: _resolvingAddress
                      ? Padding(
                          padding: EdgeInsets.all(14.r),
                          child: GlobalLoading(size: 16.sp),
                        )
                      : null,
                ),
                16.height,
                _Label('Location'),
                10.height,
                _locationTile(context),
                if (_locationError != null) _Error(_locationError!),
                16.height,
                Row(
                  children: [
                    Expanded(
                      child: _TimeField(
                        label: 'Arrived',
                        value: _time.format(_enteredAt),
                        onTap: _saving ? null : () => _pickTime(true),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: _TimeField(
                        label: 'Left',
                        value: _time.format(_exitedAt),
                        onTap: _saving ? null : () => _pickTime(false),
                      ),
                    ),
                  ],
                ),
                if (_timeError != null) _Error(_timeError!),
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

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    String? error,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      enabled: !_saving,
      minLines: 1,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) {
        if (_submitted) setState(() {});
      },
      style: context.bodyMedium,
      cursorColor: AppColor.primary,
      decoration: buildAppInputDecoration(
        context: context,
        hintText: hint,
        errorText: error,
        suffixIcon: suffix,
      ),
    );
  }

  Widget _locationTile(BuildContext context) {
    final text = _locating
        ? 'Getting your location…'
        : _lat == null
        ? 'Location unavailable'
        : '${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}';

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 4.w, 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: AppColor.primary, size: 20.sp),
          10.width,
          Expanded(
            child: AppText(
              text,
              style: context.bodyMedium.copyWith(
                color: _lat == null ? AppColor.hintText : const Color(0xFF2D2D2D),
              ),
            ),
          ),
          _locating
              ? Padding(
                  padding: EdgeInsets.all(12.r),
                  child: GlobalLoading(size: 18.sp),
                )
              : IconButton(
                  onPressed: _saving ? null : _locate,
                  icon: Icon(
                    Icons.my_location_rounded,
                    color: AppColor.primary,
                    size: 20.sp,
                  ),
                ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        10.height,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColor.primary,
                  size: 18.sp,
                ),
                8.width,
                AppText(value, style: context.bodyMedium),
              ],
            ),
          ),
        ),
      ],
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
