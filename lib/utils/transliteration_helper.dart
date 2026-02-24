import 'arabic_normalizer.dart';

/// Helper class for suggesting transliterations for Arabic text.
///
/// This provides auto-suggestions based on common Arabic phrases
/// and character mappings.
class TransliterationHelper {
  /// Common Arabic to transliteration mappings
  static const Map<String, String> _commonPhrases = {
    'سبحان الله': 'SubhanAllah',
    'الحمد لله': 'Alhamdulillah',
    'الله أكبر': 'Allahu Akbar',
    'لا إله إلا الله': 'La ilaha illallah',
    'أستغفر الله': 'Astaghfirullah',
    'لا حول ولا قوة إلا بالله': 'La hawla wa la quwwata illa billah',
    'بسم الله': 'Bismillah',
    'بسم الله الرحمن الرحيم': 'Bismillah ar-Rahman ar-Rahim',
    'ما شاء الله': 'MashaAllah',
    'إن شاء الله': 'InshaAllah',
    'جزاك الله خيرا': 'JazakAllahu Khayran',
    'السلام عليكم': 'Assalamu Alaikum',
    'وعليكم السلام': 'Wa Alaikum Assalam',
    'يا الله': 'Ya Allah',
    'استغفر الله العظيم': 'Astaghfirullah al-Azeem',
    'لا إله إلا الله محمد رسول الله': 'La ilaha illallah Muhammad Rasulullah',
    'الله': 'Allah',
    'سبحانك': 'Subhanak',
    'تبارك الله': 'Tabarakallah',
    'اللهم صل على محمد': 'Allahumma salli ala Muhammad',
  };

  /// Basic character mapping for simple transliteration
  static const Map<String, String> _characterMap = {
    'ا': 'a',
    'أ': 'a',
    'إ': 'i',
    'آ': 'aa',
    'ب': 'b',
    'ت': 't',
    'ث': 'th',
    'ج': 'j',
    'ح': 'h',
    'خ': 'kh',
    'د': 'd',
    'ذ': 'dh',
    'ر': 'r',
    'ز': 'z',
    'س': 's',
    'ش': 'sh',
    'ص': 's',
    'ض': 'd',
    'ط': 't',
    'ظ': 'dh',
    'ع': 'a',
    'غ': 'gh',
    'ف': 'f',
    'ق': 'q',
    'ك': 'k',
    'ل': 'l',
    'م': 'm',
    'ن': 'n',
    'ه': 'h',
    'ة': 'h',
    'و': 'w',
    'ي': 'y',
    'ى': 'a',
    ' ': ' ',
  };

  /// Suggests transliteration for given Arabic text.
  ///
  /// First checks for exact matches in common phrases,
  /// then falls back to character-by-character transliteration.
  static String suggest(String arabicText) {
    if (arabicText.isEmpty) return '';

    // Normalize the input for matching
    final normalized = ArabicNormalizer.normalize(arabicText);

    // Check for exact match in common phrases
    for (final entry in _commonPhrases.entries) {
      final normalizedPhrase = ArabicNormalizer.normalize(entry.key);
      if (normalized == normalizedPhrase) {
        return entry.value;
      }
    }

    // Check for partial match (contains)
    for (final entry in _commonPhrases.entries) {
      final normalizedPhrase = ArabicNormalizer.normalize(entry.key);
      if (normalized.contains(normalizedPhrase) || normalizedPhrase.contains(normalized)) {
        return entry.value;
      }
    }

    // Fall back to character-by-character transliteration
    return _basicTransliterate(arabicText);
  }

  /// Performs basic character-by-character transliteration.
  static String _basicTransliterate(String arabicText) {
    final buffer = StringBuffer();
    final normalized = ArabicNormalizer.normalize(arabicText);

    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      buffer.write(_characterMap[char] ?? char);
    }

    // Capitalize first letter
    final result = buffer.toString().trim();
    if (result.isEmpty) return '';

    return result[0].toUpperCase() + result.substring(1);
  }

  /// Returns a list of possible transliteration suggestions.
  ///
  /// Useful for showing multiple options to the user.
  static List<String> getSuggestions(String arabicText) {
    final suggestions = <String>[];
    final primary = suggest(arabicText);

    if (primary.isNotEmpty) {
      suggestions.add(primary);
    }

    // Add variations with different capitalizations if applicable
    if (primary.length > 1) {
      // All lowercase version
      final lowercase = primary[0].toLowerCase() + primary.substring(1);
      if (lowercase != primary && !suggestions.contains(lowercase)) {
        suggestions.add(lowercase);
      }
    }

    return suggestions;
  }
}
