import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';

/// Demo `GET /trips/{id}/map` payload until the backend endpoint is live.
/// Built in the API's JSON shape so it goes through the real parser.
class TripMapDemo {
  static const _places = [
    [
      ('Naples Airport', 'Viale F. Ruffo di Calabria', 40.8860, 14.2908, 30),
      ("Palazzo dell'Immacolatella", 'Imbarco Grimaldi Lines', 40.8409, 14.2611, 45),
      ('Castel dell\'Ovo', 'Via Eldorado, Naples', 40.8282, 14.2475, 90),
      ('Spaccanapoli', 'Centro Storico, Naples', 40.8484, 14.2550, 60),
    ],
    [
      ('Positano Ferry Pier', 'Via del Brigantino', 40.6268, 14.4853, 20),
      ('Spiaggia Grande', 'Positano Beach', 40.6281, 14.4870, 150),
      ('Fornillo Beach', 'Via Fornillo, Positano', 40.6260, 14.4800, 60),
    ],
    [
      ('Amalfi Cathedral', "Piazza del Duomo, Amalfi", 40.6346, 14.6027, 40),
      ('Atrani', 'Atrani Village', 40.6360, 14.6080, 50),
      ('Villa Rufolo', 'Piazza Duomo, Ravello', 40.6490, 14.6115, 120),
    ],
    [
      ('Marina Grande', 'Capri Port', 40.5560, 14.2380, 25),
      ('Blue Grotto', 'Grotta Azzurra, Anacapri', 40.5606, 14.2058, 70),
      ('Anacapri Centre', 'Piazza Vittoria, Anacapri', 40.5530, 14.2160, 100),
    ],
    [
      ('Pompeii Ruins', 'Via Villa dei Misteri', 40.7490, 14.4840, 180),
      ('Sorrento Piazza Tasso', 'Piazza Tasso, Sorrento', 40.6263, 14.3757, 60),
    ],
  ];

  /// [days] are `(dayNumber, date)` pairs of the trip. With more than two
  /// days, the last one is left empty to show the "no checkpoints" state.
  static TripMapResponse build(List<(int, DateTime?)> days) {
    return TripMapResponse.fromJson({
      'success': true,
      'message': 'Demo map',
      'data': {
        'days': [
          for (var i = 0; i < days.length; i++)
            _day(
              days[i].$1,
              days[i].$2,
              days.length > 2 && i == days.length - 1
                  ? const []
                  : _places[i % _places.length],
            ),
        ],
      },
    });
  }

  static Map<String, dynamic> _day(
    int dayNumber,
    DateTime? date,
    List<(String, String, double, double, int)> places,
  ) {
    final day = date ?? DateTime.now();
    var time = DateTime(day.year, day.month, day.day, 9, 30);
    final checkpoints = <Map<String, dynamic>>[];
    for (var i = 0; i < places.length; i++) {
      final (title, address, lat, lng, minutes) = places[i];
      final exited = time.add(Duration(minutes: minutes));
      checkpoints.add({
        'id': 'demo_${dayNumber}_$i',
        'title': title,
        'address': address,
        'lat': lat,
        'lng': lng,
        'entered_at': time.toUtc().toIso8601String(),
        'exited_at': exited.toUtc().toIso8601String(),
        'duration_minutes': minutes,
        'display_order': i + 1,
        'status': 'COMPLETED',
        'source': 'MANUAL',
      });
      time = exited.add(const Duration(minutes: 40));
    }

    Map<String, dynamic>? anchor;
    if (checkpoints.isNotEmpty) {
      final longest = checkpoints.reduce(
        (a, b) =>
            (a['duration_minutes'] as int) >= (b['duration_minutes'] as int)
                ? a
                : b,
      );
      anchor = {
        'lat': longest['lat'],
        'lng': longest['lng'],
        'checkpoint_id': longest['id'],
        'place_name': longest['title'],
      };
    }

    return {
      'day_number': dayNumber,
      'date': date?.toIso8601String(),
      'anchor': anchor,
      'route_polyline': null,
      'checkpoints': checkpoints,
    };
  }
}