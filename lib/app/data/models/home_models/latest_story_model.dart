class HomeLatestStoryResponse {
  final bool? success;
  final String? message;
  final HomeLatestStoryData? data;

  HomeLatestStoryResponse({this.success, this.message, this.data});

  factory HomeLatestStoryResponse.fromJson(Map<String, dynamic> json) =>
      HomeLatestStoryResponse(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? HomeLatestStoryData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class HomeLatestStoryData {
  final bool hasStory;
  final HomeStory? story;

  HomeLatestStoryData({
    this.hasStory = false,
    this.story,
  });

  factory HomeLatestStoryData.fromJson(Map<String, dynamic> json) =>
      HomeLatestStoryData(
        hasStory: json['hasStory'] == true,
        story: json['story'] is Map<String, dynamic>
            ? HomeStory.fromJson(json['story'] as Map<String, dynamic>)
            : null,
      );
}

class HomeStory {
  final String? id;
  final String? tripId;
  final String? title;
  final DateTime? date;
  final String? formattedDate;
  final String? readTime;
  final String? snippet;
  final String? coverUrl;
  final bool? isPublished;
  final String? shareToken;
  final HomeStoryTrip? trip;

  HomeStory({
    this.id,
    this.tripId,
    this.title,
    this.date,
    this.formattedDate,
    this.readTime,
    this.snippet,
    this.coverUrl,
    this.isPublished,
    this.shareToken,
    this.trip,
  });

  factory HomeStory.fromJson(Map<String, dynamic> json) => HomeStory(
        id: json['id']?.toString(),
        tripId: json['tripId']?.toString(),
        title: json['title']?.toString(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString())
            : null,
        formattedDate: json['formattedDate']?.toString(),
        readTime: json['readTime']?.toString(),
        snippet: json['snippet']?.toString(),
        coverUrl: json['coverUrl']?.toString(),
        isPublished: json['isPublished'] as bool?,
        shareToken: json['shareToken']?.toString(),
        trip: json['trip'] is Map<String, dynamic>
            ? HomeStoryTrip.fromJson(json['trip'] as Map<String, dynamic>)
            : null,
      );
}

class HomeStoryTrip {
  final String? id;
  final String? title;
  final String? destinedPlace;
  final String? startingPlace;

  HomeStoryTrip({
    this.id,
    this.title,
    this.destinedPlace,
    this.startingPlace,
  });

  factory HomeStoryTrip.fromJson(Map<String, dynamic> json) => HomeStoryTrip(
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        destinedPlace: json['destinedPlace']?.toString(),
        startingPlace: json['startingPlace']?.toString(),
      );
}
