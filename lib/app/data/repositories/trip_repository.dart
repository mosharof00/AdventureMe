import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';

abstract class ITripRepository {
  Future<TripResponse> createTrip({
    required String title,
    required String startingPlace,
    required String destinedPlace,
    required DateTime startingDate,
    required DateTime endingDate,
    required bool travelTrackerEnabled,
    required bool isPublic,
    required bool canShare,
  });
}

class TripRepository implements ITripRepository {
  final ApiClient _client;

  TripRepository(this._client);

  static final _apiDate = DateFormat('yyyy-MM-dd');

  @override
  Future<TripResponse> createTrip({
    required String title,
    required String startingPlace,
    required String destinedPlace,
    required DateTime startingDate,
    required DateTime endingDate,
    required bool travelTrackerEnabled,
    required bool isPublic,
    required bool canShare,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.trips,
        data: {
          'title': title,
          'starting_place': startingPlace,
          'destined_place': destinedPlace,
          'starting_date': _apiDate.format(startingDate),
          'ending_date': _apiDate.format(endingDate),
          'travel_tracker_enabled': travelTrackerEnabled,
          'is_public': isPublic,
          'can_share': canShare,
        },
      ),
      (dynamic data) => TripResponse.fromJson(data),
      'Create Trip',
    );
  }
}
