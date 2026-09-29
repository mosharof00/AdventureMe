import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

import '../controllers/view_itinerary_map_controller.dart';

class ViewItineraryMapView extends GetView<ViewItineraryMapController> {
  const ViewItineraryMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgGradient3,
      appBar: const CustomAppBar(
        title: 'View Map',
        showBackButton: true,
        backgroundColor: AppColor.bgGradient3,
      ),
      // Map lives in a bounded body (not a full-bleed Stack background) so the
      // iOS platform view is created against a correct frame — otherwise it
      // renders black below the fold.
      body: Obx(
        () => controller.mapReady.value
            ? Stack(
                children: [
                  SizedBox.expand(
                    child: GoogleMap(
                      initialCameraPosition: controller.initialCamera,
                      markers: controller.markers.toSet(),
                      polylines: controller.polylines.toSet(),
                      onMapCreated: controller.onMapCreated,
                      myLocationEnabled: controller.myLocationEnabled,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    bottom: 24.h,
                    child: _CircleButton(
                      icon: Icons.my_location_rounded,
                      onTap: controller.goToMyLocation,
                    ),
                  ),
                ],
              )
            : const GlobalLoading(),
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
