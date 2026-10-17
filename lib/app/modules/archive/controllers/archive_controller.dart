import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/core/network/handle_exceptions.dart';
import 'package:adventureme/app/data/models/feed_models/feed_model.dart';
import 'package:adventureme/app/data/repositories/feed_repository.dart';
import 'package:adventureme/app/routes/app_pages.dart';

import '../widgets/feed_filter_bottom_sheet.dart';

class ArchiveController extends GetxController {
  final IFeedRepository _feedRepository = Get.find<IFeedRepository>();

  // ── Search ───────────────────────────────────────────
  final searchController = TextEditingController();
  final activeSearch = ''.obs;

  // ── Filter State ─────────────────────────────────────
  final selectedFilter = 'recent'.obs; // 'recent' | 'all' | 'completed'
  final selectedStatus = Rxn<String>(); // null | 'COMPLETED' | 'ACTIVE' | 'PENDING'
  final selectedHasStory = Rxn<bool>(); // null | true | false

  bool get isFilterActive =>
      selectedFilter.value != 'recent' ||
      selectedStatus.value != null ||
      selectedHasStory.value != null;

  // ── Feed List & Pagination State ─────────────────────
  final items = <FeedItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasNextPage = true.obs;
  String? nextCursor;

  final hasError = false.obs;
  final errorMessage = ''.obs;

  final scrollController = ScrollController();
  final bookmarkedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeed(refresh: true);
  }

  void loadMore() {
    if (!hasNextPage.value ||
        isLoading.value ||
        isLoadingMore.value ||
        items.isEmpty) {
      return;
    }
    fetchFeed();
  }

  // ── Search Action ────────────────────────────────────
  void onSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    final query = searchController.text.trim();
    activeSearch.value = query;
    fetchFeed(refresh: true);
  }

  // ── Filter Actions ───────────────────────────────────
  void openFilterSheet() {
    FeedFilterBottomSheet.show(Get.context!);
  }

  void applyFilters({
    required String filter,
    String? status,
    bool? hasStory,
  }) {
    selectedFilter.value = filter;
    selectedStatus.value = status;
    selectedHasStory.value = hasStory;
    fetchFeed(refresh: true);
  }

  void resetFilters() {
    selectedFilter.value = 'recent';
    selectedStatus.value = null;
    selectedHasStory.value = null;
    fetchFeed(refresh: true);
  }

  // ── Fetch Feed API ───────────────────────────────────
  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      nextCursor = null;
      hasNextPage.value = true;
    } else {
      if (!hasNextPage.value || isLoadingMore.value || isLoading.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await _feedRepository.getFeed(
        cursor: refresh ? null : nextCursor,
        limit: 10,
        filter: selectedFilter.value,
        search: activeSearch.value.isNotEmpty ? activeSearch.value : null,
        status: selectedStatus.value,
        hasStory: selectedHasStory.value,
      );

      if (response.success == true && response.data != null) {
        final newItems = response.data!.items;
        if (refresh) {
          items.assignAll(newItems);
        } else {
          items.addAll(newItems);
        }

        // Initialize bookmark state
        for (final item in newItems) {
          if (item.isBookmark || item.isSaved) {
            bookmarkedIds.add(item.id);
          }
        }

        nextCursor = response.data?.meta?.nextCursor;
        hasNextPage.value = response.data?.meta?.hasNextPage ?? false;
      } else {
        if (refresh) {
          hasError.value = true;
          errorMessage.value = response.message ?? 'Unable to retrieve feed.';
        }
      }
    } catch (e) {
      if (refresh) {
        hasError.value = true;
        errorMessage.value = 'Unable to connect. Please try again.';
      }
      handleException(e, context: 'Feed List');
    } finally {
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  // ── Item Actions ─────────────────────────────────────
  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  void toggleBookmark(FeedItem item) {
    if (bookmarkedIds.contains(item.id)) {
      bookmarkedIds.remove(item.id);
    } else {
      bookmarkedIds.add(item.id);
    }
  }

  void onShare(FeedItem story) {
    // Can trigger share or copy share token
  }

  void onStoryTap(FeedItem story) {
    Get.toNamed(Routes.ARCHIVE_DETAILS, arguments: story);
  }

  void onNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
