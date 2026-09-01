import 'package:json_annotation/json_annotation.dart';

part 'plush_toy_model.g.dart';

/// プラシシ（ぬいぐるみキャラ）の種類
enum PlushToySpecies {
  bear('🐻 ベア', 'A friendly bear who loves adventures'),
  cat('🐱 ネコ', 'A curious cat who asks questions'),
  dog('🐶 ワンコ', 'An enthusiastic dog who encourages you'),
  rabbit('🐰 ウサギ', 'A clever rabbit who shares stories'),
  panda('🐼 パンダ', 'A gentle panda who listens carefully');

  final String displayName;
  final String description;

  const PlushToySpecies(this.displayName, this.description);
}

/// ぬいぐるみキャラクター定義
@JsonSerializable()
class PlushToyCharacter {
  /// キャラクターID
  final String characterId;

  /// キャラクター種類
  final PlushToySpecies species;

  /// カスタム名
  final String customName;

  /// 個性（気質）
  final String personality; // "friendly", "curious", "encouraging", "wise", "gentle"

  /// 経験値（会話数で成長）
  final int experiencePoints;

  /// 好感度（何度会話したか）
  final int affectionLevel;

  /// 作成日時
  final DateTime createdAt;

  /// 最後に会話した日時
  final DateTime? lastConversationAt;

  /// アンロックされたスキル/フレーズ
  final List<String> unlockedSkills;

  PlushToyCharacter({
    required this.characterId,
    required this.species,
    required this.customName,
    required this.personality,
    required this.experiencePoints,
    required this.affectionLevel,
    required this.createdAt,
    this.lastConversationAt,
    required this.unlockedSkills,
  });

  factory PlushToyCharacter.fromJson(Map<String, dynamic> json) =>
      _$PlushToyCharacterFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyCharacterToJson(this);
}

/// ハンズフリー会話セッション
@JsonSerializable()
class PlushToySession {
  /// セッションID
  final String sessionId;

  /// キャラクターID
  final String characterId;

  /// ユーザーID
  final String userId;

  /// セッション開始時刻
  final DateTime startedAt;

  /// セッション終了時刻
  final DateTime? endedAt;

  /// 会話ターン数
  final int turnCount;

  /// 会話の言語トピック（例: "greeting", "daily_life", "emotions", "hobbies"）
  final String topic;

  /// セッション中に学習したフレーズ数
  final int phrasesLearned;

  /// 発音チェック実施数
  final int pronunciationChecks;

  /// 平均スコア (0-100)
  final int averageScore;

  /// ユーザーの気分（セッション終了時）
  final String? userMood; // "happy", "satisfied", "tired", "motivated"

  /// セッションの質評価 (0.0-1.0)
  final double sessionQuality;

  /// 報酬コイン
  final int rewardCoins;

  /// 獲得XP
  final int earnedXP;

  PlushToySession({
    required this.sessionId,
    required this.characterId,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    required this.turnCount,
    required this.topic,
    required this.phrasesLearned,
    required this.pronunciationChecks,
    required this.averageScore,
    this.userMood,
    required this.sessionQuality,
    required this.rewardCoins,
    required this.earnedXP,
  });

  factory PlushToySession.fromJson(Map<String, dynamic> json) =>
      _$PlushToySessionFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToySessionToJson(this);
}

/// 会話内のメッセージ
@JsonSerializable()
class PlushToyMessage {
  /// メッセージID
  final String messageId;

  /// 送信者（"user" または "character"）
  final String sender;

  /// メッセージテキスト
  final String text;

  /// 英語音声プロンプト（AIが話す文）
  final String? audioScript;

  /// 日本語訳
  final String? japaneseTranslation;

  /// メッセージ送信時刻
  final DateTime timestamp;

  /// 発音スコア（ユーザーメッセージの場合のみ）
  final int? pronunciationScore;

  /// ユーザーのカテゴリ分類（文法、感情表現など）
  final String? messageCategory;

  PlushToyMessage({
    required this.messageId,
    required this.sender,
    required this.text,
    this.audioScript,
    this.japaneseTranslation,
    required this.timestamp,
    this.pronunciationScore,
    this.messageCategory,
  });

  factory PlushToyMessage.fromJson(Map<String, dynamic> json) =>
      _$PlushToyMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyMessageToJson(this);
}

/// 会話データ（セッションに含まれる一連の会話）
@JsonSerializable()
class PlushToyConversation {
  /// 会話ID
  final String conversationId;

  /// セッションID
  final String sessionId;

  /// メッセージリスト
  final List<PlushToyMessage> messages;

  /// 会話のテーマ
  final String theme;

  /// 学習ポイント（何を学んだか）
  final List<String> learningPoints;

  /// チャレンジ内容
  final String? challenge;

  /// チャレンジ完了状況
  final bool challengeCompleted;

  /// 会話の自然さスコア (0.0-1.0)
  final double naturalness;

