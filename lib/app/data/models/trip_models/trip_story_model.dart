class TripStoryResponse {
  final bool? success;
  final String? message;
  final TripStoryData? data;

  TripStoryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory TripStoryResponse.fromJson(Map<String, dynamic> json) =>
      TripStoryResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] is Map<String, dynamic>
            ? TripStoryData.fromJson(json['data'])
            : null,
      );
}

class TripStoryData {
  final String? itineraryId;
  final String? tripId;
  final String? title;
  final String? description;
  final String? coverUrl;
  final List<String> coverPhotos;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? generatedAt;
  final DateTime? storyCreatedAt;
  final DateTime? storyPublishedAt;
  final int viewCount;
  final String? shareToken;
  final String? shareUrl;
  final String? qrCodeUrl;
  final String visibility;
  final bool isPrivate;
  final bool canShare;
  final StoryAuthor? author;
  final StorySummary? summary;
  final List<StoryDay> days;
  final int totalMoments;
  final int totalPhotos;

  TripStoryData({
    this.itineraryId,
    this.tripId,
    this.title,
    this.description,
    this.coverUrl,
    this.coverPhotos = const [],
    this.isPublished = false,
    this.publishedAt,
    this.generatedAt,
    this.storyCreatedAt,
    this.storyPublishedAt,
    this.viewCount = 0,
    this.shareToken,
    this.shareUrl,
    this.qrCodeUrl,
    this.visibility = 'PRIVATE',
    this.isPrivate = true,
    this.canShare = false,
    this.author,
    this.summary,
    this.days = const [],
    this.totalMoments = 0,
    this.totalPhotos = 0,
  });

  /// Up to 3 images for the hero gallery UI; falls back to [coverUrl] if empty.
  List<String> get effectiveCoverPhotos {
    final list = coverPhotos.where((e) => e.trim().isNotEmpty).toList();
    if (list.isNotEmpty) return list.take(3).toList();
    if (coverUrl != null && coverUrl!.trim().isNotEmpty) return [coverUrl!];
    return const [];
  }

