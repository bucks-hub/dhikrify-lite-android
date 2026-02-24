import 'package:hive/hive.dart';
import '../utils/arabic_normalizer.dart';

part 'zikr_phrase.g.dart';

/// Model representing a Zikr phrase with count tracking.
///
/// This model is persisted using Hive and includes fields for:
/// - Arabic text and transliteration
/// - Total count (persists across sessions)
/// - Session count (reset when user chooses)
/// - Active/inactive state
/// - Default phrase flag (prevents deletion)
@HiveType(typeId: 0)
class ZikrPhrase extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String arabicText;

  @HiveField(2)
  String transliteration;

  @HiveField(3)
  int totalCount;

  @HiveField(4)
  int sessionCount;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  bool isDefault;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime lastUpdatedAt;

  ZikrPhrase({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    this.totalCount = 0,
    this.sessionCount = 0,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  /// Returns normalized version of the Arabic text for matching purposes.
  String get normalizedArabic => ArabicNormalizer.normalize(arabicText);

  /// Increments both session and total counts.
  ///
  /// This method should be called when the phrase is detected in transcription.
  void incrementCount([int amount = 1]) {
    sessionCount += amount;
    totalCount += amount;
    lastUpdatedAt = DateTime.now();
    save();
  }

  /// Resets only the session count to zero.
  void resetSessionCount() {
    sessionCount = 0;
    lastUpdatedAt = DateTime.now();
    save();
  }

  /// Resets both session and total counts to zero.
  void resetAllCounts() {
    sessionCount = 0;
    totalCount = 0;
    lastUpdatedAt = DateTime.now();
    save();
  }

  /// Creates a copy of this phrase with updated fields.
  ZikrPhrase copyWith({
    String? id,
    String? arabicText,
    String? transliteration,
    int? totalCount,
    int? sessionCount,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return ZikrPhrase(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      totalCount: totalCount ?? this.totalCount,
      sessionCount: sessionCount ?? this.sessionCount,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
