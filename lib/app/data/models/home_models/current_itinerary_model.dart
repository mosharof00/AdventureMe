class CurrentItineraryResponse {
  final bool? success;
  final String? message;
  final CurrentItineraryData? data;

  CurrentItineraryResponse({this.success, this.message, this.data});

  factory CurrentItineraryResponse.fromJson(Map<String, dynamic> json) =>
      CurrentItineraryResponse(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? CurrentItineraryData.fromJson(
                json['data'] as Map<String, dynamic>)
            : null,
      );
}

class CurrentItineraryData {
  final bool hasCurrentTrip;
  final CurrentItineraryTrip? trip;

  CurrentItineraryData({
    this.hasCurrentTrip = false,
    this.trip,
  });

  factory CurrentItineraryData.fromJson(Map<String, dynamic> json) =>
      CurrentItineraryData(
        hasCurrentTrip: json['hasCurrentTrip'] == true,
        trip: json['trip'] is Map<String, dynamic>
            ? CurrentItineraryTrip.fromJson(
                json['trip'] as Map<String, dynamic>)
            : null,
      );
}

class CurrentItineraryTrip {
  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? startingPlace;
  final String? startingCountry;
  final String? destinedPlace;
  final String? destinedCountry;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? startedAt;
  final bool? liveLocationEnabled;
  final bool? travelTrackerEnabled;
  final int? trackingDurationMinutes;
  final String? thumbnailUrl;
  final MapPreview? mapPreview;

  CurrentItineraryTrip({
    this.id,
    this.title,
    this.description,
    this.status,
    this.startingPlace,
    this.startingCountry,
    this.destinedPlace,
    this.destinedCountry,
    this.startDate,
    this.endDate,
    this.startedAt,
    this.liveLocationEnabled,
    this.travelTrackerEnabled,
    this.trackingDurationMinutes,
    this.thumbnailUrl,
    this.mapPreview,
  });

  factory CurrentItineraryTrip.fromJson(Map<String, dynamic> json) =>
      CurrentItineraryTrip(
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        description: json['description']?.toString(),
        status: json['status']?.toString(),
        startingPlace: json['startingPlace']?.toString(),
        startingCountry: json['startingCountry']?.toString(),
        destinedPlace: json['destinedPlace']?.toString(),
        destinedCountry: json['destinedCountry']?.toString(),
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'].toString())
            : null,
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'].toString())
            : null,
        startedAt: json['startedAt'] != null
            ? DateTime.tryParse(json['startedAt'].toString())
            : null,
        liveLocationEnabled: json['liveLocationEnabled'] as bool?,
        travelTrackerEnabled: json['travelTrackerEnabled'] as bool?,
        trackingDurationMinutes:
            (json['trackingDurationMinutes'] as num?)?.toInt(),
        thumbnailUrl: json['thumbnailUrl']?.toString(),
        mapPreview: json['mapPreview'] is Map<String, dynamic>
            ? MapPreview.fromJson(json['mapPreview'] as Map<String, dynamic>)
            : null,
      );
}

class MapPreview {
  final MapLocationPing? latestLocation;
  final List<MapLocationPing> recentPings;
  final List<MapCheckpointPreview> checkPoints;

  MapPreview({
    this.latestLocation,
    this.recentPings = const [],
    this.checkPoints = const [],
  });

  factory MapPreview.fromJson(Map<String, dynamic> json) => MapPreview(
        latestLocation: json['latestLocation'] is Map<String, dynamic>
            ? MapLocationPing.fromJson(
                json['latestLocation'] as Map<String, dynamic>)
            : null,
        recentPings: (json['recentPings'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(MapLocationPing.fromJson)
                .toList() ??
            const [],
        checkPoints: (json['checkPoints'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(MapCheckpointPreview.fromJson)
                .toList() ??
            const [],
      );
}

class MapLocationPing {
  final double? lat;
  final double? lng;
  final DateTime? recordedAt;

  MapLocationPing({
    this.lat,
    this.lng,
    this.recordedAt,
  });

  factory MapLocationPing.fromJson(Map<String, dynamic> json) =>
      MapLocationPing(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        recordedAt: json['recordedAt'] != null
            ? DateTime.tryParse(json['recordedAt'].toString())
            : null,
      );
}

class MapCheckpointPreview {
  final double? lat;
  final double? lng;
  final String? placeName;
  final String? status;

  MapCheckpointPreview({
    this.lat,
    this.lng,
    this.placeName,
    this.status,
  });

  factory MapCheckpointPreview.fromJson(Map<String, dynamic> json) =>
      MapCheckpointPreview(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        placeName: json['placeName']?.toString(),
        status: json['status']?.toString(),
      );
}
