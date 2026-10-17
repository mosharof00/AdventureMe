class FeedResponse {
  final bool? success;
  final String? message;
  final FeedData? data;

  FeedResponse({this.success, this.message, this.data});

  factory FeedResponse.fromJson(Map<String, dynamic> json) => FeedResponse(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? FeedData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class FeedData {
  final List<FeedItem> items;
  final FeedMeta? meta;

  FeedData({
    this.items = const [],
    this.meta,
  });

  factory FeedData.fromJson(Map<String, dynamic> json) => FeedData(
        items: (json['items'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(FeedItem.fromJson)
                .toList() ??
            const [],
        meta: json['meta'] is Map<String, dynamic>
            ? FeedMeta.fromJson(json['meta'] as Map<String, dynamic>)
            : null,
      );
}

class FeedMeta {
  final int limit;
  final bool hasNextPage;
  final String? nextCursor;
  final int count;

  FeedMeta({
    this.limit = 10,
    this.hasNextPage = false,
    this.nextCursor,
    this.count = 0,
  });

  factory FeedMeta.fromJson(Map<String, dynamic> json) => FeedMeta(
        limit: (json['limit'] as num?)?.toInt() ?? 10,
        hasNextPage: json['hasNextPage'] == true,
        nextCursor: json['nextCursor']?.toString(),
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

class FeedItem {
  final String id;
  final String title;
  final String? coverUrl;
  final String? startingPlace;
  final String? destinedPlace;
  final String? startingCountry;
  final String? destinedCountry;
  final String? placeDisplay;
  final String? dateRangeDisplay;
  final String? subtitle;
  final int? viewsCount;
  final String? viewsDisplay;
  final String? status;
  final bool isCompleted;
  final bool isPublic;
  final FeedAuthor? author;
  final bool isBookmark;
  final bool isSaved;
  final String? savedId;
  final bool hasStory;
  final FeedStory? story;
  final DateTime? createdAt;

  FeedItem({
    required this.id,
    this.title = '',
    this.coverUrl,
    this.startingPlace,
    this.destinedPlace,
    this.startingCountry,
    this.destinedCountry,
    this.placeDisplay,
    this.dateRangeDisplay,
    this.subtitle,
    this.viewsCount,
    this.viewsDisplay,
    this.status,
    this.isCompleted = false,
    this.isPublic = true,
    this.author,
    this.isBookmark = false,
    this.isSaved = false,
    this.savedId,
    this.hasStory = false,
    this.story,
    this.createdAt,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        coverUrl: json['coverUrl']?.toString(),
        startingPlace: json['startingPlace']?.toString(),
        destinedPlace: json['destinedPlace']?.toString(),
        startingCountry: json['startingCountry']?.toString(),
        destinedCountry: json['destinedCountry']?.toString(),
        placeDisplay: json['placeDisplay']?.toString(),
        dateRangeDisplay: json['dateRangeDisplay']?.toString(),
        subtitle: json['subtitle']?.toString(),
        viewsCount: (json['viewsCount'] as num?)?.toInt(),
        viewsDisplay: json['viewsDisplay']?.toString(),
        status: json['status']?.toString(),
        isCompleted: json['isCompleted'] == true,
        isPublic: json['isPublic'] != false,
        author: json['author'] is Map<String, dynamic>
            ? FeedAuthor.fromJson(json['author'] as Map<String, dynamic>)
            : null,
        isBookmark: json['isBookmark'] == true,
        isSaved: json['isSaved'] == true,
        savedId: json['savedId']?.toString(),
        hasStory: json['hasStory'] == true,
        story: json['story'] is Map<String, dynamic>
            ? FeedStory.fromJson(json['story'] as Map<String, dynamic>)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  FeedItem copyWith({
    bool? isBookmark,
    bool? isSaved,
    String? savedId,
  }) {
    return FeedItem(
      id: id,
      title: title,
      coverUrl: coverUrl,
      startingPlace: startingPlace,
      destinedPlace: destinedPlace,
      startingCountry: startingCountry,
      destinedCountry: destinedCountry,
      placeDisplay: placeDisplay,
      dateRangeDisplay: dateRangeDisplay,
      subtitle: subtitle,
      viewsCount: viewsCount,
      viewsDisplay: viewsDisplay,
      status: status,
      isCompleted: isCompleted,
      isPublic: isPublic,
      author: author,
      isBookmark: isBookmark ?? this.isBookmark,
      isSaved: isSaved ?? this.isSaved,
      savedId: savedId ?? this.savedId,
      hasStory: hasStory,
      story: story,
      createdAt: createdAt,
    );
  }
}

class FeedAuthor {
  final String? id;
  final String? name;
  final String? username;
  final String? avatarUrl;

  FeedAuthor({
    this.id,
    this.name,
    this.username,
    this.avatarUrl,
  });

  factory FeedAuthor.fromJson(Map<String, dynamic> json) => FeedAuthor(
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        username: json['username']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
      );
}

class FeedStory {
  final String? id;
  final String? title;
  final String? description;
  final String? readTime;
  final bool? isPublished;
  final String? shareToken;

  FeedStory({
    this.id,
    this.title,
    this.description,
    this.readTime,
    this.isPublished,
    this.shareToken,
  });

  factory FeedStory.fromJson(Map<String, dynamic> json) => FeedStory(
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        description: json['description']?.toString(),
        readTime: json['readTime']?.toString(),
        isPublished: json['isPublished'] as bool?,
        shareToken: json['shareToken']?.toString(),
      );
}
