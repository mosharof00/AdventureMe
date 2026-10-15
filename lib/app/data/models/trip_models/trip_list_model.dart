import 'package:adventureme/app/core/constants/enums.dart';

class TripListResponse {
  final bool? success;
  final String? message;
  final List<TripListItem> data;
  final CursorMeta? meta;

  TripListResponse({
    this.success,
    this.message,
    this.data = const [],
    this.meta,
  });

  factory TripListResponse.fromJson(Map<String, dynamic> json) =>
      TripListResponse(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(TripListItem.fromJson)
            .toList(),
        meta: json['meta'] is Map<String, dynamic>
            ? CursorMeta.fromJson(json['meta'])
            : null,
      );
}

/// Cursor-pagination info returned with list endpoints.
class CursorMeta {
  final int? limit;
  final int? count;
  final bool hasNextPage;
  final String? nextCursor;

  CursorMeta({this.limit, this.count, this.hasNextPage = false, this.nextCursor});

  factory CursorMeta.fromJson(Map<String, dynamic> json) => CursorMeta(
        limit: (json['limit'] as num?)?.toInt(),
        count: (json['count'] as num?)?.toInt(),
        hasNextPage: json['hasNextPage'] == true,
        nextCursor: json['nextCursor']?.toString(),
      );
}

class TripListItem {
  final String? id;
  final String? title;
  final String? startingPlace;
  final String? startingCountry;
  final String? destinedPlace;
  final String? destinedCountry;
  final DateTime? startingDate;
  final DateTime? endingDate;
  final TripStatus status;
  final bool isPublic;
  final int? trackingDurationMinutes;
  final String? trackingDisplay;
  final String? coverUrl;

  TripListItem({
    this.id,
    this.title,
    this.startingPlace,
    this.startingCountry,
    this.destinedPlace,
    this.destinedCountry,
    this.startingDate,
    this.endingDate,
    this.status = TripStatus.pending,
    this.isPublic = false,
    this.trackingDurationMinutes,
    this.trackingDisplay,
    this.coverUrl,
  });

  bool get isCompleted => status == TripStatus.completed;

  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;

  TripListItem copyWith({
    String? coverUrl,
    String? startingCountry,
    String? destinedCountry,
  }) => TripListItem(
        id: id,
        title: title,
        startingPlace: startingPlace,
        startingCountry: startingCountry ?? this.startingCountry,
        destinedPlace: destinedPlace,
        destinedCountry: destinedCountry ?? this.destinedCountry,
        startingDate: startingDate,
        endingDate: endingDate,
        status: status,
        isPublic: isPublic,
        trackingDurationMinutes: trackingDurationMinutes,
        trackingDisplay: trackingDisplay,
        coverUrl: coverUrl ?? this.coverUrl,
      );

  factory TripListItem.fromJson(Map<String, dynamic> json) => TripListItem(
        id: json['id']?.toString(),
        title: json['title'],
        startingPlace: json['starting_place'],
        startingCountry: json['starting_country'],
        destinedPlace: json['destined_place'],
        destinedCountry: json['destined_country'],
        startingDate: DateTime.tryParse(json['starting_date']?.toString() ?? ''),
        endingDate: DateTime.tryParse(json['ending_date']?.toString() ?? ''),
        status: TripStatus.fromApi(json['status']?.toString()),
        isPublic: json['is_public'] == true,
        trackingDurationMinutes:
            (json['tracking_duration_minutes'] as num?)?.toInt(),
        trackingDisplay: json['tracking_display'],
        coverUrl: json['cover_url'],
      );
}
