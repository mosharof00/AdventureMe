import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/core/extensions/text_style_extension.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';

import '../controllers/itinerary_controller.dart';

/// Search field + status tabs; pinned at the top of the Itinerary scroll.
class ItinerarySearchAndTabs extends StatelessWidget {
  const ItinerarySearchAndTabs({super.key});

  static double get searchHeight => 34.h;
  static double get tabsHeight => 32.h;
  static double get spacing => 12.h;

  static double get contentHeight =>
      searchHeight + spacing + tabsHeight + spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(height: searchHeight, child: const _SearchField()),
        ),
        SizedBox(height: spacing),
        SizedBox(height: tabsHeight, child: const ItineraryTabs()),
        SizedBox(height: spacing),
      ],
    );
  }
}

class _SearchField extends GetView<ItineraryController> {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.r),
      borderSide: BorderSide(color: AppColor.hintText.withValues(alpha: 0.15)),
    );

    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: context.bodyMedium.copyWith(color: const Color(0xFF2D2D2D)),
      cursorColor: AppColor.primary,
      decoration: InputDecoration(
        hintText: 'Search Itinerary',
        hintStyle: context.bodyMedium.copyWith(color: AppColor.hintText),
        filled: true,
        fillColor: AppColor.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        prefixIcon: Icon(Icons.search, size: 22.sp, color: AppColor.hintText),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.searchController,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: controller.clearSearch,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: AppColor.hintText,
                  ),
                ),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColor.primary),
        ),
      ),
    );
  }
}

class ItineraryTabs extends GetView<ItineraryController> {
  const ItineraryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: ItineraryTab.values.length,
      separatorBuilder: (_, __) => 8.horizontalSpace,
      itemBuilder: (_, index) {
        final tab = ItineraryTab.values[index];
        return Obx(
          () => _TabChip(
            label: tab.label,
            isActive: controller.selectedTab.value == tab,
            onTap: () => controller.changeTab(tab),
          ),
        );
      },
    );
  }
}

class _TabChip extends StatefulWidget {
  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  @override
  void didUpdateWidget(covariant _TabChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        constraints: BoxConstraints(minWidth: 72.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isActive
                ? AppColor.primary
                : AppColor.hintText.withValues(alpha: 0.2),
          ),
        ),
        child: AppText(
          widget.label,
          style: context.bodySmall.copyWith(
            color: isActive ? AppColor.white : AppColor.hintText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
