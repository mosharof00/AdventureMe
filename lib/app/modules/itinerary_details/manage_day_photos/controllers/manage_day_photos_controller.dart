import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adventureme/app/core/theme/app_color.dart';
import 'package:adventureme/app/global/widgets/app_bottom_sheet.dart';
import 'package:adventureme/app/global/widgets/global_button.dart';

/// A single image inside a category — either a previously uploaded network
/// image or a freshly picked local file.
class PhotoItem {
  const PhotoItem.network(this.url) : file = null;
  const PhotoItem.local(this.file) : url = null;

  final String? url;
  final XFile? file;

  bool get isLocal => file != null;
  String get id => isLocal ? file!.path : url!;
}

class PhotoCategory {
  const PhotoCategory({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class ManageDayPhotosController extends GetxController {
  final _picker = ImagePicker();

  late final int dayNumber;
  late final String dayDate;

  final categories = const <PhotoCategory>[
    PhotoCategory(label: 'Favorite Image', icon: Icons.star_border_rounded),
    PhotoCategory(label: 'Best Moment', icon: Icons.image_outlined),
    PhotoCategory(label: 'Hidden Gem', icon: Icons.diamond_outlined),
    PhotoCategory(label: 'Sudden Adventure', icon: Icons.explore_outlined),
  ];

  final selected = 0.obs;

  /// Working image list per category index.
  final Map<int, RxList<PhotoItem>> _images = {};

  /// Saved baseline (list of ids) per category index — used for dirty checks.
  final Map<int, List<String>> _baseline = {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      dayNumber = (arg['day'] as int?) ?? 1;
      dayDate = (arg['date'] as String?) ?? '';
    } else if (arg is int) {
      dayNumber = arg;
      dayDate = '';
    } else {
      dayNumber = 1;
      dayDate = '';
    }

    for (var i = 0; i < categories.length; i++) {
      final seed = _seedFor(i);
      _images[i] = seed.obs;
      _baseline[i] = seed.map((e) => e.id).toList();
    }
  }

  // ── Mock existing (already uploaded) images ──────────
  List<PhotoItem> _seedFor(int index) {
    switch (index) {
      case 0:
        return const [
          PhotoItem.network(
            'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400',
          ),
          PhotoItem.network(
            'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400',
          ),
          PhotoItem.network(
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
          ),
        ];
      case 1:
        return const [
          PhotoItem.network(
            'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=400',
          ),
          PhotoItem.network(
            'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400',
          ),
        ];
      default:
        return const [];
    }
  }

  PhotoCategory get currentCategory => categories[selected.value];
  RxList<PhotoItem> get currentImages => _images[selected.value]!;
  RxList<PhotoItem> imagesFor(int index) => _images[index]!;

  void selectCategory(int index) => selected.value = index;

  /// True when the current category differs from its last saved baseline.
  bool get isDirty {
    final current = currentImages.map((e) => e.id).toList();
    final base = _baseline[selected.value]!;
    if (current.length != base.length) return true;
    for (var i = 0; i < current.length; i++) {
      if (current[i] != base[i]) return true;
    }
    return false;
  }

  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;
      final existingPaths = currentImages
          .where((e) => e.isLocal)
          .map((e) => e.id)
          .toSet();
      final fresh = picked
          .where((f) => !existingPaths.contains(f.path))
          .map((f) => PhotoItem.local(f));
      currentImages.addAll(fresh);
    } catch (_) {
      Get.snackbar('Oops', 'Could not open the gallery. Please try again.');
    }
  }

  void removeImage(PhotoItem item) {
    currentImages.removeWhere((e) => e.id == item.id);
  }

  void saveCategory() {
    if (!isDirty) return;
    _commitBaseline();
    _showSuccessSheet();
  }

  void saveAsDraft() {
    _commitBaseline();
    Get.back();
  }

  void _commitBaseline() {
    _baseline[selected.value] = currentImages.map((e) => e.id).toList();
    currentImages.refresh();
  }

  void _showSuccessSheet() {
    AppBottomSheet.show(
      sticker: 'assets/images/excited_sticker.png',
      title: 'Yey! Upload Completed',
      description:
          'Your memory is now available on photo chapter. Click continue to view directly.',
      isDismissible: false,
      actionWidget: GlobalButton(
        text: 'Continue',
        color: AppColor.primary,
        onTap: () {
          Get.back(); // close sheet
          Get.back(); // return to itinerary details
        },
      ),
    );
  }
}
