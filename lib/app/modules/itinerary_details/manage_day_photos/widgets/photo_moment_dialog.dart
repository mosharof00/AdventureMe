import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/data/models/picked_location.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/modules/select_location/controllers/select_location_controller.dart';

/// Optional context sent with a photo upload.
class PhotoMoment {
  const PhotoMoment({this.title, this.quote, this.location});

  final String? title;
  final String? quote;
  final PickedLocation? location;
}

/// Asks for the moment's title, quote and place (all optional).
/// Returns `null` when cancelled.
class PhotoMomentDialog extends StatefulWidget {
  const PhotoMomentDialog({super.key, required this.photoCount});

  final int photoCount;

  static Future<PhotoMoment?> show({required int photoCount}) {
    return Get.dialog<PhotoMoment>(
      PhotoMomentDialog(photoCount: photoCount),
      barrierDismissible: false,
    );
  }

  @override
  State<PhotoMomentDialog> createState() => _PhotoMomentDialogState();
}

class _PhotoMomentDialogState extends State<PhotoMomentDialog> {
  final _titleController = TextEditingController();
  final _quoteController = TextEditingController();
  PickedLocation? _location;

  Future<void> _pickLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await SelectLocationController.pick(
      initial: _location,
      title: 'Where Was This?',
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  void _upload() {
    String? clean(String text) => text.trim().isEmpty ? null : text.trim();
    Get.back(
      result: PhotoMoment(
        title: clean(_titleController.text),
        quote: clean(_quoteController.text),
        location: _location,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photoCount;
    return Dialog(
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
                  'About This Moment',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              6.height,
              Center(
                child: AppText(
                  'Add a little context to your $count photo${count == 1 ? '' : 's'}. '
                  'Everything here is optional.',
                  style: context.bodyMedium.copyWith(color: AppColor.hintText),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              20.height,
              _Label('Title'),
              10.height,
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: context.bodyMedium,
                cursorColor: AppColor.primary,
                decoration: buildAppInputDecoration(
                  context: context,
                  hintText: 'e.g. Ferry to Positano',
                ),
              ),
              18.height,
              _Label('Quote'),
              10.height,
              TextField(
                controller: _quoteController,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: context.bodyMedium,
                cursorColor: AppColor.primary,
                decoration: buildAppInputDecoration(
                  context: context,
                  hintText: 'What did this moment feel like?',
                ),
              ),
              18.height,
              _Label('Location'),
              10.height,
              _LocationField(
                location: _location,
                onTap: _pickLocation,
                onClear: () => setState(() => _location = null),
              ),
              24.height,
              Row(
                children: [
                  Expanded(
                    child: GlobalButton(
                      text: 'Cancel',
                      color: const Color(0xFFD6E4F0),
                      textColor: const Color(0xFF2D2D2D),
                      onTap: () => Get.back(),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: GlobalButton(text: 'Upload', onTap: _upload),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.location,
    required this.onTap,
    required this.onClear,
  });

  final PickedLocation? location;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final picked = location;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 4.w, 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              picked == null
                  ? Icons.add_location_alt_outlined
                  : Icons.location_on_rounded,
              color: AppColor.primary,
              size: 20.sp,
            ),
            10.width,
            Expanded(
              child: AppText(
                picked?.label ?? 'Pick on map',
                style: context.bodyMedium.copyWith(
                  color: picked == null
                      ? AppColor.hintText
                      : const Color(0xFF2D2D2D),
                ),
                maxLines: 2,
              ),
            ),
            if (picked != null)
              IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColor.hintText,
                  size: 18.sp,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.hintText,
                  size: 20.sp,
                ),
              ),
          ],
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
    return AppText(
      text,
      style: context.titleSmall.copyWith(
        color: const Color(0xFF2D2D2D),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
