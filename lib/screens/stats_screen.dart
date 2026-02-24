import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phrase_provider.dart';

/// Screen displaying statistics for all Zikr phrases.
///
/// Features:
/// - Aggregate totals (session and total counts)
/// - Per-phrase breakdown
/// - Reset session counts button
/// - Reset all counts button (with confirmation)
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PhraseProvider>(
        builder: (context, phraseProvider, _) {
          final phrases = phraseProvider.phrases;

          // Calculate aggregate totals
          int totalSessionCount = 0;
          int totalOverallCount = 0;

          for (final phrase in phrases) {
            totalSessionCount += phrase.sessionCount;
            totalOverallCount += phrase.totalCount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Aggregate totals card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Counts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Session: $totalSessionCount',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall: $totalOverallCount',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Per-phrase breakdown header
              const Text(
                'Per-Phrase Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Per-phrase list
              ...phrases.map((phrase) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            phrase.arabicText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Session: ${phrase.sessionCount} | Total: ${phrase.totalCount}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // Reset buttons
              OutlinedButton(
                onPressed: () => _resetSessionCounts(context, phraseProvider),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Reset Session Counts'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmResetAllCounts(context, phraseProvider),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Reset All Counts'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _resetSessionCounts(BuildContext context, PhraseProvider provider) async {
    await provider.resetSessionCounts();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session counts reset'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmResetAllCounts(BuildContext context, PhraseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Counts?'),
        content: const Text(
          'This will reset both session and total counts for all phrases. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllCounts(context, provider);
            },
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _resetAllCounts(BuildContext context, PhraseProvider provider) async {
    await provider.resetAllCounts();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All counts reset'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
