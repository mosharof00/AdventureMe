import 'package:flutter/cupertino.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class GlobalLoading extends StatelessWidget {
  const GlobalLoading({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
          color: color ?? AppColor.primary, size: size ?? 35.sp),
    );
  }
}
