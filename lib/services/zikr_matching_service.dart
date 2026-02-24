import '../models/zikr_phrase.dart';
import '../utils/arabic_normalizer.dart';
import 'storage_service.dart';

/// Service for matching transcribed text against Zikr phrases.
///
/// This service:
/// - Receives transcribed text from TranscriptionService
/// - Normalizes the transcription using ArabicNormalizer
/// - Matches against active Zikr phrases
/// - Increments counts for detected phrases
/// - Handles multiple occurrences in single transcription
/// - Prevents duplicate counting with smart phrase-level tracking
class ZikrMatchingService {
  /// Callback for when a match is detected
  Function(ZikrPhrase, int)? onMatch;

  /// Track last detection time for each phrase to avoid over-counting from partials
  final Map<String, DateTime> _lastPhraseDetection = {};

  /// Track the last transcription text to detect when it's truly new
  String _lastTranscriptionText = '';

  /// Processes transcribed text and matches against active phrases.
  ///
  /// Returns a map of matched phrase IDs to their occurrence counts.
  Map<String, int> processTranscription(String transcription) {
    if (transcription.isEmpty) return {};

    final normalized = ArabicNormalizer.normalize(transcription);
    final now = DateTime.now();

    // If this is the exact same text as before, skip it completely
    if (normalized == _lastTranscriptionText) {
      return {};
    }

    _lastTranscriptionText = normalized;
    final Map<String, int> matches = {};
    final activePhrases = StorageService.getActivePhrases();

    for (final phrase in activePhrases) {
      // Count all occurrences in this transcription
      final count = ArabicNormalizer.countMatches(
        transcription,
        phrase.arabicText,
      );

      if (count > 0) {
        // Only count if we haven't detected this phrase in the last 300ms
        // This prevents duplicate counting of the same transcription
        // but allows counting rapid successive utterances
        final lastDetection = _lastPhraseDetection[phrase.id];
        if (lastDetection == null || now.difference(lastDetection).inMilliseconds > 300) {
          matches[phrase.id] = count;
          phrase.incrementCount(count);
          onMatch?.call(phrase, count);
          _lastPhraseDetection[phrase.id] = now;
          print('Detected "${phrase.arabicText}" x$count');
        }
      }
    }

    return matches;
  }

  /// Checks if a specific phrase is contained in the transcription.
  bool containsPhrase(String transcription, ZikrPhrase phrase) {
    return ArabicNormalizer.matches(transcription, phrase.arabicText);
  }
}
