import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/zikr_phrase.dart';
import '../providers/phrase_provider.dart';
import '../utils/transliteration_helper.dart';
import '../utils/constants.dart';

/// Screen for adding a new Zikr phrase or editing an existing one.
///
/// Features:
/// - Arabic text input (RTL, required)
/// - Voice input for Arabic text
/// - Auto-suggest transliteration
/// - Transliteration input (LTR, optional)
/// - Validation
/// - Save/Cancel actions
class AddEditPhraseScreen extends StatefulWidget {
  final ZikrPhrase? phrase;

  const AddEditPhraseScreen({
    super.key,
    this.phrase,
  });

  @override
  State<AddEditPhraseScreen> createState() => _AddEditPhraseScreenState();
}

class _AddEditPhraseScreenState extends State<AddEditPhraseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _arabicController;
  late TextEditingController _transliterationController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;

  bool get isEditing => widget.phrase != null;

  @override
  void initState() {
    super.initState();
    _arabicController = TextEditingController(
      text: widget.phrase?.arabicText ?? '',
    );
    _transliterationController = TextEditingController(
      text: widget.phrase?.transliteration ?? '',
    );

    // Add listener to auto-suggest transliteration
    _arabicController.addListener(_onArabicTextChanged);
    _initializeSpeech();
  }

  /// Initialize speech recognition
  Future<void> _initializeSpeech() async {
    _speechInitialized = await _speech.initialize();
  }

  /// Called when Arabic text changes
  void _onArabicTextChanged() {
    // Auto-suggest transliteration if field is empty
    if (_transliterationController.text.isEmpty && _arabicController.text.isNotEmpty) {
      final suggestion = TransliterationHelper.suggest(_arabicController.text);
      if (suggestion.isNotEmpty) {
        _transliterationController.text = suggestion;
      }
    }
  }

  @override
  void dispose() {
    _arabicController.removeListener(_onArabicTextChanged);
    _arabicController.dispose();
    _transliterationController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Phrase' : 'Add Phrase'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Arabic text input with voice button
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                controller: _arabicController,
                decoration: InputDecoration(
                  labelText: 'Arabic Text',
                  hintText: _isListening ? 'Listening...' : 'Enter Zikr phrase in Arabic',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.black,
                    ),
                    onPressed: _toggleVoiceInput,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Amiri',
                ),
                textDirection: TextDirection.rtl,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Arabic text is required';
                  }
                  return null;
                },
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 8),

            // Show suggested transliteration hint
            if (_arabicController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: Text(
                  'Suggested: ${TransliterationHelper.suggest(_arabicController.text)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Transliteration input
            TextFormField(
              controller: _transliterationController,
              decoration: const InputDecoration(
                labelText: 'Transliteration (Optional)',
                hintText: 'Enter transliteration',
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),

                // Save button
                ElevatedButton(
                  onPressed: _savePhrase,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles voice input for Arabic text
  void _toggleVoiceInput() async {
    if (!_speechInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      // Stop listening
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // Start listening
      setState(() => _isListening = true);

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _arabicController.text = result.recognizedWords;
              _isListening = false;
            });
          }
        },
        localeId: AppConstants.arabicLocale,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: false,
        ),
      );
    }
  }

  void _savePhrase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phraseProvider = Provider.of<PhraseProvider>(context, listen: false);
    final now = DateTime.now();

    if (isEditing) {
      // Update existing phrase
      widget.phrase!.arabicText = _arabicController.text.trim();
      widget.phrase!.transliteration = _transliterationController.text.trim();
      widget.phrase!.lastUpdatedAt = now;
      await phraseProvider.updatePhrase(widget.phrase!);
    } else {
      // Create new phrase
      final newPhrase = ZikrPhrase(
        id: 'custom_${now.millisecondsSinceEpoch}',
        arabicText: _arabicController.text.trim(),
        transliteration: _transliterationController.text.trim(),
        isDefault: false,
        createdAt: now,
        lastUpdatedAt: now,
      );
      await phraseProvider.addPhrase(newPhrase);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
