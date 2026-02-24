import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';

/// Large circular button for starting/stopping speech recognition.
///
/// States:
/// - Inactive: Black circle with white mic icon
/// - Active: White circle with black border and black mic icon (pulsing animation)
/// - Disabled: When permission is denied
class RecordingButton extends StatefulWidget {
  const RecordingButton({super.key});

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionProvider>(
      builder: (context, transcriptionProvider, _) {
        final isListening = transcriptionProvider.isListening;
        final permissionGranted = transcriptionProvider.permissionGranted;

        return GestureDetector(
          onTap: permissionGranted
              ? () => transcriptionProvider.toggleListening()
              : () => _showPermissionDialog(context, transcriptionProvider),
          child: isListening
              ? ScaleTransition(
                  scale: _pulseAnimation,
                  child: _buildButton(isListening),
                )
              : _buildButton(isListening),
        );
      },
    );
  }

  Widget _buildButton(bool isListening) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening ? Colors.white : Colors.black,
        border: isListening ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Icon(
        Icons.mic,
        color: isListening ? Colors.black : Colors.white,
        size: 40,
      ),
    );
  }

  void _showPermissionDialog(
    BuildContext context,
    TranscriptionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Dhikrify needs microphone access to transcribe your Zikr recitations. Please enable microphone permission in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
