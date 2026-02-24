/// Application-wide constants and default values.
class AppConstants {
  /// Application name
  static const String appName = 'Dhikrify';

  /// Hive box name for storing Zikr phrases
  static const String phrasesBoxName = 'zikr_phrases';

  /// Default Zikr phrases with Arabic text and transliteration
  static const List<Map<String, String>> defaultPhrases = [
    {
      'arabic': 'سبحان الله',
      'transliteration': 'SubhanAllah',
    },
    {
      'arabic': 'الحمد لله',
      'transliteration': 'Alhamdulillah',
    },
    {
      'arabic': 'الله أكبر',
      'transliteration': 'Allahu Akbar',
    },
    {
      'arabic': 'لا إله إلا الله',
      'transliteration': 'La ilaha illallah',
    },
    {
      'arabic': 'أستغفر الله',
      'transliteration': 'Astaghfirullah',
    },
    {
      'arabic': 'لا حول ولا قوة إلا بالله',
      'transliteration': 'La hawla wa la quwwata illa billah',
    },
  ];

  /// Speech recognition locale for Arabic
  static const String arabicLocale = 'ar-SA';

  /// Auto-restart interval for continuous listening (in seconds)
  static const int autoRestartInterval = 30;

  /// Pause duration before considering speech ended (in seconds)
  static const int pauseDuration = 3;
}
