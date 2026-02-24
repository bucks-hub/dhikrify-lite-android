import 'package:hive_flutter/hive_flutter.dart';
import '../models/zikr_phrase.dart';
import '../utils/constants.dart';

/// Service for managing persistent storage of Zikr phrases using Hive.
///
/// This service handles:
/// - Initializing Hive database
/// - Seeding default phrases on first launch
/// - CRUD operations for Zikr phrases
/// - Bulk operations (reset counts, etc.)
class StorageService {
  static Box<ZikrPhrase>? _phrasesBox;

  /// Initializes Hive and opens the phrases box.
  ///
  /// This should be called once during app startup before runApp.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ZikrPhraseAdapter());
    _phrasesBox = await Hive.openBox<ZikrPhrase>(AppConstants.phrasesBoxName);

    // Seed default phrases if box is empty
    if (_phrasesBox!.isEmpty) {
      await _seedDefaultPhrases();
    }
  }

  /// Seeds the database with 6 default Zikr phrases.
  static Future<void> _seedDefaultPhrases() async {
    final now = DateTime.now();

    for (int i = 0; i < AppConstants.defaultPhrases.length; i++) {
      final phraseData = AppConstants.defaultPhrases[i];
      final phrase = ZikrPhrase(
        id: 'default_$i',
        arabicText: phraseData['arabic']!,
        transliteration: phraseData['transliteration']!,
        isDefault: true,
        createdAt: now,
        lastUpdatedAt: now,
      );
      await _phrasesBox!.put(phrase.id, phrase);
    }
  }

  /// Returns all Zikr phrases from the database.
  static List<ZikrPhrase> getAllPhrases() {
    return _phrasesBox!.values.toList();
  }

  /// Returns only active Zikr phrases.
  static List<ZikrPhrase> getActivePhrases() {
    return _phrasesBox!.values.where((phrase) => phrase.isActive).toList();
  }

  /// Adds a new Zikr phrase to the database.
  static Future<void> addPhrase(ZikrPhrase phrase) async {
    await _phrasesBox!.put(phrase.id, phrase);
  }

  /// Updates an existing Zikr phrase.
  static Future<void> updatePhrase(ZikrPhrase phrase) async {
    phrase.lastUpdatedAt = DateTime.now();
    await phrase.save();
  }

  /// Deletes a Zikr phrase from the database.
  ///
  /// Returns false if attempting to delete a default phrase.
  static Future<bool> deletePhrase(String id) async {
    final phrase = _phrasesBox!.get(id);
    if (phrase == null || phrase.isDefault) {
      return false;
    }
    await _phrasesBox!.delete(id);
    return true;
  }

  /// Resets session counts for all phrases.
  static Future<void> resetAllSessionCounts() async {
    for (final phrase in _phrasesBox!.values) {
      phrase.resetSessionCount();
    }
  }

  /// Resets both session and total counts for all phrases.
  static Future<void> resetAllTotalCounts() async {
    for (final phrase in _phrasesBox!.values) {
      phrase.resetAllCounts();
    }
  }

  /// Gets a specific phrase by ID.
  static ZikrPhrase? getPhraseById(String id) {
    return _phrasesBox!.get(id);
  }

  /// Closes the Hive box. Call this on app disposal if needed.
  static Future<void> dispose() async {
    await _phrasesBox?.close();
  }
}
