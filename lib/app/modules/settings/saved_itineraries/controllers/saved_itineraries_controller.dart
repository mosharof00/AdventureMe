import 'package:get/get.dart';

enum SavedSort { all, oldest, newest }

class SavedItineraryItem {
  const SavedItineraryItem({
    required this.id,
    required this.title,
    required this.starting,
    required this.destined,
    required this.dateRange,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String starting;
  final String destined;
  final String dateRange;
  final String imageUrl;
  final DateTime createdAt;
}

class SavedItinerariesController extends GetxController {
  final selectedSort = SavedSort.all.obs;
  final bookmarkedIds = <String>{}.obs;

  final items = <SavedItineraryItem>[
    SavedItineraryItem(
      id: '1',
      title: 'Japan Adventure',
      starting: 'Starting: Florida',
      destined: 'Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026 | 6 Days',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
      createdAt: DateTime(2026, 3, 10),
    ),
    SavedItineraryItem(
      id: '2',
      title: 'Japan Adventure',
      starting: 'Starting: Florida',
      destined: 'Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026 | 6 Days',
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
      createdAt: DateTime(2026, 2, 1),
    ),
    SavedItineraryItem(
      id: '3',
      title: 'Japan Adventure',
      starting: 'Starting: Florida',
      destined: 'Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026 | 6 Days',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      createdAt: DateTime(2026, 4, 5),
    ),
    SavedItineraryItem(
      id: '4',
      title: 'Japan Adventure',
      starting: 'Starting: Florida',
      destined: 'Destined: Brazil',
      dateRange: 'Mar 10 to Mar 17, 2026 | 6 Days',
      imageUrl:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400',
      createdAt: DateTime(2026, 1, 15),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    bookmarkedIds.addAll(items.map((e) => e.id));
  }

  List<SavedItineraryItem> get filteredItems {
    final list = [...items];
    switch (selectedSort.value) {
      case SavedSort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SavedSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SavedSort.all:
        break;
    }
    return list;
  }

  void changeSort(SavedSort sort) => selectedSort.value = sort;

  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  void toggleBookmark(String id) {
    if (bookmarkedIds.contains(id)) {
      bookmarkedIds.remove(id);
    } else {
      bookmarkedIds.add(id);
    }
  }

  void onShare(SavedItineraryItem item) {}

  void onFilterTap() {}
}
