import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/constants.dart';

/// Service for continuous Arabic speech recognition.
///
/// This service:
/// - Configures speech-to-text for Arabic (ar-SA locale)
/// - Maintains continuous listening with minimal gaps
/// - Uses ultra-fast restart to keep mic active
/// - Processes transcription results in real-time
/// - Never saves audio to disk
class TranscriptionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  Timer? _autoRestartTimer;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _hasRecentError = false;

  /// Callback for when transcription is received (final results only)
  Function(String)? onTranscription;

  /// Callback for when listening state changes
  Function(bool)? onListeningStateChanged;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether currently listening
  bool get isListening => _isListening;

  /// Initializes the speech recognition service.
  ///
  /// Returns true if initialization succeeded, false otherwise.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      return _isInitialized;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Starts continuous listening for Arabic speech.
  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) return;

    _isListening = true;
    _notifyListeningStateChanged();
    _startListeningInternal();
  }

  /// Internal method to start speech recognition.
  void _startListeningInternal() {
    // Don't start if already listening
    if (_speech.isListening) {
      print('Speech recognition already active, skipping start');
      return;
    }

    _speech.listen(
      onResult: _onResult,
      localeId: AppConstants.arabicLocale,
      pauseFor: const Duration(milliseconds: 800), // Short pause for better responsiveness
      listenFor: const Duration(hours: 24), // Listen for 24 hours continuously
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true, // Process partial results for continuous detection
        cancelOnError: false,
        onDevice: false, // Use cloud recognition for better accuracy
        autoPunctuation: false, // Disable to improve performance
        enableHapticFeedback: false, // Disable haptics
      ),
    );
  }


  /// Stops listening for speech.
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _autoRestartTimer?.cancel();
    await _speech.stop();
    _notifyListeningStateChanged();
  }

  /// Called when speech recognition result is received.
  void _onResult(dynamic result) {
    if (result.recognizedWords.isEmpty) return;

    // Process final results always, and partial results if they're long enough
    if (result.finalResult) {
      print('Final transcription: ${result.recognizedWords}');
      onTranscription?.call(result.recognizedWords);
    } else if (result.recognizedWords.split(' ').length >= 2) {
      // Process partial results that have at least 2 words
      print('Partial transcription: ${result.recognizedWords}');
      onTranscription?.call(result.recognizedWords);
    }
  }

  /// Called when speech recognition status changes.
  void _onStatus(String status) {
    print('Speech recognition status: $status');

    // Only restart if we're supposed to be listening but the engine stopped
    // Don't restart if we just had an error
    if (status == 'done' && _isListening && !_hasRecentError) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isListening && !_speech.isListening && !_hasRecentError) {
          print('Session ended, restarting...');
          _startListeningInternal();
        }
      });
    }

    // Clear error flag after a delay
    if (status == 'listening') {
      _hasRecentError = false;
    }
  }

  /// Called when speech recognition error occurs.
  void _onError(dynamic error) {
    print('Speech recognition error: $error');

    final errorMsg = error.toString();

    // Mark that we had an error to prevent immediate restart loops
    if (errorMsg.contains('error_busy') || errorMsg.contains('permanent: true')) {
      _hasRecentError = true;

      // For busy errors, wait longer before trying again
      if (errorMsg.contains('error_busy')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_isListening && !_speech.isListening) {
            _hasRecentError = false;
            print('Retrying after busy error...');
            _startListeningInternal();
          }
        });
      }
      return;
    }

    // For transient errors, try to restart
    _hasRecentError = true;
    if (_isListening && !_speech.isListening) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isListening && !_speech.isListening) {
          _hasRecentError = false;
          print('Restarting after error...');
          _startListeningInternal();
        }
      });
    }
  }

  /// Notifies listening state change callback.
  void _notifyListeningStateChanged() {
    onListeningStateChanged?.call(_isListening);
  }

  /// Cleans up resources.
  void dispose() {
    _autoRestartTimer?.cancel();
    _speech.stop();
  }
}
