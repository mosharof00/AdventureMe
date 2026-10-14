import 'package:adventureme/app/core/constants/enums.dart';

class TripPhoto {
  final String? id;
  final String? category;
  final String? caption;
  final String? title;
  final String? quote;
  final double? lat;
  final double? lng;
  final int? displayOrder;
  final bool isDraft;
  final String? url;
  final String? displayUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  TripPhoto({
    this.id,
    this.category,
    this.caption,
    this.title,
    this.quote,
    this.lat,
    this.lng,
    this.displayOrder,
    this.isDraft = false,
    this.url,
    this.displayUrl,
    this.thumbnailUrl,
    this.createdAt,
  });

  /// Smallest available image, for grids.
  String get previewUrl => thumbnailUrl ?? displayUrl ?? url ?? '';

  /// Best available image for the full-screen viewer.
  String get viewUrl => displayUrl ?? url ?? thumbnailUrl ?? '';

  factory TripPhoto.fromJson(Map<String, dynamic> json) => TripPhoto(
        id: json['id']?.toString(),
        category: json['category'],
        caption: json['caption'],
        title: json['title'],
        quote: json['quote'],
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        displayOrder: (json['display_order'] as num?)?.toInt(),
        isDraft: json['is_draft'] == true,
        url: json['url'],
        displayUrl: json['display_url'],
        thumbnailUrl: json['thumbnail_url'],
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

/// One upload of a day's photos with its title, quote and place
/// (a Photo Chapter block).
class TripMoment {
  final String? id;
  final String? title;
  final String? quote;
  final double? lat;
  final double? lng;
  final String? address;
  final bool isDraft;
  final DateTime? createdAt;
  final List<TripPhoto> photos;

  TripMoment({
    this.id,
    this.title,
    this.quote,
    this.lat,
    this.lng,
    this.address,
    this.isDraft = false,
    this.createdAt,
    this.photos = const [],
  });

  factory TripMoment.fromJson(Map<String, dynamic> json) => TripMoment(
        id: json['id']?.toString(),
        title: json['title'],
        quote: json['quote'],
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        address: json['address'],
        isDraft: json['is_draft'] == true,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        photos: _photos(json['photos']),
      );
}

/// `GET /trips/{id}/days/{day}/photos`
class DayPhotosResponse {
  final bool? success;
  final String? message;
  final int? dayNumber;
  final bool isFinalized;
  final DateTime? finalizedAt;
  final int totalPhotos;

  /// Oldest first.
  final List<TripMoment> moments;
  final Map<PhotoCategory, List<TripPhoto>> categories;

  DayPhotosResponse({
    this.success,
    this.message,
    this.dayNumber,
    this.isFinalized = false,
    this.finalizedAt,
    this.totalPhotos = 0,
    this.moments = const [],
    this.categories = const {},
  });

  factory DayPhotosResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final moments = (data['moments'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TripMoment.fromJson)
        .toList()
      ..sort((a, b) {
        final at = a.createdAt, bt = b.createdAt;
        if (at == null || bt == null) return 0;
        return at.compareTo(bt);
      });

    // Older payloads group by `categories`; newer ones only by `moments`.
    final rawCategories = data['categories'] is Map
        ? data['categories'] as Map
        : null;
    final allPhotos = [for (final m in moments) ...m.photos];

    return DayPhotosResponse(
      success: json['success'],
      message: json['message'],
      dayNumber: (data['day_number'] as num?)?.toInt(),
      isFinalized: data['is_finalized'] == true,
      finalizedAt: DateTime.tryParse(data['finalized_at']?.toString() ?? ''),
      totalPhotos: (data['total_photos'] as num?)?.toInt() ?? allPhotos.length,
      moments: moments,
      categories: {
        for (final category in PhotoCategory.values)
          category: rawCategories != null
              ? _photos(rawCategories[category.apiValue])
              : (allPhotos
                    .where((p) => p.category == category.apiValue)
                    .toList()
                  ..sort(
                    (a, b) => (a.displayOrder ?? 0).compareTo(
                      b.displayOrder ?? 0,
                    ),
                  )),
      },
    );
  }
}

/// `POST /trips/{id}/days/{day}/photos` (and other photo actions).
class PhotosActionResponse {
  final bool? success;
  final String? message;
  final List<TripPhoto> photos;

  PhotosActionResponse({this.success, this.message, this.photos = const []});

  /// `data` is a photo list, or (upload) a moment holding `photos`.
  factory PhotosActionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PhotosActionResponse(
      success: json['success'],
      message: json['message'],
      photos: _photos(data is Map ? data['photos'] : data),
    );
  }
}

List<TripPhoto> _photos(dynamic value) => (value is List ? value : const [])
    .whereType<Map<String, dynamic>>()
    .map(TripPhoto.fromJson)
    .toList();
