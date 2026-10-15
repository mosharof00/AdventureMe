import 'package:flutter_test/flutter_test.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_story_model.dart';
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

  test('TripResponse parses delete trip response correctly', () {
    final json = {
      'success': true,
      'message': 'Trip removed.',
    };

    final response = TripResponse.fromJson(json);
    expect(response.success, true);
    expect(response.message, 'Trip removed.');
    expect(response.data, isNull);
  });

  test('TripData parses story_created_at and hasStory correctly', () {
    final jsonWithoutStory = {
      'id': 'cmv92rczg000070vlep83lv7z',
      'title': 'Test Trip',
      'story_created_at': null,
    };
    final trip1 = TripData.fromJson(jsonWithoutStory);
    expect(trip1.storyCreatedAt, isNull);
    expect(trip1.hasStory, false);

    final jsonWithStory = {
      'id': 'cmv92rczg000070vlep83lv7z',
      'title': 'Test Trip',
      'story_created_at': '2026-10-14T08:15:24.161Z',
    };
    final trip2 = TripData.fromJson(jsonWithStory);
    expect(trip2.storyCreatedAt, isNotNull);
    expect(trip2.hasStory, true);
  });

  test('TripStoryResponse parses story data and caps cover photos to <= 3', () {
    final json = {
      'success': true,
      'message': 'Your story is ready.',
      'data': {
        'itinerary_id': 'cmuxx0ih7000lbsvlf1l9jmzu',
        'trip_id': 'cmuxwqadw0000bsvlntlr3xk8',
        'title': 'Family Adventure in the Amazon Jungle',
        'cover_url': 'https://example.com/cover.jpg',
        'cover_photos': [
          'https://example.com/p1.jpg',
          'https://example.com/p2.jpg',
          'https://example.com/p3.jpg',
          'https://example.com/p4.jpg',
          'https://example.com/p5.jpg',
        ],
        'story_created_at': '2026-10-12T03:41:04.196Z',
        'author': {
          'id': 'u1',
          'name': 'User update',
          'avatar_url': 'https://example.com/avatar.jpg',
          'is_verified': true,
        },
        'summary': {
          'locations_explored': 'Total of 12 locations have been explored.',
          'total_locations_count': 12,
          'miles_traveled': '13397 miles',
          'total_duration': 'From May 7 to May 12, 2026',
        },
        'days': [
          {
            'day_number': 1,
            'title': 'Arrival',
            'narrative': 'Arrived at the location.',
            'moments': [
              {
                'id': 'm1',
                'category_label': 'CONNECTION',
                'title': 'Laughter at the Table',
                'quote': 'Fun moments together.',
                'photos': [
                  {
                    'id': 'ph1',
                    'url': 'https://example.com/photo1.jpg',
                  }
                ]
              }
            ]
          }
        ]
      }
    };

    final response = TripStoryResponse.fromJson(json);
    expect(response.success, true);
    expect(response.data?.title, 'Family Adventure in the Amazon Jungle');
    expect(response.data?.author?.name, 'User update');
    expect(response.data?.author?.isVerified, true);
    expect(response.data?.effectiveCoverPhotos.length, 3);
    expect(response.data?.days.first.moments.first.allPhotoUrls,
        ['https://example.com/photo1.jpg']);
  });
}
