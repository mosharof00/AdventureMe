import 'package:adventureme/app/core/constants/enums.dart';

class TripPhoto {
  final String? id;
  final String? category;
  final String? caption;
  final int? displayOrder;
  final bool isDraft;
  final String? url;
  final String? displayUrl;
  final String? thumbnailUrl;

  TripPhoto({
    this.id,
    this.category,
    this.caption,
    this.displayOrder,
    this.isDraft = false,
    this.url,
    this.displayUrl,
    this.thumbnailUrl,
  });

  /// Smallest available image, for grids.
  String get previewUrl => thumbnailUrl ?? displayUrl ?? url ?? '';

  factory TripPhoto.fromJson(Map<String, dynamic> json) => TripPhoto(
        id: json['id']?.toString(),
        category: json['category'],
        caption: json['caption'],
        displayOrder: (json['display_order'] as num?)?.toInt(),
        isDraft: json['is_draft'] == true,
        url: json['url'],
        displayUrl: json['display_url'],
        thumbnailUrl: json['thumbnail_url'],
      );
}

/// `GET /trips/{id}/days/{day}/photos`
class DayPhotosResponse {
  final bool? success;
  final String? message;
  final int? dayNumber;
  final bool isFinalized;
  final DateTime? finalizedAt;
  final Map<PhotoCategory, List<TripPhoto>> categories;

  DayPhotosResponse({
    this.success,
    this.message,
    this.dayNumber,
    this.isFinalized = false,
    this.finalizedAt,
    this.categories = const {},
  });

  factory DayPhotosResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawCategories = data['categories'] is Map
        ? data['categories'] as Map
        : const {};

    return DayPhotosResponse(
      success: json['success'],
      message: json['message'],
      dayNumber: (data['day_number'] as num?)?.toInt(),
      isFinalized: data['is_finalized'] == true,
      finalizedAt: DateTime.tryParse(data['finalized_at']?.toString() ?? ''),
      categories: {
        for (final category in PhotoCategory.values)
          category: _photos(rawCategories[category.apiValue]),
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

  factory PhotosActionResponse.fromJson(Map<String, dynamic> json) =>
      PhotosActionResponse(
        success: json['success'],
        message: json['message'],
        photos: _photos(json['data']),
      );
}

List<TripPhoto> _photos(dynamic value) => (value is List ? value : const [])
    .whereType<Map<String, dynamic>>()
    .map(TripPhoto.fromJson)
    .toList();
