import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zikr_phrase.dart';
import '../providers/phrase_provider.dart';
import '../screens/add_edit_phrase_screen.dart';

/// Widget displaying a single Zikr phrase with counts and active toggle.
///
/// Features:
/// - Large Arabic text (RTL)
/// - Small transliteration (LTR)
/// - Session and total counts
/// - Active/inactive toggle switch
/// - Tap to edit (non-default phrases only)
/// - Long press to delete (non-default phrases only)
class ZikrPhraseTile extends StatelessWidget {
  final ZikrPhrase phrase;

  const ZikrPhraseTile({
    super.key,
    required this.phrase,
  });

  @override
  Widget build(BuildContext context) {
    final phraseProvider = Provider.of<PhraseProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: phrase.isDefault
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditPhraseScreen(phrase: phrase),
                  ),
                );
              },
        onLongPress: phrase.isDefault
            ? null
            : () => _showDeleteDialog(context, phraseProvider),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arabic text (RTL)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  phrase.arabicText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Transliteration (LTR)
              if (phrase.transliteration.isNotEmpty)
                Text(
                  phrase.transliteration,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),

              // Counts and toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Counts
                  Expanded(
                    child: Text(
                      'Session: ${phrase.sessionCount} | Total: ${phrase.totalCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Delete button (for custom phrases only)
                  if (!phrase.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _showDeleteDialog(context, phraseProvider),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  // Active/Inactive toggle
                  Switch(
                    value: phrase.isActive,
                    onChanged: (value) {
                      phraseProvider.togglePhraseActive(phrase);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows confirmation dialog before deleting the phrase
  void _showDeleteDialog(BuildContext context, PhraseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Phrase?'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'Are you sure you want to delete "${phrase.arabicText}"?\n\nThis action cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deletePhrase(phrase.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phrase deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
