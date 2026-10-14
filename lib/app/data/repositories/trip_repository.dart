import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/core/constants/enums.dart';
import 'package:adventureme/app/data/models/trip_models/day_photos_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_list_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_map_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_memory_model.dart';
import 'package:adventureme/app/data/models/trip_models/story_status_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_model.dart';
import 'package:adventureme/app/data/models/trip_models/trip_prompt_model.dart';

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

  Future<TripResponse> endTrip(String tripId);

  /// Starts a story job, or returns the recently generated one.
  Future<StoryStatusResponse> generateStory(String tripId);

  Future<StoryStatusResponse> getStoryStatus(String tripId);

  Future<TripReflectionResponse> saveReflection({
    required String tripId,
    required String reflection,
    required DominantEmotion emotion,
  });

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
  /// [title], [quote] and the location are optional context for the moment.
  Future<PhotosActionResponse> uploadDayPhotos({
    required String tripId,
    required int day,
    required PhotoCategory category,
    required List<File> files,
    String? title,
    String? quote,
    double? lat,
    double? lng,
  });

  /// Publishes all draft photos of the day.
  Future<PhotosActionResponse> finalizeDayPhotos(
    String tripId,
    int day, {
    String dayNote = '',
  });

  Future<PhotosActionResponse> deletePhoto(String tripId, String photoId);

  /// Saves a quick note ([text]) or a voice recording ([voice]) for a day.
  Future<TripMemoryResponse> addMemory({
    required String tripId,
    required int day,
    required MemorySource source,
    String? text,
    File? voice,
  });

  Future<TripMapResponse> getTripMap(String tripId);

  Future<CheckpointResponse> addCheckpoint({
    required String tripId,
    required int day,
    required String title,
    required String address,
    required double lat,
    required double lng,
    required DateTime enteredAt,
    required DateTime exitedAt,
  });

  /// [timezone] is an IANA name, e.g. `Asia/Dhaka`.
  Future<PromptBatchResponse> getPromptBatch(String tripId, String timezone);

  /// [answers] maps prompt id → text. With [skipRemaining], prompts left out
  /// of [answers] are marked skipped.
  Future<PromptAnswerResponse> answerPromptBatch(
    String tripId,
    Map<String, String> answers, {
    bool skipRemaining = true,
  });
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
  Future<TripResponse> endTrip(String tripId) {
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.endTrip(tripId)),
      (dynamic data) => TripResponse.fromJson(data),
      'End Trip',
    );
  }

  @override
  Future<StoryStatusResponse> generateStory(String tripId) {
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.generateStory(tripId)),
      (dynamic data) => StoryStatusResponse.fromJson(data),
      'Generate Story',
    );
  }

  @override
  Future<StoryStatusResponse> getStoryStatus(String tripId) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.storyStatus(tripId)),
      (dynamic data) => StoryStatusResponse.fromJson(data),
      'Story Status',
    );
  }

  @override
  Future<TripReflectionResponse> saveReflection({
    required String tripId,
    required String reflection,
    required DominantEmotion emotion,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.tripReflection(tripId),
        data: {'reflection': reflection, 'dominant_emotion': emotion.apiValue},
      ),
      (dynamic data) => TripReflectionResponse.fromJson(data),
      'Save Trip Reflection',
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
    String? title,
    String? quote,
    double? lat,
    double? lng,
  }) async {
    final formData = FormData.fromMap({
      'category': category.apiValue,
      'is_draft': 'true',
      if (title != null && title.isNotEmpty) 'title': title,
      if (quote != null && quote.isNotEmpty) 'quote': quote,
      if (lat != null && lng != null) ...{'lat': '$lat', 'lng': '$lng'},
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

  @override
  Future<TripMemoryResponse> addMemory({
    required String tripId,
    required int day,
    required MemorySource source,
    String? text,
    File? voice,
  }) async {
    final formData = FormData.fromMap({
      'day_number': day.toString(),
      'source': source.apiValue,
      if (text != null && text.isNotEmpty) 'text': text,
      if (voice != null)
        'voice': await MultipartFile.fromFile(
          voice.path,
          filename: voice.path.split(Platform.pathSeparator).last,
          contentType: DioMediaType('audio', 'mp4'),
        ),
    });

    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.tripMemories(tripId), data: formData),
      (dynamic data) => TripMemoryResponse.fromJson(data),
      'Add Trip Memory',
    );
  }

  @override
  Future<TripMapResponse> getTripMap(String tripId) {
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.tripMap(tripId)),
      (dynamic data) => TripMapResponse.fromJson(data),
      'Get Trip Map',
    );
  }

  @override
  Future<CheckpointResponse> addCheckpoint({
    required String tripId,
    required int day,
    required String title,
    required String address,
    required double lat,
    required double lng,
    required DateTime enteredAt,
    required DateTime exitedAt,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.dayCheckpoints(tripId, day),
        data: {
          'title': title,
          'address': address,
          'lat': lat,
          'lng': lng,
          'entered_at': enteredAt.toUtc().toIso8601String(),
          'exited_at': exitedAt.toUtc().toIso8601String(),
        },
      ),
      (dynamic data) => CheckpointResponse.fromJson(data),
      'Add Checkpoint',
    );
  }

  @override
  Future<PromptBatchResponse> getPromptBatch(String tripId, String timezone) {
    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.promptBatch(tripId),
        queryParameters: {'timezone': timezone},
      ),
      (dynamic data) => PromptBatchResponse.fromJson(data),
      'Get Prompt Batch',
    );
  }

  @override
  Future<PromptAnswerResponse> answerPromptBatch(
    String tripId,
    Map<String, String> answers, {
    bool skipRemaining = true,
  }) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.answerPromptBatch(tripId),
        data: {
          'answers': [
            for (final entry in answers.entries)
              {'prompt_id': entry.key, 'text': entry.value},
          ],
          'skip_remaining': skipRemaining,
        },
      ),
      (dynamic data) => PromptAnswerResponse.fromJson(data),
      'Answer Prompt Batch',
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
