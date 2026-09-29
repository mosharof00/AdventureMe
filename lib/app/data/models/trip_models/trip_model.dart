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
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.tripIntervals = const [],
  });

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
        userId: json['user_id'],
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
        tripIntervals: (json['tripIntervals'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(TripInterval.fromJson)
            .toList(),
      );
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
      );
}

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
