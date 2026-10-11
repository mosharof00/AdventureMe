import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';

import '../../data/repositories/trip_repository.dart';
import '../../global/widgets/global_snackbar.dart';
import '../../global/widgets/trip_prompts_dialog.dart';
import '../network/handle_exceptions.dart';
import '../theme/app_color.dart';
import '../utils/logger.dart';

/// Asks the daily context questions (morning / afternoon / evening) of a trip.
/// Call [askIfPending] from any screen; it only shows the dialog when the
/// current batch is unanswered.
class TripPromptService extends GetxService {
  ITripRepository get _repository => Get.find<ITripRepository>();

  bool _checking = false;

  /// Batches already shown this session (`tripId|date|phase`), so "Later"
  /// isn't followed by the same dialog on every screen refresh.
  final _shownBatches = <String>{};

  Future<String> _timezone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      return 'UTC';
    }
  }

  /// Shows the current batch of [tripId] if it still needs answers.
  /// Returns whether answers were saved.
  Future<bool> askIfPending(String tripId) async {
    if (_checking) return false;
    _checking = true;
    try {
      final batch = await _repository.getPromptBatch(
        tripId,
        await _timezone(),
      );
      final prompts = batch.pendingPrompts;
      final key = '$tripId|${batch.localDate}|${batch.phase}';
      if (batch.success != true ||
          batch.isAnswered ||
          !batch.shouldShowPopup ||
          prompts.isEmpty ||
          _shownBatches.contains(key)) {
        return false;
      }
      _shownBatches.add(key);

      final saved = await TripPromptsDialog.show(
        tripId: tripId,
        phase: batch.phase,
        prompts: prompts,
      );
      if (saved) {
        globalSnackBar(
          title: 'Moments Saved',
          message: 'Thank you. These will make your story yours.',
          backgroundColor: AppColor.primary,
        );
      }
      return saved;
    } catch (e) {
      // A background check; failing silently is better than a popup error.
      Log.e('[Trip Prompts] $e');
      return false;
    } finally {
      _checking = false;
    }
  }

  /// Saves the filled answers; blank ones are left out and skipped.
  /// Called by [TripPromptsDialog].
  Future<bool> submit(String tripId, Map<String, String> answers) async {
    try {
      final response = await _repository.answerPromptBatch(tripId, answers);
      if (response.success != true) {
        globalSnackBar(
          title: 'Not Saved',
          message: response.message ?? 'Unable to save your answers.',
        );
        return false;
      }
      return true;
    } catch (e) {
      handleException(e, context: 'Answer Trip Prompts');
      return false;
    }
  }
}
