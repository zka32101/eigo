import 'package:json_annotation/json_annotation.dart';

part 'song_generator_model.g.dart';

/// 童謡メロディのテンプレート
enum TraditionalMelody {
  twinkleTwinkleLittleStar(
    '🌟 きらきら星',
    'Twinkle Twinkle Little Star',
    'A simple lullaby melody',
    '英語学習者向け',
  ),
  maryHadALittleLamb(
    '🐑 メリーさんのひつじ',
    "Mary Had a Little Lamb",
    'Classic nursery rhyme melody',
    '基礎英語',
  ),
  baaBlackSheep(
    '🐑 バア黒い羊',
    'Baa Baa Black Sheep',
    'Traditional counting melody',
    '数字学習',
  ),
  oldMacdonald(
    '🚜 昔のマクドナルド',
    "Old MacDonald Had a Farm",
    'Farm animals melody',
    '動物学習',
  ),
  twinkleVariation(
    '⭐ きらきら星・応用',
    'Twinkle Twinkle - Extended',
    'Extended version with more lyrics',
    '発展学習',
  );

  final String displayName;
  final String englishName;
  final String description;
  final String targetLevel;

  const TraditionalMelody(
    this.displayName,
    this.englishName,
    this.description,
    this.targetLevel,
  );
}

/// 歌生成リクエスト
@JsonSerializable()
class SongGenerationRequest {
  /// リクエストID
  final String requestId;

  /// ユーザーID
  final String userId;

  /// 学習対象ボキャブラリー
  final List<String> vocabularyWords;

  /// 選択されたメロディ
  final String melodyType;

  /// テーマ
  final String theme; // "animals", "food", "colors", "daily_life", "nature"

  /// 学習レベル
  final String learningLevel; // "beginner", "intermediate", "advanced"

  /// 歌詞の言語（主に英語）
  final String lyricLanguage;

  /// リクエスト作成日時
  final DateTime createdAt;

  SongGenerationRequest({
    required this.requestId,
    required this.userId,
    required this.vocabularyWords,
    required this.melodyType,
    required this.theme,
    required this.learningLevel,
    required this.lyricLanguage,
    required this.createdAt,
  });

  factory SongGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$SongGenerationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SongGenerationRequestToJson(this);
}

/// 生成された替え歌
@JsonSerializable()
class GeneratedSong {
  /// 歌ID
  final String songId;

  /// ユーザーID
  final String userId;

  /// 対応するリクエストID
  final String requestId;

  /// メロディタイプ
  final String melodyType;

  /// 生成された歌詞（英語）
  final String englishLyrics;

  /// 日本語訳
  final String japaneseTranslation;

  /// メロディの歌詞セクション
  final List<String> lyricSections;

  /// 音声URL（TTS生成後）
  final String? audioUrl;

  /// BPM（テンポ）
  final int bpm;

  /// 調（キー）
  final String musicalKey; // "C", "G", "D", "A" etc.

  /// 推奨学習年齢
  final String ageGroup; // "6-7", "7-8", "8-9", "9-10", "10-11", "11-12"

  /// 学習効果スコア（0.0-1.0）
  final double learningEffectiveness;

  /// 親への訴求力スコア（0.0-1.0）
  final double parentalAppeal;

  /// 生成日時
  final DateTime generatedAt;

  /// 再生回数
  final int playCount;

  /// ユーザー評価（1-5）
  final int? userRating;

  /// 共有状態
  final bool shared;

  /// 共有日時
  final DateTime? sharedAt;

  GeneratedSong({
    required this.songId,
    required this.userId,
    required this.requestId,
    required this.melodyType,
    required this.englishLyrics,
    required this.japaneseTranslation,
    required this.lyricSections,
    this.audioUrl,
    required this.bpm,
    required this.musicalKey,
    required this.ageGroup,
    required this.learningEffectiveness,
    required this.parentalAppeal,
    required this.generatedAt,
    required this.playCount,
    this.userRating,
    required this.shared,
    this.sharedAt,
  });

  factory GeneratedSong.fromJson(Map<String, dynamic> json) =>
      _$GeneratedSongFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedSongToJson(this);
}

/// ユーザーの歌ライブラリ
@JsonSerializable()
class SongLibrary {
  /// ライブラリID
  final String libraryId;

  /// ユーザーID
  final String userId;

  /// 保存された歌のID一覧
  final List<String> savedSongIds;

  /// お気に入りの歌のID一覧
  final List<String> favoriteSongIds;

  /// 再生履歴（最近再生順）
  final List<String> playHistory;

  /// 最初に生成された歌の日時
  final DateTime firstSongGeneratedAt;

  /// 最後に生成された歌の日時
  final DateTime? lastSongGeneratedAt;

  /// 総生成歌数
  final int totalSongsGenerated;

