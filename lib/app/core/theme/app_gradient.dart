// app_gradient.dart
import 'package:flutter/material.dart';
import 'app_color.dart';

class AppGradient {
  AppGradient._();

  static const LinearGradient appBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColor.bgGradient1, // peach top
      AppColor.bgGradient2, // near-white middle
      AppColor.bgGradient3, // cyan bottom
    ],
    stops: [0.0, 0.5, 1.0], // tweak to match Figma's exact stop %
  );
}