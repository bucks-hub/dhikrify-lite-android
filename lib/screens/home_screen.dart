import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phrase_provider.dart';
import '../widgets/zikr_phrase_tile.dart';
import '../widgets/recording_button.dart';
import '../widgets/mic_indicator.dart';
import 'add_edit_phrase_screen.dart';
import 'stats_screen.dart';

/// Main home screen of the Dhikrify app.
///
/// Features:
/// - AppBar with title and stats navigation
/// - List of Zikr phrases
/// - Add phrase button
/// - Recording button (fixed at bottom)
/// - Mic indicator (below recording button)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikrify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Phrases list
          Expanded(
            child: Consumer<PhraseProvider>(
              builder: (context, phraseProvider, _) {
                final phrases = phraseProvider.phrases;

                if (phrases.isEmpty) {
                  return const Center(
                    child: Text(
                      'No phrases yet.\nTap "Add Phrase" to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 180, // Space for recording button and add button
                  ),
                  itemCount: phrases.length,
                  itemBuilder: (context, index) {
                    return ZikrPhraseTile(phrase: phrases[index]);
                  },
                );
              },
            ),
          ),

          // Bottom section with recording controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Add phrase button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditPhraseScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Add Phrase'),
                  ),
                ),
                const SizedBox(height: 16),

                // Recording button
                const RecordingButton(),
                const SizedBox(height: 8),

                // Mic indicator
                const MicIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
