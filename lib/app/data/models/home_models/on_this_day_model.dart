class OnThisDayResponse {
  final bool? success;
  final String? message;
  final OnThisDayData? data;

  OnThisDayResponse({this.success, this.message, this.data});

  factory OnThisDayResponse.fromJson(Map<String, dynamic> json) =>
      OnThisDayResponse(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? OnThisDayData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class OnThisDayData {
  final bool hasMemory;
  final DateTime? date;
  final String? formattedDate;
  final int? yearsAgo;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? placeName;
  final OnThisDayTrip? trip;
  final OnThisDayMemory? memory;

  OnThisDayData({
    this.hasMemory = false,
    this.date,
    this.formattedDate,
    this.yearsAgo,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.placeName,
    this.trip,
    this.memory,
  });

  factory OnThisDayData.fromJson(Map<String, dynamic> json) => OnThisDayData(
        hasMemory: json['hasMemory'] == true,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString())
            : null,
        formattedDate: json['formattedDate']?.toString(),
        yearsAgo: (json['yearsAgo'] as num?)?.toInt(),
        title: json['title']?.toString(),
        subtitle: json['subtitle']?.toString(),
        imageUrl: json['imageUrl']?.toString(),
        placeName: json['placeName']?.toString(),
        trip: json['trip'] is Map<String, dynamic>
            ? OnThisDayTrip.fromJson(json['trip'] as Map<String, dynamic>)
            : null,
        memory: json['memory'] is Map<String, dynamic>
            ? OnThisDayMemory.fromJson(json['memory'] as Map<String, dynamic>)
            : null,
      );
}

class OnThisDayTrip {
  final String? id;
  final String? title;
  final String? destinedPlace;
  final String? startingPlace;

  OnThisDayTrip({
    this.id,
    this.title,
    this.destinedPlace,
    this.startingPlace,
  });

  factory OnThisDayTrip.fromJson(Map<String, dynamic> json) => OnThisDayTrip(
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        destinedPlace: json['destinedPlace']?.toString(),
        startingPlace: json['startingPlace']?.toString(),
      );
}

class OnThisDayMemory {
  final String? id;
  final String? text;
  final String? emotion;
  final String? taste;

  OnThisDayMemory({
    this.id,
    this.text,
    this.emotion,
    this.taste,
  });

  factory OnThisDayMemory.fromJson(Map<String, dynamic> json) =>
      OnThisDayMemory(
        id: json['id']?.toString(),
        text: json['text']?.toString(),
        emotion: json['emotion']?.toString(),
        taste: json['taste']?.toString(),
      );
}
