double? _double(dynamic value) => (value as num?)?.toDouble();

DateTime? _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '');

class GeoBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  const GeoBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  static GeoBounds? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final north = _double(json['north']), south = _double(json['south']);
    final east = _double(json['east']), west = _double(json['west']);
    if (north == null || south == null || east == null || west == null) {
      return null;
    }
    return GeoBounds(north: north, south: south, east: east, west: west);
  }
}

class Checkpoint {
  final String? id;
  final String? title;
  final String? address;
  final double lat;
  final double lng;
  final DateTime? enteredAt;
  final DateTime? exitedAt;
  final int? durationMinutes;
  final int displayOrder;
  final String? status;
  final String? source;
  final int photoCount;

  const Checkpoint({
    this.id,
    this.title,
    this.address,
    required this.lat,
    required this.lng,
    this.enteredAt,
    this.exitedAt,
    this.durationMinutes,
    this.displayOrder = 0,
    this.status,
    this.source,
    this.photoCount = 0,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) => Checkpoint(
        id: json['id']?.toString(),
        title: json['title'],
        address: json['address'],
        lat: _double(json['lat']) ?? 0,
        lng: _double(json['lng']) ?? 0,
        enteredAt: _date(json['entered_at']),
        exitedAt: _date(json['exited_at']),
        durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
        status: json['status'],
        source: json['source'],
        photoCount: (json['photo_count'] as num?)?.toInt() ?? 0,
      );
}

/// The day's marker on the trip map (usually its longest-stay checkpoint).
class DayAnchor {
  final double lat;
  final double lng;
  final String? checkpointId;
  final String? placeName;

  const DayAnchor({
    required this.lat,
    required this.lng,
    this.checkpointId,
    this.placeName,
  });

  static DayAnchor? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final lat = _double(json['lat']), lng = _double(json['lng']);
    if (lat == null || lng == null) return null;
    return DayAnchor(
      lat: lat,
      lng: lng,
      checkpointId: json['checkpoint_id']?.toString(),
      placeName: json['place_name'],
    );
  }
}

class TripMapDay {
  final int dayNumber;
  final DateTime? date;
  final DayAnchor? anchor;
  final GeoBounds? bounds;
  final String? routePolyline;
  final int? distanceMeters;
  final List<Checkpoint> checkpoints;

  const TripMapDay({
    required this.dayNumber,
    this.date,
    this.anchor,
    this.bounds,
    this.routePolyline,
    this.distanceMeters,
    this.checkpoints = const [],
  });

  factory TripMapDay.fromJson(Map<String, dynamic> json) {
    final checkpoints = (json['checkpoints'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Checkpoint.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return TripMapDay(
      dayNumber: (json['day_number'] as num?)?.toInt() ?? 0,
      date: _date(json['date']),
      anchor: DayAnchor.fromJson(json['anchor']),
      bounds: GeoBounds.fromJson(json['bounds']),
      routePolyline: json['route_polyline'],
      distanceMeters: (json['distance_meters'] as num?)?.toInt(),
      checkpoints: checkpoints,
    );
  }

  /// Adds [checkpoint] at its order; becomes the anchor if the day had none.
  TripMapDay withCheckpoint(Checkpoint checkpoint) => TripMapDay(
        dayNumber: dayNumber,
        date: date,
        anchor: anchor ??
            DayAnchor(
              lat: checkpoint.lat,
              lng: checkpoint.lng,
              checkpointId: checkpoint.id,
              placeName: checkpoint.title,
            ),
        bounds: null,
        routePolyline: null,
        distanceMeters: distanceMeters,
        checkpoints: [...checkpoints, checkpoint]
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      );
}

/// `GET /trips/{id}/map`
class TripMapResponse {
  final bool? success;
  final String? message;
  final GeoBounds? bounds;
  final List<TripMapDay> days;

  TripMapResponse({
    this.success,
    this.message,
    this.bounds,
    this.days = const [],
  });

  factory TripMapResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TripMapResponse(
      success: json['success'],
      message: json['message'],
      bounds: GeoBounds.fromJson(data['bounds']),
      days: (data['days'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TripMapDay.fromJson)
          .toList(),
    );
  }
}

/// `POST /trips/{id}/days/{day}/checkpoints`
class CheckpointResponse {
  final bool? success;
  final String? message;
  final Checkpoint? data;

  CheckpointResponse({this.success, this.message, this.data});

  factory CheckpointResponse.fromJson(Map<String, dynamic> json) =>
      CheckpointResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] is Map<String, dynamic>
            ? Checkpoint.fromJson(json['data'])
            : null,
      );
}
