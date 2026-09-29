import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_svg_icon.dart';
import 'package:adventureme/gen/assets.gen.dart';

import '../controllers/create_new_trip_controller.dart';

class TripDetailsStep extends GetView<CreateNewTripController> {
  const TripDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputTextFormField(
            label: 'Your Trip Title',
            hintText: 'e.g. Florida Adventure',
            controller: controller.titleController,
            validator: controller.validateTitle,
            fillColor: const Color(0xFFFFFCF8),
            enabledBorderColor: Colors.transparent,
          ),
          18.height,
          AppInputTextFormField(
            label: 'Starting Place',
            hintText: 'e.g. Florida',
            controller: controller.startingPlaceController,
            validator: controller.validateStartingPlace,
            fillColor: const Color(0xFFFFFCF8),
            enabledBorderColor: Colors.transparent,
          ),
          18.height,
          AppInputTextFormField(
            label: 'Destined Place',
            hintText: 'e.g. Brazil',
            controller: controller.destinedPlaceController,
            validator: controller.validateDestinedPlace,
            fillColor: const Color(0xFFFFFCF8),
            enabledBorderColor: Colors.transparent,
          ),
          18.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInputTextFormField(
                  label: 'Starting Date',
                  hintText: 'mm/dd/yyyy',
                  controller: controller.startDateController,
                  validator: controller.validateStartDate,
                  readOnly: true,
                  onTap: () => controller.pickStartDate(context),
                  fillColor: const Color(0xFFFFFCF8),
                  enabledBorderColor: Colors.transparent,
                  suffixIcon: _calendarIcon(),
                ),
              ),
              16.width,
              Expanded(
                child: AppInputTextFormField(
                  label: 'Ending Date',
                  hintText: 'mm/dd/yyyy',
                  controller: controller.endDateController,
                  validator: controller.validateEndDate,
                  readOnly: true,
                  onTap: () => controller.pickEndDate(context),
                  fillColor: const Color(0xFFFFFCF8),
                  enabledBorderColor: Colors.transparent,
                  suffixIcon: _calendarIcon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarIcon() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: AppSvgIcon(
        Assets.icons.calendarIcon,
        size: 18.sp,
        color: AppColor.primary,
      ),
    );
  }
}