  /// 総再生時間（秒）
  final int totalPlayTime;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  SongLibrary({
    required this.libraryId,
    required this.userId,
    required this.savedSongIds,
    required this.favoriteSongIds,
    required this.playHistory,
    required this.firstSongGeneratedAt,
    this.lastSongGeneratedAt,
    required this.totalSongsGenerated,
    required this.totalPlayTime,
    required this.lastUpdatedAt,
  });

  factory SongLibrary.fromJson(Map<String, dynamic> json) =>
      _$SongLibraryFromJson(json);

  Map<String, dynamic> toJson() => _$SongLibraryToJson(this);
}

/// 歌詞のメトリクス・分析
@JsonSerializable()
class SongMetrics {
  /// メトリクスID
  final String metricsId;

  /// 歌ID
  final String songId;

  /// ユーザーID
  final String userId;

  /// 難易度スコア（0.0-1.0）
  final double difficultyScore;

  /// ボキャブラリーカバレッジ（含まれた学習語彙の割合）
  final double vocabularyCoverage;

  /// 音韻多様性スコア（発音練習効果）
  final double phoneticDiversity;

  /// 文法複雑性（文構造の複雑さ）
  final double grammaticalComplexity;

  /// 文化的関連性スコア
  final double culturalRelevance;

  /// 推定学習定着率（0.0-1.0）
  final double estimatedRetention;

  /// ストレス（強勢）パターン一致度
  final double stressPatternMatch;

  /// 記憶付与スコア（歌による記憶補強効果）
  final double mnemonicPower;

  /// 計測日時
  final DateTime measuredAt;

  SongMetrics({
    required this.metricsId,
    required this.songId,
    required this.userId,
    required this.difficultyScore,
    required this.vocabularyCoverage,
    required this.phoneticDiversity,
    required this.grammaticalComplexity,
    required this.culturalRelevance,
    required this.estimatedRetention,
    required this.stressPatternMatch,
    required this.mnemonicPower,
    required this.measuredAt,
  });

  factory SongMetrics.fromJson(Map<String, dynamic> json) =>
      _$SongMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SongMetricsToJson(this);
}

/// 歌学習進捗
@JsonSerializable()
class SongLearningProgress {
  /// 進捗ID
  final String progressId;

  /// ユーザーID
  final String userId;

  /// 歌ID
  final String songId;

  /// 総再生回数
  final int totalPlays;

  /// 完全リスニング回数（最後まで聞いた回数）
  final int completeListenings;

  /// シング練習実施回数
  final int singPracticeCount;

  /// 平均歌唱スコア（0-100）
  final int averageSingScore;

  /// 発音改善度（初回 vs 現在）
  final double pronunciationImprovement;

  /// 歌詞理解度（0.0-1.0）
  final double lyricComprehension;

  /// 最後に再生した日時
  final DateTime? lastPlayedAt;

  /// 最初に再生した日時
  final DateTime? firstPlayedAt;

  /// 学習完了フラグ
  final bool isLearned;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  SongLearningProgress({
    required this.progressId,
    required this.userId,
    required this.songId,
    required this.totalPlays,
    required this.completeListenings,
    required this.singPracticeCount,
    required this.averageSingScore,
    required this.pronunciationImprovement,
    required this.lyricComprehension,
    this.lastPlayedAt,
    this.firstPlayedAt,
    required this.isLearned,
    required this.lastUpdatedAt,
  });

  factory SongLearningProgress.fromJson(Map<String, dynamic> json) =>
      _$SongLearningProgressFromJson(json);

  Map<String, dynamic> toJson() => _$SongLearningProgressToJson(this);
}

/// 歌生成統計
@JsonSerializable()
class SongGenerationStats {
  /// 統計ID
  final String statsId;

  /// ユーザーID
  final String userId;

  /// 総生成歌数
  final int totalSongsGenerated;

  /// 平均生成品質スコア（0.0-1.0）
  final double averageQualityScore;

  /// 最も使用されたメロディ
  final String mostUsedMelody;

  /// 最も使用されたテーマ
  final String mostUsedTheme;

  /// 総ボキャブラリー学習語数
  final int totalVocabularyLearned;

  /// 総歌唱練習時間（秒）
  final int totalSingPracticeTime;

  /// 平均曲の長さ（秒）
  final int averageSongDuration;

  /// 推定学習効果（0.0-1.0）
  final double estimatedLearningEffectiveness;

  /// 最初の歌生成日時
  final DateTime? firstGenerationAt;

  /// 最後の歌生成日時
  final DateTime? lastGenerationAt;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  SongGenerationStats({
    required this.statsId,
    required this.userId,
    required this.totalSongsGenerated,
    required this.averageQualityScore,
    required this.mostUsedMelody,
    required this.mostUsedTheme,
    required this.totalVocabularyLearned,
    required this.totalSingPracticeTime,
    required this.averageSongDuration,
    required this.estimatedLearningEffectiveness,
    this.firstGenerationAt,
    this.lastGenerationAt,
    required this.lastUpdatedAt,
  });

  factory SongGenerationStats.fromJson(Map<String, dynamic> json) =>
      _$SongGenerationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SongGenerationStatsToJson(this);
}
