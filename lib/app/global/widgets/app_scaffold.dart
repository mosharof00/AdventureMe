import 'package:flutter/material.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/core/theme/app_gradient.dart';
import 'package:adventureme/app/global/widgets/custom_appbar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.appbarTitle,
    this.backOnTap,
    this.showBackButton = true,
    this.actions,
    this.gradient,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = true,
  });

  final Widget body;

  /// Pass a fully custom app bar to override the default.
  final PreferredSizeWidget? appBar;

  /// Used by the built-in [CustomAppBar] when [appBar] is null.
  final String? appbarTitle;

  final VoidCallback? backOnTap;
  final bool showBackButton;
  final List<AppBarAction>? actions;
  final Gradient? gradient;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAppBar = appBar != null || appbarTitle != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: hasAppBar && extendBodyBehindAppBar,
      appBar:
          appBar ??
          (appbarTitle != null
              ? CustomAppBar(
                  title: appbarTitle,
                  showBackButton: showBackButton,
                  onBackTap: backOnTap,
                  actions: actions,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              : null),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? null : (gradient ?? AppGradient.appBgGradient),
          color: isDark ? AppColor.darkBackground : null,
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}
