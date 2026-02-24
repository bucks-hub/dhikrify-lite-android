import 'package:flutter/foundation.dart';
import '../models/zikr_phrase.dart';
import '../services/storage_service.dart';

/// Provider for managing Zikr phrases state.
///
/// This provider wraps StorageService and provides ChangeNotifier
/// functionality to update the UI when phrases change.
class PhraseProvider extends ChangeNotifier {
  /// Returns all Zikr phrases from storage, sorted by most recently detected first.
  List<ZikrPhrase> get phrases {
    final allPhrases = StorageService.getAllPhrases();
    // Sort by lastUpdatedAt in descending order (most recent first)
    allPhrases.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    return allPhrases;
  }

  /// Returns only active Zikr phrases, sorted by most recently detected first.
  List<ZikrPhrase> get activePhrases {
    final active = StorageService.getActivePhrases();
    // Sort by lastUpdatedAt in descending order (most recent first)
    active.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    return active;
  }

  /// Adds a new Zikr phrase.
  Future<void> addPhrase(ZikrPhrase phrase) async {
    await StorageService.addPhrase(phrase);
    notifyListeners();
  }

  /// Updates an existing Zikr phrase.
  Future<void> updatePhrase(ZikrPhrase phrase) async {
    await StorageService.updatePhrase(phrase);
    notifyListeners();
  }

  /// Deletes a Zikr phrase (only non-default phrases can be deleted).
  ///
  /// Returns true if deletion succeeded, false if phrase is default.
  Future<bool> deletePhrase(String id) async {
    final result = await StorageService.deletePhrase(id);
    if (result) {
      notifyListeners();
    }
    return result;
  }

  /// Toggles the active state of a phrase.
  Future<void> togglePhraseActive(ZikrPhrase phrase) async {
    phrase.isActive = !phrase.isActive;
    await StorageService.updatePhrase(phrase);
    notifyListeners();
  }

  /// Resets session counts for all phrases.
  Future<void> resetSessionCounts() async {
    await StorageService.resetAllSessionCounts();
    notifyListeners();
  }

  /// Resets both session and total counts for all phrases.
  Future<void> resetAllCounts() async {
    await StorageService.resetAllTotalCounts();
    notifyListeners();
  }

  /// Gets a specific phrase by ID.
  ZikrPhrase? getPhraseById(String id) {
    return StorageService.getPhraseById(id);
  }

  /// Refreshes the provider to trigger UI updates.
  ///
  /// This can be called after external changes to phrases.
  void refresh() {
    notifyListeners();
  }
}
