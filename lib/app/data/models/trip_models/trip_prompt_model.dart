class TripPrompt {
  final String id;
  final String? key;
  final String text;
  final String? status;

  const TripPrompt({
    required this.id,
    this.key,
    required this.text,
    this.status,
  });

  bool get isPending => status == null || status == 'PENDING';

  factory TripPrompt.fromJson(Map<String, dynamic> json) => TripPrompt(
        id: json['id']?.toString() ?? '',
        key: json['key'],
        text: json['text'] ?? '',
        status: json['status'],
      );
}

/// `GET /trips/{id}/prompts/current-batch` — questions for the current part of
/// the user's local day (MORNING / AFTERNOON / EVENING).
class PromptBatchResponse {
  final bool? success;
  final String? message;
  final String? phase;
  final String? localDate;
  final bool isAnswered;
  final bool shouldShowPopup;
  final List<TripPrompt> prompts;

  PromptBatchResponse({
    this.success,
    this.message,
    this.phase,
    this.localDate,
    this.isAnswered = false,
    this.shouldShowPopup = false,
    this.prompts = const [],
  });

  List<TripPrompt> get pendingPrompts =>
      prompts.where((p) => p.isPending && p.id.isNotEmpty).toList();

  factory PromptBatchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return PromptBatchResponse(
      success: json['success'],
      message: json['message'],
      phase: data['phase'],
      localDate: data['local_date'],
      isAnswered: data['is_answered'] == true,
      shouldShowPopup: data['should_show_popup'] == true,
      prompts: (data['prompts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TripPrompt.fromJson)
          .toList(),
    );
  }
}

/// `POST /trips/{id}/prompts/batch/answer`
class PromptAnswerResponse {
  final bool? success;
  final String? message;

  PromptAnswerResponse({this.success, this.message});

  factory PromptAnswerResponse.fromJson(Map<String, dynamic> json) =>
      PromptAnswerResponse(success: json['success'], message: json['message']);
}
