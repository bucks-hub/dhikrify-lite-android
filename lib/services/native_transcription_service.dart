import 'dart:async';
import 'package:flutter/services.dart';

/// Native platform service for continuous Arabic speech recognition.
///
/// This service uses platform channels to communicate with native
/// Android/iOS code that maintains continuous microphone access.
class NativeTranscriptionService {
  static const platform = MethodChannel('com.dhikrifylite.app/transcription');
  static const eventChannel = EventChannel('com.dhikrifylite.app/transcription_stream');

  StreamSubscription? _transcriptionSubscription;

  /// Callback for when transcription is received
  Function(String)? onTranscription;

  /// Callback for when listening state changes
  Function(bool)? onListeningStateChanged;

  bool _isListening = false;

  /// Whether currently listening
  bool get isListening => _isListening;

  /// Initializes the native transcription service.
  Future<bool> initialize() async {
    try {
      final result = await platform.invokeMethod('initialize');
      return result == true;
    } catch (e) {
      print('Error initializing native transcription: $e');
      return false;
    }
  }

  /// Starts continuous listening for Arabic speech.
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      // Start native recording
      await platform.invokeMethod('startListening', {'locale': 'ar-SA'});

      // Listen to transcription stream
      _transcriptionSubscription = eventChannel.receiveBroadcastStream().listen(
        (dynamic data) {
          if (data is String && data.isNotEmpty) {
            print('Native transcription: $data');
            onTranscription?.call(data);
          }
        },
        onError: (error) {
          print('Transcription stream error: $error');
        },
      );

      _isListening = true;
      onListeningStateChanged?.call(true);
    } catch (e) {
      print('Error starting native listening: $e');
    }
  }

  /// Stops listening for speech.
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await platform.invokeMethod('stopListening');
      await _transcriptionSubscription?.cancel();
      _transcriptionSubscription = null;

      _isListening = false;
      onListeningStateChanged?.call(false);
    } catch (e) {
      print('Error stopping native listening: $e');
    }
  }

  /// Cleans up resources.
  void dispose() {
    _transcriptionSubscription?.cancel();
    stopListening();
  }
}
