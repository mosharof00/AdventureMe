class UpcomingItineraryResponse {
  final bool? success;
  final String? message;
  final UpcomingItineraryData? data;

  UpcomingItineraryResponse({this.success, this.message, this.data});

  factory UpcomingItineraryResponse.fromJson(Map<String, dynamic> json) =>
      UpcomingItineraryResponse(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? UpcomingItineraryData.fromJson(
                json['data'] as Map<String, dynamic>)
            : null,
      );
}

class UpcomingItineraryData {
  final bool hasUpcoming;
  final int totalCount;
  final UpcomingItineraryItem? featured;
  final List<UpcomingItineraryItem> items;

  UpcomingItineraryData({
    this.hasUpcoming = false,
    this.totalCount = 0,
    this.featured,
    this.items = const [],
  });

  factory UpcomingItineraryData.fromJson(Map<String, dynamic> json) =>
      UpcomingItineraryData(
        hasUpcoming: json['hasUpcoming'] == true,
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        featured: json['featured'] is Map<String, dynamic>
            ? UpcomingItineraryItem.fromJson(
                json['featured'] as Map<String, dynamic>)
            : null,
        items: (json['items'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(UpcomingItineraryItem.fromJson)
                .toList() ??
            const [],
      );
}

class UpcomingItineraryItem {
  final String? id;
  final String? title;
  final String? status;
  final String? statusLabel;
  final String? startingPlace;
  final String? startingCountry;
  final String? destinedPlace;
  final String? destinedCountry;
  final String? routeDisplay;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? dateDisplay;
  final String? thumbnailUrl;

  UpcomingItineraryItem({
    this.id,
    this.title,
    this.status,
    this.statusLabel,
    this.startingPlace,
    this.startingCountry,
    this.destinedPlace,
    this.destinedCountry,
    this.routeDisplay,
    this.startDate,
    this.endDate,
    this.dateDisplay,
    this.thumbnailUrl,
  });

  factory UpcomingItineraryItem.fromJson(Map<String, dynamic> json) =>
      UpcomingItineraryItem(
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        status: json['status']?.toString(),
        statusLabel: json['statusLabel']?.toString(),
        startingPlace: json['startingPlace']?.toString(),
        startingCountry: json['startingCountry']?.toString(),
        destinedPlace: json['destinedPlace']?.toString(),
        destinedCountry: json['destinedCountry']?.toString(),
        routeDisplay: json['routeDisplay']?.toString(),
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'].toString())
            : null,
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'].toString())
            : null,
        dateDisplay: json['dateDisplay']?.toString(),
        thumbnailUrl: json['thumbnailUrl']?.toString(),
      );
}
