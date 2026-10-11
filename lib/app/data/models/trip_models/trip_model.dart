import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';

class TripResponse {
  final bool? success;
  final String? message;
  final TripData? data;

  TripResponse({this.success, this.message, this.data});

  factory TripResponse.fromJson(Map<String, dynamic> json) => TripResponse(
    success: json['success'],
    message: json['message'],
    data: json['data'] is Map<String, dynamic>
        ? TripData.fromJson(json['data'])
        : null,
  );
}

class TripThumbnailResponse {
  final bool? success;
  final String? message;
  final String? thumbnailPath;
  final String? thumbnailUrl;

  TripThumbnailResponse({
    this.success,
    this.message,
    this.thumbnailPath,
    this.thumbnailUrl,
  });

  factory TripThumbnailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TripThumbnailResponse(
      success: json['success'],
      message: json['message'],
      thumbnailPath: data['thumbnail_path'],
      thumbnailUrl: data['thumbnail_url'],
    );
  }
}

class TripData {
  final String? id;
  final String? title;
  final String? startingPlace;
  final String? destinedPlace;
  final DateTime? startingDate;
  final DateTime? endingDate;
  final int? numberOfDays;
  final bool travelTrackerEnabled;
  final bool isPublic;
  final bool canShare;
  final String? sharedLocationPrecision;

  /// PENDING, ... (lifecycle of the trip)
  final String? status;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? endedAt;
  final bool liveLocationEnabled;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final int? trackingDurationMinutes;
  final String? trackingDisplay;
  final String? intention;
  final String? intentionType;
  final List<String> intentionTags;
  final DateTime? anticipatedAt;
  final DateTime? reflectedAt;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TripInterval> tripIntervals;

  TripData({
    this.id,
    this.title,
    this.startingPlace,
    this.destinedPlace,
    this.startingDate,
    this.endingDate,
    this.numberOfDays,
    this.travelTrackerEnabled = false,
    this.isPublic = false,
    this.canShare = false,
    this.sharedLocationPrecision,
    this.status,
    this.startedAt,
    this.pausedAt,
    this.endedAt,
    this.liveLocationEnabled = false,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.trackingDurationMinutes,
    this.trackingDisplay,
    this.intention,
    this.intentionType,
    this.intentionTags = const [],
    this.anticipatedAt,
    this.reflectedAt,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.tripIntervals = const [],
  });

  TripStatus get tripStatus => TripStatus.fromApi(status);

  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  bool get hasIntention => intention != null && intention!.trim().isNotEmpty;

  bool get hasReflection => reflectedAt != null;

  factory TripData.fromJson(Map<String, dynamic> json) => TripData(
    id: json['id'],
    title: json['title'],
    startingPlace: json['starting_place'],
    destinedPlace: json['destined_place'],
    startingDate: _date(json['starting_date']),
    endingDate: _date(json['ending_date']),
    numberOfDays: (json['number_of_days'] as num?)?.toInt(),
    travelTrackerEnabled: json['travel_tracker_enabled'] == true,
    isPublic: json['is_public'] == true,
    canShare: json['can_share'] == true,
    sharedLocationPrecision: json['shared_location_precision'],
    status: json['status'],
    startedAt: _date(json['started_at']),
    pausedAt: _date(json['paused_at']),
    endedAt: _date(json['ended_at']),
    liveLocationEnabled: json['live_location_enabled'] == true,
    thumbnailPath: json['thumbnail_path'],
    thumbnailUrl: json['thumbnail_url'],
    trackingDurationMinutes: (json['tracking_duration_minutes'] as num?)
        ?.toInt(),
    trackingDisplay: json['tracking_display'],
    intention: json['intention'],
    intentionType: json['intention_type'],
    intentionTags: _strings(json['intention_tags']),
    anticipatedAt: _date(json['anticipated_at']),
    reflectedAt: _date(json['reflected_at']),
    userId: json['user_id'],
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
    tripIntervals: (json['tripIntervals'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TripInterval.fromJson)
        .toList(),
  );

  TripData copyWith({
    String? intention,
    String? intentionType,
    List<String>? intentionTags,
    DateTime? reflectedAt,
    List<TripInterval>? tripIntervals,
  }) => TripData(
    id: id,
    title: title,
    startingPlace: startingPlace,
    destinedPlace: destinedPlace,
    startingDate: startingDate,
    endingDate: endingDate,
    numberOfDays: numberOfDays,
    travelTrackerEnabled: travelTrackerEnabled,
    isPublic: isPublic,
    canShare: canShare,
    sharedLocationPrecision: sharedLocationPrecision,
    status: status,
    startedAt: startedAt,
    pausedAt: pausedAt,
    endedAt: endedAt,
    liveLocationEnabled: liveLocationEnabled,
    thumbnailPath: thumbnailPath,
    thumbnailUrl: thumbnailUrl,
    trackingDurationMinutes: trackingDurationMinutes,
    trackingDisplay: trackingDisplay,
    intention: intention ?? this.intention,
    intentionType: intentionType ?? this.intentionType,
    intentionTags: intentionTags ?? this.intentionTags,
    anticipatedAt: anticipatedAt,
    reflectedAt: reflectedAt ?? this.reflectedAt,
    userId: userId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    tripIntervals: tripIntervals ?? this.tripIntervals,
  );
}

class TripIntentionResponse {
  final bool? success;
  final String? message;
  final String? intention;
  final String? intentionType;
  final List<String> intentionTags;

  TripIntentionResponse({
    this.success,
    this.message,
    this.intention,
    this.intentionType,
    this.intentionTags = const [],
  });

  factory TripIntentionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TripIntentionResponse(
      success: json['success'],
      message: json['message'],
      intention: data['intention'],
      intentionType: data['intention_type'],
      intentionTags: _strings(data['intention_tags']),
    );
  }
}

/// `POST /trips/{id}/reflection`
class TripReflectionResponse {
  final bool? success;
  final String? message;
  final DateTime? reflectedAt;

  TripReflectionResponse({this.success, this.message, this.reflectedAt});

  factory TripReflectionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TripReflectionResponse(
      success: json['success'],
      message: json['message'],
      reflectedAt: _date(data['reflected_at']),
    );
  }
}

/// One day of a trip.
class TripInterval {
  final String? id;
  final String? tripId;
  final int? dayNumber;
  final DateTime? date;
  final String? dayNote;
  final String? dailyReflection;
  final String? dailyReflectionSource;
  final DateTime? dailyReflectedAt;
  final DateTime? photosCategorizedAt;

  /// Sorted by `display_order`.
  final List<Checkpoint> checkPoints;

  TripInterval({
    this.id,
    this.tripId,
    this.dayNumber,
    this.date,
    this.dayNote,
    this.dailyReflection,
    this.dailyReflectionSource,
    this.dailyReflectedAt,
    this.photosCategorizedAt,
    this.checkPoints = const [],
  });

  factory TripInterval.fromJson(Map<String, dynamic> json) => TripInterval(
    id: json['id'],
    tripId: json['trip_id'],
    dayNumber: (json['day_number'] as num?)?.toInt(),
    date: _date(json['date']),
    dayNote: json['day_note'],
    dailyReflection: json['daily_reflection'],
    dailyReflectionSource: json['daily_reflection_source'],
    dailyReflectedAt: _date(json['daily_reflected_at']),
    photosCategorizedAt: _date(json['photos_categorized_at']),
    checkPoints: (json['checkPoints'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Checkpoint.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
  );
}

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

List<String> _strings(dynamic value) => (value as List? ?? const [])
    .map((e) => e?.toString() ?? '')
    .where((e) => e.isNotEmpty)
    .toList();
