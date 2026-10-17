import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/data/models/home_models/current_itinerary_model.dart';
import 'package:adventureme/app/data/models/home_models/latest_story_model.dart';
import 'package:adventureme/app/data/models/home_models/on_this_day_model.dart';
import 'package:adventureme/app/data/models/home_models/upcoming_itinerary_model.dart';

abstract class IHomeRepository {
  Future<OnThisDayResponse> getOnThisDay(String date);
  Future<HomeLatestStoryResponse> getLatestStory();
  Future<CurrentItineraryResponse> getCurrentItinerary();
  Future<UpcomingItineraryResponse> getUpcomingItinerary({int limit = 10});
}

class HomeRepository implements IHomeRepository {
  HomeRepository(this._client);

  final ApiClient _client;

  @override
  Future<OnThisDayResponse> getOnThisDay(String date) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.onThisDay(date)),
      (dynamic data) =>
          OnThisDayResponse.fromJson(data as Map<String, dynamic>),
      'Home On This Day',
    );
  }

  @override
  Future<HomeLatestStoryResponse> getLatestStory() {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.latestStory),
      (dynamic data) =>
          HomeLatestStoryResponse.fromJson(data as Map<String, dynamic>),
      'Home Latest Story',
    );
  }

  @override
  Future<CurrentItineraryResponse> getCurrentItinerary() {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.currentItinerary),
      (dynamic data) =>
          CurrentItineraryResponse.fromJson(data as Map<String, dynamic>),
      'Home Current Itinerary',
    );
  }

  @override
  Future<UpcomingItineraryResponse> getUpcomingItinerary({int limit = 10}) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.upcomingItinerary(limit: limit)),
      (dynamic data) =>
          UpcomingItineraryResponse.fromJson(data as Map<String, dynamic>),
      'Home Upcoming Itinerary',
    );
  }
}
