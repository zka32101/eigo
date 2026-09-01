import 'package:json_annotation/json_annotation.dart';

part 'camera_scan_model.g.dart';

/// Scanned vocabulary item from camera
@JsonSerializable()
class ScannedVocabulary {
  final String itemId; // Unique identifier
  final String englishWord; // English translation
  final String japaneseWord; // Japanese translation
  final String pronunciation; // IPA pronunciation
  final String category; // furniture, food, animals, etc.
  final String description; // Detailed description
  final String imagePath; // Path to captured image
  final DateTime scannedAt;
  final int useCount; // How many times reviewed

  const ScannedVocabulary({
    required this.itemId,
    required this.englishWord,
    required this.japaneseWord,
    required this.pronunciation,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.scannedAt,
    required this.useCount,
  });

  factory ScannedVocabulary.fromJson(Map<String, dynamic> json) =>
      _$ScannedVocabularyFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedVocabularyToJson(this);

  ScannedVocabulary copyWith({
    String? itemId,
    String? englishWord,
    String? japaneseWord,
    String? pronunciation,
    String? category,
    String? description,
    String? imagePath,
    DateTime? scannedAt,
    int? useCount,
  }) {
    return ScannedVocabulary(
      itemId: itemId ?? this.itemId,
      englishWord: englishWord ?? this.englishWord,
      japaneseWord: japaneseWord ?? this.japaneseWord,
      pronunciation: pronunciation ?? this.pronunciation,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      scannedAt: scannedAt ?? this.scannedAt,
      useCount: useCount ?? this.useCount,
    );
  }
}

/// Category for organizing scanned vocabulary
@JsonSerializable()
class VocabularyCategory {
  final String categoryId;
  final String categoryName;
  final String icon; // Emoji
  final int itemCount;
  final List<String> vocabularyIds; // References to ScannedVocabulary

  const VocabularyCategory({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.itemCount,
    required this.vocabularyIds,
  });

  factory VocabularyCategory.fromJson(Map<String, dynamic> json) =>
      _$VocabularyCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$VocabularyCategoryToJson(this);

  VocabularyCategory copyWith({
    String? categoryId,
    String? categoryName,
    String? icon,
    int? itemCount,
    List<String>? vocabularyIds,
  }) {
    return VocabularyCategory(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      vocabularyIds: vocabularyIds ?? this.vocabularyIds,
    );
  }
}

/// My Dictionary stats
@JsonSerializable()
class DictionaryStats {
  final int totalItems;
  final int totalScans;
  final List<String> categories; // Category IDs
  final DateTime lastScanAt;
  final int longestStreak; // Days with at least one scan
  final int currentStreak;
  final List<String> unlockedBadges; // Badge IDs

  const DictionaryStats({
    required this.totalItems,
    required this.totalScans,
    required this.categories,
    required this.lastScanAt,
    required this.longestStreak,
    required this.currentStreak,
    required this.unlockedBadges,
  });

  factory DictionaryStats.fromJson(Map<String, dynamic> json) =>
      _$DictionaryStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DictionaryStatsToJson(this);

  DictionaryStats copyWith({
    int? totalItems,
    int? totalScans,
    List<String>? categories,
    DateTime? lastScanAt,
    int? longestStreak,
    int? currentStreak,
    List<String>? unlockedBadges,
  }) {
    return DictionaryStats(
      totalItems: totalItems ?? this.totalItems,
      totalScans: totalScans ?? this.totalScans,
      categories: categories ?? this.categories,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }
}

/// AI Recognition result from Gemini
@JsonSerializable()
class AIRecognitionResult {
  final String objectName; // English object name
  final double confidence; // 0.0-1.0 confidence score
  final String japaneseTranslation;
  final String pronunciationIPA;
  final String category;
  final List<String> relatedWords; // Similar objects
  final String detailedDescription;

  const AIRecognitionResult({
    required this.objectName,
    required this.confidence,
    required this.japaneseTranslation,
    required this.pronunciationIPA,
    required this.category,
    required this.relatedWords,
    required this.detailedDescription,
  });

  factory AIRecognitionResult.fromJson(Map<String, dynamic> json) =>
      _$AIRecognitionResultFromJson(json);

  Map<String, dynamic> toJson() => _$AIRecognitionResultToJson(this);
}

/// Scan achievement/milestone
@JsonSerializable()
class ScanAchievement {
  final String achievementId;
  final String title;
  final String description;
  final String icon; // Emoji
  final int targetCount; // Items to collect for this achievement
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int coinsReward;

  const ScanAchievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetCount,
    required this.currentCount,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.coinsReward,
  });

  factory ScanAchievement.fromJson(Map<String, dynamic> json) =>
      _$ScanAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$ScanAchievementToJson(this);

  ScanAchievement copyWith({
    String? achievementId,
    String? title,
    String? description,
    String? icon,
    int? targetCount,
    int? currentCount,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? coinsReward,
  }) {
    return ScanAchievement(
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      coinsReward: coinsReward ?? this.coinsReward,
    );
  }

  /// Progress as percentage (0-100)
  double get progress => (currentCount / targetCount * 100).clamp(0, 100);
}
