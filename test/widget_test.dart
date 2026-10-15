import 'package:flutter_test/flutter_test.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/models/trip_models/visited_countries_model.dart';

void main() {
  test('TripData parses country fields correctly', () {
    final json = {
      'id': 'cmv92rczg000070vlep83lv7z',
      'title': 'Summer in Portugal',
      'starting_place': 'Lisbon',
      'starting_country': 'Portugal',
      'destined_place': 'Porto',
      'destined_country': 'Portugal',
      'starting_date': '2026-07-01T00:00:00.000Z',
      'ending_date': '2026-07-10T00:00:00.000Z',
    };

    final trip = TripData.fromJson(json);
    expect(trip.startingCountry, 'Portugal');
    expect(trip.destinedCountry, 'Portugal');
  });

  test('VisitedCountriesResponse parses correctly', () {
    final json = {
      'success': true,
      'message': 'You have explored 4 countries so far.',
      'data': {
        'totalVisitedCountries': 4,
        'totalWorldCountries': 195,
        'worldPercentage': 2.05,
        'worldPercentageRounded': 2,
        'summaryText': '4 Countries visited out of 195',
      }
    };

    final response = VisitedCountriesResponse.fromJson(json);
    expect(response.success, true);
    expect(response.data?.totalVisitedCountries, 4);
    expect(response.data?.totalWorldCountries, 195);
    expect(response.data?.worldPercentageRounded, 2);
  });
}
