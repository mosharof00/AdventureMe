import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/routes/app_pages.dart';

enum ArchiveSort { all, oldest, newest }

class ArchiveStory {
  const ArchiveStory({
    required this.id,
    required this.title,
    required this.location,
    required this.dateRange,
    required this.views,
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatar,
  });

  final String id;
  final String title;
  final String location;
  final String dateRange;
  final String views;
  final String imageUrl;
  final String authorName;
  final String authorAvatar;
}

class ArchiveController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final selectedSort = ArchiveSort.all.obs;
  final bookmarkedIds = <String>{'story_2', 'story_3'}.obs;

  void changeSort(ArchiveSort sort) => selectedSort.value = sort;

  void onSearchChanged(String value) => searchQuery.value = value;

  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  void toggleBookmark(String id) {
    if (bookmarkedIds.contains(id)) {
      bookmarkedIds.remove(id);
    } else {
      bookmarkedIds.add(id);
    }
  }

  void onShare(ArchiveStory story) {}
  void onStoryTap(ArchiveStory story) =>
      Get.toNamed(Routes.ARCHIVE_DETAILS, arguments: story);
  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  final stories = const <ArchiveStory>[
    ArchiveStory(
      id: 'story_1',
      title: 'Florida Beach, A Heaven with your Favorite!',
      location: 'Miami, Florida',
      dateRange: 'Mar 10 to Mar 17, 2026',
      views: '34k',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      authorName: 'Jack Kargille',
      authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    ArchiveStory(
      id: 'story_2',
      title: 'Seminyak Bali, The Best Trip with Friends!',
      location: 'Seminyak, Bali',
      dateRange: 'Mar 10 to Mar 17, 2026',
      views: '23k',
      imageUrl:
          'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=800',
      authorName: 'Jack Kargille',
      authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    ArchiveStory(
      id: 'story_3',
      title: '101 Places in Japan to Feel Emotions!',
      location: 'Tokyo, Japan',
      dateRange: 'Mar 10 to Mar 17, 2026',
      views: '18k',
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      authorName: 'Jack Kargille',
      authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
  ];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
