import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:adventureme/app/core/extensions/sizedbox_extension.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_input_text_form_field.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/select_location_controller.dart';

class SelectLocationView extends GetView<SelectLocationController> {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgGradient3,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: controller.title,
        showBackButton: true,
        backgroundColor: AppColor.bgGradient3,
      ),
      body: Obx(() {
        if (!controller.mapReady.value) return const GlobalLoading();
        return Stack(
          children: [
            SizedBox.expand(
              child: Obx(
                () => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.initialTarget,
                    zoom: controller.initialZoom,
                  ),
                  onMapCreated: controller.onMapCreated,
                  onCameraMove: controller.onCameraMove,
                  onCameraIdle: controller.onCameraIdle,
                  onTap: (_) => controller.searchFocus.unfocus(),
                  myLocationEnabled: controller.myLocationEnabled.value,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  buildingsEnabled: false,
                  indoorViewEnabled: false,
                  tiltGesturesEnabled: false,
                ),
              ),
            ),
            const IgnorePointer(child: Center(child: _CenterPin())),
            Positioned(
              right: 16.w,
              bottom: 200.h,
              child: _CircleButton(
                icon: Icons.my_location_rounded,
                onTap: controller.goToMyLocation,
              ),
            ),
            Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: const _SearchBox(),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ConfirmCard(),
            ),
          ],
        );
      }),
    );
  }
}

/// Its tip sits exactly on the map center.
class _CenterPin extends GetView<SelectLocationController> {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    final size = 46.r;
    return Padding(
      padding: EdgeInsets.only(bottom: size),
      child: Obx(
        () => AnimatedSlide(
          duration: const Duration(milliseconds: 150),
          offset: controller.isMoving.value
              ? const Offset(0, -0.15)
              : Offset.zero,
          child: Icon(
            Icons.location_on_rounded,
            size: size,
            color: AppColor.error,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends GetView<SelectLocationController> {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                focusNode: controller.searchFocus,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                style: context.bodyMedium,
                cursorColor: AppColor.primary,
                decoration: buildAppInputDecoration(
                  context: context,
                  hintText: 'Search a place or address',
                  fillColor: AppColor.white,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                  suffixIcon: controller.searchText.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: controller.clearSearch,
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColor.hintText,
                            size: 20.sp,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Obx(() {
            final results = controller.results;
            final searching = controller.isSearching.value;
            final noMatch = controller.noResults.value;
            if (!searching && results.isEmpty && !noMatch) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: EdgeInsets.only(top: 8.h),
              constraints: searching || noMatch
                  ? null
                  : BoxConstraints(maxHeight: 280.h),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
                clipBehavior: Clip.antiAlias,
                child: searching
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            GlobalLoading(size: 20.sp),
                            10.width,
                            AppText(
                              'Searching…',
                              style: context.bodyMedium.copyWith(
                                color: AppColor.hintText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : noMatch
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        child: AppText(
                          'No places found. Try a different name.',
                          style: context.bodySmall.copyWith(
                            color: AppColor.hintText,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: Colors.grey.shade100,
                        ),
                        itemBuilder: (_, i) => InkWell(
                          onTap: () => controller.selectResult(results[i]),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  color: AppColor.primary,
                                  size: 20.sp,
                                ),
                                10.width,
                                Expanded(
                                  child: AppText(
                                    results[i].label,
                                    style: context.bodyMedium.copyWith(
                                      color: const Color(0xFF2D2D2D),
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ConfirmCard extends GetView<SelectLocationController> {
  const _ConfirmCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final busy = controller.isMoving.value || controller.isResolving.value;
          final point = controller.target.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Selected location',
                style: context.labelSmall.copyWith(color: AppColor.hintText),
              ),
              8.height,
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColor.primary,
                    size: 22.sp,
                  ),
                  10.width,
                  Expanded(
                    child: AppText(
                      busy
                          ? 'Finding address…'
                          : controller.address.value ??
                                '${point.latitude.toStringAsFixed(5)}, '
                                    '${point.longitude.toStringAsFixed(5)}',
                      style: context.titleSmall.copyWith(
                        color: const Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              16.height,
              GlobalButton(
                text: 'Confirm Location',
                isDisabled: busy,
                onTap: controller.confirm,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Icon(icon, size: 20.sp, color: AppColor.primary),
        ),
      ),
    );
  }
}
