import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/data/models/trip_models/day_photos_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';

abstract class ITripRepository {
  /// Cursor-paginated; pass the previous page's cursor to get the next page.
  Future<TripListResponse> getTrips({
    String? cursor,
    int limit = 20,
    TripStatus? status,
    String? search,
  });

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

  Future<TripResponse> updateTrip({
    required String tripId,
    required String title,
    required String startingPlace,
    required String destinedPlace,
    required DateTime startingDate,
    required DateTime endingDate,
    required bool travelTrackerEnabled,
    required bool isPublic,
    required bool canShare,
  });

  Future<TripResponse> deleteTrip(String tripId);

  Future<TripResponse> getTripDetails(String tripId);

  Future<TripResponse> startTrip(String tripId);

  Future<TripIntentionResponse> saveIntention({
    required String tripId,
    required IntentionType type,
    required List<String> tags,
    required String intention,
  });

  Future<TripThumbnailResponse> uploadThumbnail({
    required String tripId,
    required File file,
  });

  Future<DayPhotosResponse> getDayPhotos(String tripId, int day);

  /// Uploads [files] into one [category] of a day, as drafts.
  Future<PhotosActionResponse> uploadDayPhotos({
    required String tripId,
    required int day,
    required PhotoCategory category,
    required List<File> files,
  });

  /// Publishes all draft photos of the day.
  Future<PhotosActionResponse> finalizeDayPhotos(
    String tripId,
    int day, {
    String dayNote = '',
  });

  Future<PhotosActionResponse> deletePhoto(String tripId, String photoId);
}

class TripRepository implements ITripRepository {
  final ApiClient _client;

  TripRepository(this._client);

  static final _apiDate = DateFormat('yyyy-MM-dd');

  @override
  Future<TripListResponse> getTrips({
    String? cursor,
    int limit = 20,
    TripStatus? status,
    String? search,
  }) {
    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.trips,
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (status != null) 'status': status.apiValue,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
      (dynamic data) => TripListResponse.fromJson(data),
      'Get Trips',
    );
  }

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
        data: _tripBody(
          title: title,
          startingPlace: startingPlace,
          destinedPlace: destinedPlace,
          startingDate: startingDate,
          endingDate: endingDate,
          travelTrackerEnabled: travelTrackerEnabled,
          isPublic: isPublic,
          canShare: canShare,
        ),
      ),
      (dynamic data) => TripResponse.fromJson(data),
      'Create Trip',
    );
  }

  @override
  Future<TripResponse> updateTrip({
    required String tripId,
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
      () => _client.dio.patch(
        ApiEndpoint.tripDetails(tripId),
        data: _tripBody(
          title: title,
          startingPlace: startingPlace,
          destinedPlace: destinedPlace,
          startingDate: startingDate,
          endingDate: endingDate,
          travelTrackerEnabled: travelTrackerEnabled,
          isPublic: isPublic,
          canShare: canShare,
        ),
      ),
      (dynamic data) => TripResponse.fromJson(data),
      'Update Trip',
    );
  }

  @override
  Future<TripResponse> deleteTrip(String tripId) {
    return _client.handleRequest(
      () => _client.dio.delete(ApiEndpoint.tripDetails(tripId)),
      (dynamic data) => TripResponse.fromJson(data),
      'Delete Trip',
    );
  }

  Map<String, dynamic> _tripBody({
    required String title,
    required String startingPlace,
    required String destinedPlace,
    required DateTime startingDate,
    required DateTime endingDate,
    required bool travelTrackerEnabled,
    required bool isPublic,
    required bool canShare,
  }) => {
    'title': title,
    'starting_place': startingPlace,
    'destined_place': destinedPlace,
    'starting_date': _apiDate.format(startingDate),
    'ending_date': _apiDate.format(endingDate),
    'travel_tracker_enabled': travelTrackerEnabled,
    'is_public': isPublic,
    'can_share': canShare,
  };

  @override
  Future<TripResponse> getTripDetails(String tripId) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.tripDetails(tripId)),
      (dynamic data) => TripResponse.fromJson(data),
      'Get Trip Details',
    );
  }

  @override
  Future<TripResponse> startTrip(String tripId) {
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.startTrip(tripId)),
      (dynamic data) => TripResponse.fromJson(data),
      'Start Trip',
    );
  }

  @override
  Future<TripIntentionResponse> saveIntention({
    required String tripId,
    required IntentionType type,
    required List<String> tags,
    required String intention,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.tripIntention(tripId),
        data: {
          'intention_type': type.apiValue,
          'intention_tags': tags,
          'intention': intention,
        },
      ),
      (dynamic data) => TripIntentionResponse.fromJson(data),
      'Save Trip Intention',
    );
  }

  @override
  Future<TripThumbnailResponse> uploadThumbnail({
    required String tripId,
    required File file,
  }) async {
    final formData = FormData.fromMap({'file': await _imagePart(file)});

    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.tripThumbnail(tripId), data: formData),
      (dynamic data) => TripThumbnailResponse.fromJson(data),
      'Upload Trip Thumbnail',
    );
  }

  @override
  Future<DayPhotosResponse> getDayPhotos(String tripId, int day) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.dayPhotos(tripId, day)),
      (dynamic data) => DayPhotosResponse.fromJson(data),
      'Get Day Photos',
    );
  }

  @override
  Future<PhotosActionResponse> uploadDayPhotos({
    required String tripId,
    required int day,
    required PhotoCategory category,
    required List<File> files,
  }) async {
    final formData = FormData.fromMap({
      'category': category.apiValue,
      'is_draft': 'true',
    });
    for (final file in files) {
      formData.files.add(MapEntry('photos', await _imagePart(file)));
    }

    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.dayPhotos(tripId, day), data: formData),
      (dynamic data) => PhotosActionResponse.fromJson(data),
      'Upload Day Photos',
    );
  }

  @override
  Future<PhotosActionResponse> finalizeDayPhotos(
    String tripId,
    int day, {
    String dayNote = '',
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.finalizeDayPhotos(tripId, day),
        data: {'day_note': dayNote},
      ),
      (dynamic data) => PhotosActionResponse.fromJson(data),
      'Finalize Day Photos',
    );
  }

  @override
  Future<PhotosActionResponse> deletePhoto(String tripId, String photoId) {
    return _client.handleRequest(
      () => _client.dio.delete(ApiEndpoint.tripPhoto(tripId, photoId)),
      (dynamic data) => PhotosActionResponse.fromJson(data),
      'Delete Photo',
    );
  }

  Future<MultipartFile> _imagePart(File file) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    var ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpeg';
    if (ext == 'jpg') ext = 'jpeg';
    return MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: DioMediaType('image', ext),
    );
  }
}
