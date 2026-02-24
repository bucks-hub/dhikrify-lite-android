import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';

/// Indicator showing when the app is actively listening.
///
/// Displays mic icon + "Listening..." text when active.
/// Hidden when not listening.
class MicIndicator extends StatelessWidget {
  const MicIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionProvider>(
      builder: (context, transcriptionProvider, _) {
        if (!transcriptionProvider.isListening) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mic,
                color: Colors.black,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Listening...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