  /// 継続時間（秒）
  final int durationSeconds;

  PlushToyConversation({
    required this.conversationId,
    required this.sessionId,
    required this.messages,
    required this.theme,
    required this.learningPoints,
    this.challenge,
    required this.challengeCompleted,
    required this.naturalness,
    required this.durationSeconds,
  });

  factory PlushToyConversation.fromJson(Map<String, dynamic> json) =>
      _$PlushToyConversationFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyConversationToJson(this);
}

/// ぬいぐるみモード統計
@JsonSerializable()
class PlushToyStats {
  /// 統計ID
  final String statsId;

  /// ユーザーID
  final String userId;

  /// 総セッション数
  final int totalSessions;

  /// 総会話ターン数
  final int totalTurns;

  /// 総学習フレーズ数
  final int totalPhrasesLearned;

  /// 平均セッション長（秒）
  final double averageSessionDuration;

  /// 平均スコア (0-100)
  final double averageScore;

  /// 継続ストリーク（連日実施日数）
  final int consecutiveDays;

  /// 最長ストリーク
  final int longestStreak;

  /// 時間帯別利用分析（データ）
  final Map<String, int> preferredTimeSlots;

  /// 好みのトピック
  final List<String> favoriteTopics;

  /// スクリーンタイム削減（従来と比較）
  final double screenTimeReduction; // 0.0-1.0 (1.0 = 完全ハンズフリー)

  /// 親満足度スコア（推定）
  final double parentalSatisfaction; // 0.0-1.0

  /// 獲得した報酬コイン合計
  final int totalRewardCoins;

  /// 獲得したバッジ
  final List<String> unlockedBadges;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  PlushToyStats({
    required this.statsId,
    required this.userId,
    required this.totalSessions,
    required this.totalTurns,
    required this.totalPhrasesLearned,
    required this.averageSessionDuration,
    required this.averageScore,
    required this.consecutiveDays,
    required this.longestStreak,
    required this.preferredTimeSlots,
    required this.favoriteTopics,
    required this.screenTimeReduction,
    required this.parentalSatisfaction,
    required this.totalRewardCoins,
    required this.unlockedBadges,
    required this.lastUpdatedAt,
  });

  factory PlushToyStats.fromJson(Map<String, dynamic> json) =>
      _$PlushToyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyStatsToJson(this);
}

/// 会話トピック・プロンプト
@JsonSerializable()
class PlushToyTopic {
  /// トピックID
  final String topicId;

  /// トピック名
  final String name;

  /// 難易度 ("beginner", "intermediate", "advanced")
  final String difficulty;

  /// 説明
  final String description;

  /// 推奨フレーズ数
  final int suggestedPhrases;

  /// 初期プロンプト（AIが最初に言うセリフ）
  final String initialPrompt;

  /// 関連するボキャブラリー
  final List<String> vocabularyKeywords;

  /// 期待される学習成果
  final List<String> learningOutcomes;

  /// 推奨グレード
  final String gradeLevel; // "elementary", "junior_high", "high_school"

  PlushToyTopic({
    required this.topicId,
    required this.name,
    required this.difficulty,
    required this.description,
    required this.suggestedPhrases,
    required this.initialPrompt,
    required this.vocabularyKeywords,
    required this.learningOutcomes,
    required this.gradeLevel,
  });

  factory PlushToyTopic.fromJson(Map<String, dynamic> json) =>
      _$PlushToyTopicFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyTopicToJson(this);
}

/// ハンズフリー進捗追跡
@JsonSerializable()
class PlushToyProgress {
  /// 進捗ID
  final String progressId;

  /// ユーザーID
  final String userId;

  /// 現在のレベル
  final int level;

  /// 次のレベルまでの経験値
  final int experienceToNextLevel;

  /// マスターしたトピック数
  final int masteredTopics;

  /// トピック習得度（Map<topicId, percentage>）
  final Map<String, double> topicMastery;

  /// ハンズフリー率（画面を見ずに会話した割合）
  final double handsfreeRatio; // 0.0-1.0

  /// 発音改善度（初回 vs 現在）
  final double pronunciationImprovement; // 0.0-1.0

  /// 親からのフィードバック数
  final int parentFeedbackCount;

  /// 親の評価（親向けダッシュボードから）
  final double parentRating; // 0.0-5.0

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  PlushToyProgress({
    required this.progressId,
    required this.userId,
    required this.level,
    required this.experienceToNextLevel,
    required this.masteredTopics,
    required this.topicMastery,
    required this.handsfreeRatio,
    required this.pronunciationImprovement,
    required this.parentFeedbackCount,
    required this.parentRating,
    required this.lastUpdatedAt,
  });

  factory PlushToyProgress.fromJson(Map<String, dynamic> json) =>
      _$PlushToyProgressFromJson(json);

  Map<String, dynamic> toJson() => _$PlushToyProgressToJson(this);
}
