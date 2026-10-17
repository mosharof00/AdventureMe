import 'package:flutter_test/flutter_test.dart';
import 'package:adventureme/app/data/models/feed_models/feed_model.dart';
import 'package:adventureme/app/data/models/home_models/current_itinerary_model.dart';
import 'package:adventureme/app/data/models/home_models/latest_story_model.dart';
import 'package:adventureme/app/data/models/home_models/on_this_day_model.dart';
import 'package:adventureme/app/data/models/home_models/upcoming_itinerary_model.dart';
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

  test('OnThisDayResponse parses empty and populated response correctly', () {
    final emptyJson = {
      'success': true,
      'message': 'No memories found for this day yet. Keep exploring and capturing moments!',
      'data': {
        'hasMemory': false,
        'date': '2025-10-17T00:00:00.000Z',
        'formattedDate': 'October 17, 2025',
        'yearsAgo': null,
        'title': null,
        'subtitle': null,
        'imageUrl': null,
        'placeName': null,
        'trip': null,
        'memory': null
      }
    };

    final emptyResp = OnThisDayResponse.fromJson(emptyJson);
    expect(emptyResp.success, true);
    expect(emptyResp.data?.hasMemory, false);
    expect(emptyResp.data?.title, isNull);

    final populatedJson = {
      'success': true,
      'message': 'Flashback memory retrieved successfully.',
      'data': {
        'hasMemory': true,
        'date': '2025-06-10T00:00:00.000Z',
        'formattedDate': 'June 10, 2025',
        'yearsAgo': 1,
        'title': 'Remember the gelato you had in Florence?',
        'subtitle': 'Some moments stay with us forever!',
        'imageUrl': 'https://cdn.adventuresme.com/memories/gelato.jpg',
        'placeName': 'Florence',
        'trip': {
          'id': 'cm1234567890',
          'title': 'Italy Adventure',
          'destinedPlace': 'Florence',
          'startingPlace': 'Rome'
        },
        'memory': {
          'id': 'cm0987654321',
          'text': 'Had amazing gelato near Ponte Vecchio.',
          'emotion': 'joy',
          'taste': 'gelato'
        }
      }
    };

    final populatedResp = OnThisDayResponse.fromJson(populatedJson);
    expect(populatedResp.success, true);
    expect(populatedResp.data?.hasMemory, true);
    expect(populatedResp.data?.title, 'Remember the gelato you had in Florence?');
    expect(populatedResp.data?.yearsAgo, 1);
    expect(populatedResp.data?.trip?.id, 'cm1234567890');
    expect(populatedResp.data?.trip?.destinedPlace, 'Florence');
    expect(populatedResp.data?.memory?.emotion, 'joy');
    expect(populatedResp.data?.memory?.taste, 'gelato');

    final nullImageJson = {
      'success': true,
      'message': 'Trip memory retrieved successfully.',
      'data': {
        'hasMemory': true,
        'date': '2026-10-17T00:00:00.000Z',
        'formattedDate': 'October 17, 2026',
        'yearsAgo': 0,
        'title': 'Remember your trip to Banani, Dhaka?',
        'subtitle': 'Some moments stay with us forever!',
        'imageUrl': null,
        'placeName': 'Banani, Dhaka',
        'trip': {
          'id': 'cmvbuuecx0000s8vlxsat0bqi',
          'title': 'Gulshan-Banani explore',
          'destinedPlace': 'Banani, Dhaka',
          'startingPlace': 'Rampura, Dhaka'
        },
        'memory': null
      }
    };

    final nullImageResp = OnThisDayResponse.fromJson(nullImageJson);
    expect(nullImageResp.success, true);
    expect(nullImageResp.data?.hasMemory, true);
    expect(nullImageResp.data?.imageUrl, isNull);
    expect(nullImageResp.data?.title, 'Remember your trip to Banani, Dhaka?');
  });


  test('HomeLatestStoryResponse parses empty and populated response correctly', () {
    final emptyJson = {
      'success': true,
      'message': 'No stories generated yet. Complete an adventure to create your first story!',
      'data': {
        'hasStory': false,
        'story': null
      }
    };

    final emptyResp = HomeLatestStoryResponse.fromJson(emptyJson);
    expect(emptyResp.success, true);
    expect(emptyResp.data?.hasStory, false);
    expect(emptyResp.data?.story, isNull);

    final populatedJson = {
      'success': true,
      'message': 'Latest story retrieved successfully.',
      'data': {
        'hasStory': true,
        'story': {
          'id': 'cm_itinerary_123',
          'tripId': 'cm_trip_456',
          'title': 'Our Amalfi Coast Story',
          'date': '2025-06-10T00:00:00.000Z',
          'formattedDate': 'June 10, 2025',
          'readTime': '4 min read',
          'snippet': 'The winding roads, the ocean breeze, laughter that echoed all the way home. A trip we\'ll never forget.',
          'coverUrl': 'https://cdn.adventuresme.com/covers/amalfi.jpg',
          'isPublished': true,
          'shareToken': 'amalfi_story_share_xyz',
          'trip': {
            'id': 'cm_trip_456',
            'title': 'Summer in Italy',
            'destinedPlace': 'Amalfi Coast, Italy',
            'startingPlace': 'Rome'
          }
        }
      }
    };

    final populatedResp = HomeLatestStoryResponse.fromJson(populatedJson);
    expect(populatedResp.success, true);
    expect(populatedResp.data?.hasStory, true);
    expect(populatedResp.data?.story?.id, 'cm_itinerary_123');
    expect(populatedResp.data?.story?.tripId, 'cm_trip_456');
    expect(populatedResp.data?.story?.readTime, '4 min read');
    expect(populatedResp.data?.story?.trip?.title, 'Summer in Italy');
  });

  test('CurrentItineraryResponse parses empty and populated response correctly', () {
    final emptyJson = {
      'success': true,
      'message': 'No active itinerary right now. Start an adventure to begin tracking!',
      'data': {
        'hasCurrentTrip': false,
        'trip': null
      }
    };

    final emptyResp = CurrentItineraryResponse.fromJson(emptyJson);
    expect(emptyResp.success, true);
    expect(emptyResp.data?.hasCurrentTrip, false);
    expect(emptyResp.data?.trip, isNull);

    final populatedJson = {
      'success': true,
      'message': 'Current itinerary loaded successfully.',
      'data': {
        'hasCurrentTrip': true,
        'trip': {
          'id': 'cm_trip_bali',
          'title': 'Bali Visit',
          'description': 'Track your current trip and progress in a live location mode!',
          'status': 'ACTIVE',
          'startingPlace': 'Denpasar',
          'startingCountry': 'Indonesia',
          'destinedPlace': 'Ubud',
          'destinedCountry': 'Indonesia',
          'startDate': '2026-10-15T00:00:00.000Z',
          'endDate': '2026-10-22T00:00:00.000Z',
          'startedAt': '2026-10-15T08:30:00.000Z',
          'liveLocationEnabled': true,
          'travelTrackerEnabled': true,
          'trackingDurationMinutes': 180,
          'thumbnailUrl': 'https://cdn.adventuresme.com/trips/bali.jpg',
          'mapPreview': {
            'latestLocation': {
              'lat': -8.5069,
              'lng': 115.2625,
              'recordedAt': '2026-10-15T11:00:00.000Z'
            },
            'recentPings': [
              {
                'lat': -8.5069,
                'lng': 115.2625,
                'recordedAt': '2026-10-15T11:00:00.000Z'
              },
              {
                'lat': -8.512,
                'lng': 115.26,
                'recordedAt': '2026-10-15T10:45:00.000Z'
              }
            ],
            'checkPoints': [
              {
                'lat': -8.5069,
                'lng': 115.2625,
                'placeName': 'Ubud Monkey Forest',
                'status': 'PENDING'
              }
            ]
          }
        }
      }
    };

    final populatedResp = CurrentItineraryResponse.fromJson(populatedJson);
    expect(populatedResp.success, true);
    expect(populatedResp.data?.hasCurrentTrip, true);
    expect(populatedResp.data?.trip?.id, 'cm_trip_bali');
    expect(populatedResp.data?.trip?.title, 'Bali Visit');
    expect(populatedResp.data?.trip?.status, 'ACTIVE');
    expect(populatedResp.data?.trip?.startingCountry, 'Indonesia');
    expect(populatedResp.data?.trip?.destinedCountry, 'Indonesia');
    expect(populatedResp.data?.trip?.trackingDurationMinutes, 180);
    expect(populatedResp.data?.trip?.mapPreview?.latestLocation?.lat, -8.5069);
    expect(populatedResp.data?.trip?.mapPreview?.recentPings.length, 2);
    expect(populatedResp.data?.trip?.mapPreview?.checkPoints.first.placeName, 'Ubud Monkey Forest');
  });

  test('UpcomingItineraryResponse parses empty and populated response correctly', () {
    final emptyJson = {
      'success': true,
      'message': 'No upcoming itineraries found. Plan your next adventure today!',
      'data': {
        'hasUpcoming': false,
        'totalCount': 0,
        'featured': null,
        'items': []
      }
    };

    final emptyResp = UpcomingItineraryResponse.fromJson(emptyJson);
    expect(emptyResp.success, true);
    expect(emptyResp.data?.hasUpcoming, false);
    expect(emptyResp.data?.totalCount, 0);
    expect(emptyResp.data?.featured, isNull);
    expect(emptyResp.data?.items, isEmpty);

    final populatedJson = {
      'success': true,
      'message': 'Upcoming itineraries retrieved successfully.',
      'data': {
        'hasUpcoming': true,
        'totalCount': 1,
        'featured': {
          'id': 'cm_trip_florida',
          'title': 'Florida Adventure',
          'status': 'PENDING',
          'statusLabel': 'Pending',
          'startingPlace': 'Florida',
          'startingCountry': 'United States',
          'destinedPlace': 'Brazil',
          'destinedCountry': 'Brazil',
          'routeDisplay': 'Starting: Florida | Destined: Brazil',
          'startDate': '2026-05-07T00:00:00.000Z',
          'endDate': '2026-05-09T00:00:00.000Z',
          'dateDisplay': 'May 7 to May 9, 2026',
          'thumbnailUrl': null
        },
        'items': [
          {
            'id': 'cm_trip_florida',
            'title': 'Florida Adventure',
            'status': 'PENDING',
            'statusLabel': 'Pending',
            'startingPlace': 'Florida',
            'startingCountry': 'United States',
            'destinedPlace': 'Brazil',
            'destinedCountry': 'Brazil',
            'routeDisplay': 'Starting: Florida | Destined: Brazil',
            'startDate': '2026-05-07T00:00:00.000Z',
            'endDate': '2026-05-09T00:00:00.000Z',
            'dateDisplay': 'May 7 to May 9, 2026',
            'thumbnailUrl': null
          }
        ]
      }
    };

    final populatedResp = UpcomingItineraryResponse.fromJson(populatedJson);
    expect(populatedResp.success, true);
    expect(populatedResp.data?.hasUpcoming, true);
    expect(populatedResp.data?.totalCount, 1);
    expect(populatedResp.data?.featured?.id, 'cm_trip_florida');
    expect(populatedResp.data?.featured?.title, 'Florida Adventure');
    expect(populatedResp.data?.featured?.statusLabel, 'Pending');
    expect(populatedResp.data?.featured?.startingCountry, 'United States');
    expect(populatedResp.data?.featured?.destinedCountry, 'Brazil');
    expect(populatedResp.data?.featured?.routeDisplay, 'Starting: Florida | Destined: Brazil');
    expect(populatedResp.data?.featured?.dateDisplay, 'May 7 to May 9, 2026');
    expect(populatedResp.data?.items.length, 1);
  });

  test('FeedResponse parses empty and populated feed payloads correctly', () {
    final emptyJson = {
      'success': true,
      'message': 'No public adventures found at this time.',
      'data': {
        'items': [],
        'meta': {
          'limit': 10,
          'hasNextPage': false,
          'nextCursor': null,
          'count': 0
        }
      }
    };

    final emptyResp = FeedResponse.fromJson(emptyJson);
    expect(emptyResp.success, true);
    expect(emptyResp.data?.items, isEmpty);
    expect(emptyResp.data?.meta?.hasNextPage, false);
    expect(emptyResp.data?.meta?.nextCursor, isNull);

    final populatedJson = {
      'success': true,
      'message': 'Feed retrieved successfully.',
      'data': {
        'items': [
          {
            'id': 'cm_trip_001',
            'title': 'Florida Beach, A Heaven with your Favorite!',
            'coverUrl': 'https://cdn.adventuresme.com/trips/florida-beach.jpg',
            'startingPlace': 'Miami',
            'destinedPlace': 'Florida',
            'startingCountry': 'United States',
            'destinedCountry': 'United States',
            'placeDisplay': 'Miami, Florida',
            'dateRangeDisplay': 'Mar 10 to Mar 17, 2026',
            'subtitle': 'Miami, Florida - Mar 10 to Mar 17, 2026',
            'viewsCount': 34000,
            'viewsDisplay': '34k',
            'status': 'COMPLETED',
            'isCompleted': true,
            'isPublic': true,
            'author': {
              'id': 'cm_user_jack_01',
              'name': 'Jack Kargille',
              'username': 'jackk',
              'avatarUrl': 'https://cdn.adventuresme.com/avatars/jack.jpg'
            },
            'isBookmark': false,
            'isSaved': false,
            'savedId': null,
            'hasStory': true,
            'story': {
              'id': 'cm_story_florida_01',
              'title': 'Florida Beach, A Heaven with your Favorite!',
              'description': 'The warm ocean breeze and unforgettable sunsets on the sandy shores.',
              'readTime': '3 min read',
              'isPublished': true,
              'shareToken': 'florida_share_abc123'
            },
            'createdAt': '2026-03-18T10:00:00.000Z'
          }
        ],
        'meta': {
          'limit': 10,
          'hasNextPage': true,
          'nextCursor': 'cm_trip_003',
          'count': 3
        }
      }
    };

    final populatedResp = FeedResponse.fromJson(populatedJson);
    expect(populatedResp.success, true);
    expect(populatedResp.data?.items.length, 1);
    final first = populatedResp.data!.items.first;
    expect(first.id, 'cm_trip_001');
    expect(first.title, 'Florida Beach, A Heaven with your Favorite!');
    expect(first.viewsDisplay, '34k');
    expect(first.author?.name, 'Jack Kargille');
    expect(first.hasStory, true);
    expect(first.story?.readTime, '3 min read');
    expect(populatedResp.data?.meta?.hasNextPage, true);
    expect(populatedResp.data?.meta?.nextCursor, 'cm_trip_003');
  });
}



