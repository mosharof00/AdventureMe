import 'package:adventureme/app/core/network/api_client.dart';
import 'package:adventureme/app/core/network/api_endpoints.dart';
import 'package:adventureme/app/data/models/feed_models/feed_model.dart';

abstract class IFeedRepository {
  Future<FeedResponse> getFeed({
    String? cursor,
    int limit = 10,
    String? filter,
    String? search,
    String? status,
    bool? hasStory,
  });
}

class FeedRepository implements IFeedRepository {
  FeedRepository(this._client);

  final ApiClient _client;

  @override
  Future<FeedResponse> getFeed({
    String? cursor,
    int limit = 10,
    String? filter,
    String? search,
    String? status,
    bool? hasStory,
  }) {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (hasStory != null) queryParams['has_story'] = hasStory;

    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.feed,
        queryParameters: queryParams,
      ),
      (dynamic data) => FeedResponse.fromJson(data as Map<String, dynamic>),
      'Get Feed',
    );
  }
}
