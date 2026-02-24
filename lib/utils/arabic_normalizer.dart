/// Utility class for normalizing Arabic text to improve matching accuracy.
///
/// This normalizer removes diacritics, normalizes Alef variations,
/// and normalizes Ta Marbuta to improve phrase matching.
class ArabicNormalizer {
  /// Normalizes Arabic text by:
  /// - Removing diacritics (Tashkeel): Unicode range U+064B to U+065F
  /// - Normalizing Alef variations: إأآا → ا
  /// - Normalizing Ta Marbuta: ة → ه
  /// - Removing extra whitespace and trimming
  static String normalize(String text) {
    if (text.isEmpty) return text;

    String normalized = text;

    // Remove diacritics (Tashkeel) - Unicode range U+064B to U+065F
    // This includes: Fatha, Damma, Kasra, Shadda, Sukun, etc.
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    // Normalize Alef variations to plain Alef
    // إ (U+0625), أ (U+0623), آ (U+0622) → ا (U+0627)
    normalized = normalized.replaceAll(RegExp(r'[إأآ]'), 'ا');

    // Normalize Ta Marbuta (ة) to Ha (ه)
    normalized = normalized.replaceAll('ة', 'ه');

    // Remove extra whitespace and trim
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  /// Checks if the normalized haystack contains the normalized needle.
  ///
  /// Both strings are normalized before comparison.
  static bool matches(String haystack, String needle) {
    if (haystack.isEmpty || needle.isEmpty) return false;

    final normalizedHaystack = normalize(haystack);
    final normalizedNeedle = normalize(needle);

    return normalizedHaystack.contains(normalizedNeedle);
  }

  /// Counts how many times the normalized needle appears in the normalized haystack.
  ///
  /// This is useful for detecting multiple occurrences in a single transcription.
  static int countMatches(String haystack, String needle) {
    if (haystack.isEmpty || needle.isEmpty) return 0;

    final normalizedHaystack = normalize(haystack);
    final normalizedNeedle = normalize(needle);

    if (normalizedNeedle.isEmpty) return 0;

    int count = 0;
    int index = 0;

    while (index < normalizedHaystack.length) {
      int foundIndex = normalizedHaystack.indexOf(normalizedNeedle, index);
      if (foundIndex == -1) break;
      count++;
      index = foundIndex + normalizedNeedle.length;
    }

    return count;
  }
}