  factory TripStoryData.fromJson(Map<String, dynamic> json) => TripStoryData(
        itineraryId: json['itinerary_id']?.toString(),
        tripId: json['trip_id']?.toString(),
        title: json['title']?.toString(),
        description: json['description']?.toString(),
        coverUrl: json['cover_url']?.toString(),
        coverPhotos: (json['cover_photos'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        isPublished: json['is_published'] == true,
        publishedAt: _date(json['published_at']),
        generatedAt: _date(json['generated_at']),
        storyCreatedAt: _date(json['story_created_at']),
        storyPublishedAt: _date(json['story_published_at']),
        viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
        shareToken: json['share_token']?.toString(),
        shareUrl: json['share_url']?.toString(),
        qrCodeUrl: json['qr_code_url']?.toString(),
        visibility: json['visibility']?.toString() ?? 'PRIVATE',
        isPrivate: json['is_private'] == true,
        canShare: json['can_share'] == true,
        author: json['author'] is Map<String, dynamic>
            ? StoryAuthor.fromJson(json['author'])
            : null,
        summary: json['summary'] is Map<String, dynamic>
            ? StorySummary.fromJson(json['summary'])
            : null,
        days: (json['days'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StoryDay.fromJson)
            .toList(),
        totalMoments: (json['total_moments'] as num?)?.toInt() ?? 0,
        totalPhotos: (json['total_photos'] as num?)?.toInt() ?? 0,
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class StoryAuthor {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final bool isVerified;

  StoryAuthor({
    this.id,
    this.name,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory StoryAuthor.fromJson(Map<String, dynamic> json) => StoryAuthor(
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        avatarUrl: json['avatar_url']?.toString(),
        isVerified: json['is_verified'] == true,
      );
}

class StorySummary {
  final String? locationsExplored;
  final int totalLocationsCount;
  final List<String> locationsList;
  final String? milesTraveled;
  final int milesCount;
  final String? mostPhotographedLocation;
  final String? totalDuration;
  final int totalPhotos;
  final int totalDays;
  final List<StorySummaryItem> items;

  StorySummary({
    this.locationsExplored,
    this.totalLocationsCount = 0,
    this.locationsList = const [],
    this.milesTraveled,
    this.milesCount = 0,
    this.mostPhotographedLocation,
    this.totalDuration,
    this.totalPhotos = 0,
    this.totalDays = 0,
    this.items = const [],
  });

  factory StorySummary.fromJson(Map<String, dynamic> json) => StorySummary(
        locationsExplored: json['locations_explored']?.toString(),
        totalLocationsCount:
            (json['total_locations_count'] as num?)?.toInt() ?? 0,
        locationsList: (json['locations_list'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        milesTraveled: json['miles_traveled']?.toString(),
        milesCount: (json['miles_count'] as num?)?.toInt() ?? 0,
        mostPhotographedLocation:
            json['most_photographed_location']?.toString(),
        totalDuration: json['total_duration']?.toString(),
        totalPhotos: (json['total_photos'] as num?)?.toInt() ?? 0,
        totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
        items: (json['items'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StorySummaryItem.fromJson)
            .toList(),
      );
}

class StorySummaryItem {
  final String label;
  final String value;

  StorySummaryItem({
    required this.label,
    required this.value,
  });

  factory StorySummaryItem.fromJson(Map<String, dynamic> json) =>
      StorySummaryItem(
        label: json['label']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
      );
}

class StoryDay {
  final int dayNumber;
  final String? date;
  final String? formattedDate;
  final String? timeRange;
  final String? dateTimeLabel;
  final String? title;
  final String? narrative;
  final String? bodyText;
  final int totalMoments;
  final int totalPhotos;
  final List<StoryMoment> moments;

  StoryDay({
    this.dayNumber = 0,
    this.date,
    this.formattedDate,
    this.timeRange,
    this.dateTimeLabel,
    this.title,
    this.narrative,
    this.bodyText,
    this.totalMoments = 0,
    this.totalPhotos = 0,
    this.moments = const [],
  });

  bool get hasContent =>
      (title != null && title!.trim().isNotEmpty && title != 'Day $dayNumber') ||
      (narrative != null && narrative!.trim().isNotEmpty) ||
      (bodyText != null && bodyText!.trim().isNotEmpty) ||
      moments.isNotEmpty;

  factory StoryDay.fromJson(Map<String, dynamic> json) => StoryDay(
        dayNumber: (json['day_number'] as num?)?.toInt() ?? 0,
        date: json['date']?.toString(),
        formattedDate: json['formatted_date']?.toString(),
        timeRange: json['time_range']?.toString(),
        dateTimeLabel: json['date_time_label']?.toString(),
        title: json['title']?.toString(),
        narrative: json['narrative']?.toString(),
        bodyText: json['body_text']?.toString(),
        totalMoments: (json['total_moments'] as num?)?.toInt() ?? 0,
        totalPhotos: (json['total_photos'] as num?)?.toInt() ?? 0,
        moments: (json['moments'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StoryMoment.fromJson)
            .toList(),
      );
}

class StoryMoment {
  final String? id;
  final String? category;
  final String? categoryLabel;
  final String? title;
  final String? quote;
  final String? bodyText;
  final String? titleSource;
  final String? quoteSource;
  final String? bodyTextSource;
  final DateTime? userEditedAt;
  final int displayOrder;
  final int photoCount;
  final List<StoryPhoto> photos;
  final List<StoryPhoto> attachments;

  StoryMoment({
    this.id,
    this.category,
    this.categoryLabel,
    this.title,
    this.quote,
    this.bodyText,
    this.titleSource,
    this.quoteSource,
    this.bodyTextSource,
    this.userEditedAt,
    this.displayOrder = 0,
    this.photoCount = 0,
    this.photos = const [],
    this.attachments = const [],
  });

  List<String> get allPhotoUrls {
    final urls = <String>[];
    for (final p in photos) {
      final u = p.url ?? p.thumbnailUrl;
      if (u != null && u.trim().isNotEmpty && !urls.contains(u)) urls.add(u);
    }
    for (final p in attachments) {
      final u = p.url ?? p.thumbnailUrl;
      if (u != null && u.trim().isNotEmpty && !urls.contains(u)) urls.add(u);
    }
    return urls;
  }

  factory StoryMoment.fromJson(Map<String, dynamic> json) => StoryMoment(
        id: json['id']?.toString(),
        category: json['category']?.toString(),
        categoryLabel: json['category_label']?.toString(),
        title: json['title']?.toString(),
        quote: json['quote']?.toString(),
        bodyText: json['body_text']?.toString(),
        titleSource: json['title_source']?.toString(),
        quoteSource: json['quote_source']?.toString(),
        bodyTextSource: json['body_text_source']?.toString(),
        userEditedAt: json['user_edited_at'] == null
            ? null
            : DateTime.tryParse(json['user_edited_at'].toString()),
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
        photoCount: (json['photo_count'] as num?)?.toInt() ?? 0,
        photos: (json['photos'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StoryPhoto.fromJson)
            .toList(),
        attachments: (json['attachments'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StoryPhoto.fromJson)
            .toList(),
      );
}

class StoryPhoto {
  final String? id;
  final String? url;
  final String? thumbnailUrl;
  final String? category;
  final int displayOrder;

  StoryPhoto({
    this.id,
    this.url,
    this.thumbnailUrl,
    this.category,
    this.displayOrder = 0,
  });

  factory StoryPhoto.fromJson(Map<String, dynamic> json) => StoryPhoto(
        id: json['id']?.toString(),
        url: json['url']?.toString(),
        thumbnailUrl: json['thumbnail_url']?.toString(),
        category: json['category']?.toString(),
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      );
}
