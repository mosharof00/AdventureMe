class TripMemory {
  final String? id;
  final String? tripId;
  final String? source;
  final String? text;
  final String? voiceUrl;
  final String? transcript;
  final DateTime? capturedAt;

  TripMemory({
    this.id,
    this.tripId,
    this.source,
    this.text,
    this.voiceUrl,
    this.transcript,
    this.capturedAt,
  });

  factory TripMemory.fromJson(Map<String, dynamic> json) => TripMemory(
        id: json['id']?.toString(),
        tripId: json['trip_id']?.toString(),
        source: json['source'],
        text: json['text'],
        voiceUrl: json['voice_url'],
        transcript: json['transcript'],
        capturedAt: DateTime.tryParse(json['captured_at']?.toString() ?? ''),
      );
}

/// `POST /trips/{id}/memories`
class TripMemoryResponse {
  final bool? success;
  final String? message;
  final TripMemory? data;

  TripMemoryResponse({this.success, this.message, this.data});

  factory TripMemoryResponse.fromJson(Map<String, dynamic> json) =>
      TripMemoryResponse(
        success: json['success'],
        message: json['message'],
        data: json['data'] is Map<String, dynamic>
            ? TripMemory.fromJson(json['data'])
            : null,
      );
}
