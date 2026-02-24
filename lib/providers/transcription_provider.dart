import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../services/transcription_service.dart';
import '../services/native_transcription_service.dart';
import '../services/zikr_matching_service.dart';
import 'phrase_provider.dart';

/// Provider for managing speech transcription state.
///
/// This provider:
/// - Coordinates TranscriptionService and ZikrMatchingService
/// - Manages microphone permission
/// - Provides listening state to UI
/// - Updates PhraseProvider when matches are detected
class TranscriptionProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Use native transcription service for true continuous recording
  final NativeTranscriptionService _nativeService = NativeTranscriptionService();
  final ZikrMatchingService _matchingService = ZikrMatchingService();
  final PhraseProvider _phraseProvider;

  bool _isListening = false;
  bool _isInitialized = false;
  bool _permissionGranted = false;
  String _lastTranscription = '';

  TranscriptionProvider(this._phraseProvider) {
    _setupCallbacks();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission when app resumes (e.g., returning from Settings)
      _checkPermissionStatus();
    }
  }

  /// Checks the current permission status without requesting
  Future<void> _checkPermissionStatus() async {
    final status = await Permission.microphone.status;
    final wasGranted = _permissionGranted;
    _permissionGranted = status.isGranted;

    if (_permissionGranted != wasGranted) {
      notifyListeners();
    }
  }

  /// Whether currently listening
  bool get isListening => _isListening;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether microphone permission is granted
  bool get permissionGranted => _permissionGranted;

  /// Last received transcription
  String get lastTranscription => _lastTranscription;

  /// Sets up callbacks for transcription service
  void _setupCallbacks() {
    _nativeService.onTranscription = _handleTranscription;
    _nativeService.onListeningStateChanged = (listening) {
      _isListening = listening;
      notifyListeners();
    };

    _matchingService.onMatch = (phrase, count) {
      print('Match detected: ${phrase.arabicText} x$count');
      // Immediately notify UI to update counts in real-time
      _phraseProvider.refresh();
      notifyListeners();
    };
  }

  /// Initializes the transcription service and requests permissions.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    _permissionGranted = status.isGranted;

    if (!_permissionGranted) {
      notifyListeners();
      return false;
    }

    // Request notification permission for foreground service
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Initialize foreground task
    _initializeForegroundTask();

    // Initialize native speech recognition
    _isInitialized = await _nativeService.initialize();
    notifyListeners();

    return _isInitialized;
  }

  /// Initializes the foreground task configuration
  void _initializeForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'dhikrify_notification_channel',
        channelName: 'Dhikrify Listening',
        channelDescription: 'This notification appears when Dhikrify is listening for Zikr phrases.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Starts listening for speech.
  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    // Enable wakelock to keep device awake
    await WakelockPlus.enable();

    // Start foreground service
    await _startForegroundService();

    // Start native speech recognition
    await _nativeService.startListening();
  }

  /// Stops listening for speech.
  Future<void> stopListening() async {
    // Stop native speech recognition
    await _nativeService.stopListening();

    // Stop foreground service
    await FlutterForegroundTask.stopService();

    // Disable wakelock
    await WakelockPlus.disable();
  }

  /// Starts the foreground service
  Future<void> _startForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Dhikrify is Listening',
      notificationText: 'Counting your Zikr phrases...',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'stop', text: 'Stop'),
      ],
      callback: startCallback,
    );
  }

  /// Toggles listening state.
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Handles transcription results from the service.
  void _handleTranscription(String transcription) {
    _lastTranscription = transcription;
    print('Transcription received: $transcription');

    // Process the transcription for Zikr matches
    final matches = _matchingService.processTranscription(transcription);

    if (matches.isNotEmpty) {
      print('Matches found: $matches');
    }

    notifyListeners();
  }

  /// Opens app settings for permission management.
  Future<void> openSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nativeService.dispose();
    WakelockPlus.disable();
    FlutterForegroundTask.stopService();
    super.dispose();
  }
}

/// Callback function for foreground service
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(DhikrifyTaskHandler());
}

/// Task handler for foreground service
class DhikrifyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Foreground task started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called periodically - we don't need to do anything here
    // as the speech recognition runs independently
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Foreground task destroyed');
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    // Bring app to foreground
    FlutterForegroundTask.launchApp('/');
  }
}
