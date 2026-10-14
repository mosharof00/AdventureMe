import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_text.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';

/// Full-screen photo viewer for one or many photos (network URL or local file).
/// Pinch to zoom, pan, and swipe between photos.
/// Use from any screen: `Get.find<PhotoViewerService>().open(...)`.
class PhotoViewerService extends GetxService {
  /// Opens a gallery; starts at [index]. Empty / blank entries are skipped.
  Future<void> open(List<String> sources, {int index = 0}) async {
    final photos = [
      for (final s in sources)
        if (s.trim().isNotEmpty) s.trim(),
    ];
    if (photos.isEmpty) return;
    final start = index.clamp(0, photos.length - 1);
    await Get.to(
      () => _PhotoViewerPage(photos: photos, initialIndex: start),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      opaque: true,
    );
  }

  Future<void> openOne(String source) => open([source]);
}

bool _isNetwork(String source) =>
    source.startsWith('http://') || source.startsWith('https://');

ImageProvider _provider(String source) {
  if (_isNetwork(source)) {
    return CachedNetworkImageProvider(
      source,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      },
    );
  }
  return FileImage(File(source));
}

class _PhotoViewerPage extends StatefulWidget {
  const _PhotoViewerPage({required this.photos, required this.initialIndex});

  final List<String> photos;
  final int initialIndex;

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late final _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: total,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (i) => setState(() => _index = i),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (_, i) => PhotoViewGalleryPageOptions(
              imageProvider: _provider(widget.photos[i]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColor.hintText,
                  size: 48.sp,
                ),
              ),
            ),
            loadingBuilder: (_, _) =>
                const Center(child: GlobalLoading(color: AppColor.white)),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _close,
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColor.white,
                      size: 26.sp,
                    ),
                  ),
                  const Spacer(),
                  if (total > 1)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: AppText(
                        '${_index + 1} / $total',
                        style: TextStyle(
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
