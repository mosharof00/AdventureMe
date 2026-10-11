/// `POST /trips/{id}/story/generate` and `GET /trips/{id}/story/status`.
class StoryStatusResponse {
  final bool? success;
  final String? message;
  final String? itineraryId;

  /// READY, PROCESSING, ... FAILED
  final String? status;

  /// 0–100; missing in the generate response.
  final int? progress;
  final bool isPublished;
  final DateTime? generatedAt;

  StoryStatusResponse({
    this.success,
    this.message,
    this.itineraryId,
    this.status,
    this.progress,
    this.isPublished = false,
    this.generatedAt,
  });

  bool get isReady => status == 'READY';
  bool get isFailed => status == 'FAILED' || status == 'ERROR';

  factory StoryStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return StoryStatusResponse(
      success: json['success'],
      message: json['message'],
      itineraryId: data['itinerary_id']?.toString(),
      status: data['status']?.toString().toUpperCase(),
      progress: (data['progress'] as num?)?.toInt(),
      isPublished: data['is_published'] == true,
      generatedAt: DateTime.tryParse(data['generated_at']?.toString() ?? ''),
    );
  }
}
