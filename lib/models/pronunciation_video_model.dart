import 'package:json_annotation/json_annotation.dart';

part 'pronunciation_video_model.g.dart';

/// 初回の発音記録（30日後の比較対象となる）
@JsonSerializable()
class PronunciationVideoRecord {
  /// 記録ID
  final String recordId;

  /// ユーザーID
  final String userId;

  /// フレーズ/単語
  final String phrase;

  /// 日本語訳
  final String meaning;

  /// 初回スコア (0-100)
  final int initialScore;

  /// 初回の音声ファイル参照（実運用時はCloud Storageパス）
  final String audioReference;

  /// 記録日時
  final DateTime recordedAt;

  /// カテゴリ（例: "greeting", "basic_phrases", "conversation"）
  final String category;

  /// 難易度
  final String difficulty;

  PronunciationVideoRecord({
    required this.recordId,
    required this.userId,
    required this.phrase,
    required this.meaning,
    required this.initialScore,
    required this.audioReference,
    required this.recordedAt,
    required this.category,
    required this.difficulty,
  });

  factory PronunciationVideoRecord.fromJson(Map<String, dynamic> json) =>
      _$PronunciationVideoRecordFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationVideoRecordToJson(this);
}

/// 30日後の比較と成長動画データ
@JsonSerializable()
class PronunciationVideoComparison {
  /// 比較ID
  final String comparisonId;

  /// 元の記録ID
  final String recordId;

  /// ユーザーID
  final String userId;

  /// 比較時点でのスコア (0-100)
  final int finalScore;

  /// 比較時点での音声ファイル参照
  final String finalAudioReference;

  /// スコア改善幅 (0-100)
  final int scoreImprovement;

  /// 改善率 (%)
  final double improvementPercentage;

  /// 成長レベル（"novice", "beginner", "intermediate", "advanced", "excellent"）
  final String growthLevel;

  /// 発音精度改善 (0.0-1.0)
  final double accuracyImprovement;

  /// 速度改善 (0.0-1.0)
  final double speedImprovement;

  /// イントネーション改善 (0.0-1.0)
  final double intonationImprovement;

  /// 比較動画が生成された日時
  final DateTime generatedAt;

  /// 30日間の継続学習日数
  final int consistencyDays;

  /// 同期間での学習フレーズ数
  final int phrasesLearned;

  /// 報酬コイン
  final int rewardCoins;

  /// 特別バッジの獲得（報告日時）
  final DateTime? badgeUnlockedAt;

  PronunciationVideoComparison({
    required this.comparisonId,
    required this.recordId,
    required this.userId,
    required this.finalScore,
    required this.finalAudioReference,
    required this.scoreImprovement,
    required this.improvementPercentage,
    required this.growthLevel,
    required this.accuracyImprovement,
    required this.speedImprovement,
    required this.intonationImprovement,
    required this.generatedAt,
    required this.consistencyDays,
    required this.phrasesLearned,
    required this.rewardCoins,
    this.badgeUnlockedAt,
  });

  factory PronunciationVideoComparison.fromJson(Map<String, dynamic> json) =>
      _$PronunciationVideoComparisonFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationVideoComparisonToJson(this);
}

/// 発音成長の進捗情報
@JsonSerializable()
class PronunciationProgress {
  /// 進捗ID
  final String progressId;

  /// ユーザーID
  final String userId;

  /// 総記録数
  final int totalRecords;

  /// 30日経過した比較数（動画生成済み）
  final int videosGenerated;

  /// 平均スコア改善幅
  final double averageImprovement;

  /// 最高改善幅
  final int maxImprovement;

  /// 最低改善幅
  final int minImprovement;

  /// 継続中の記録（30日未経過）
  final List<PronunciationVideoRecord> activeRecords;

  /// 完了した比較（30日経過・動画生成済み）
  final List<PronunciationVideoComparison> completedComparisons;

  /// 全動画の平均スコア
  final double averageVideoScore;

  /// スコア分布（初回スコア平均）
  final double averageInitialScore;

  /// スコア分布（最終スコア平均）
  final double averageFinalScore;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  PronunciationProgress({
    required this.progressId,
    required this.userId,
    required this.totalRecords,
    required this.videosGenerated,
    required this.averageImprovement,
    required this.maxImprovement,
    required this.minImprovement,
    required this.activeRecords,
    required this.completedComparisons,
    required this.averageVideoScore,
    required this.averageInitialScore,
    required this.averageFinalScore,
    required this.lastUpdatedAt,
  });

  factory PronunciationProgress.fromJson(Map<String, dynamic> json) =>
      _$PronunciationProgressFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationProgressToJson(this);
}

/// 動画シェアカード用データ
@JsonSerializable()
class VideoShareCard {
  /// シェアカードID
  final String shareCardId;

  /// 比較ID
  final String comparisonId;

  /// ユーザー名（匿名化可能）
  final String userName;

  /// 表示用スコア（初回）
  final int initialScore;

  /// 表示用スコア（最終）
  final int finalScore;

  /// 改善幅テキスト
  final String improvementText;

  /// 成長レベルテキスト
  final String growthLevelText;

  /// シェアカードの画像URL（生成後）
  final String? imageUrl;

  /// 生成日時
  final DateTime generatedAt;

  /// シェアURL（SNS用）
  final String shareUrl;

  /// SNS定型文テンプレート
  final String shareTemplate;

  VideoShareCard({
    required this.shareCardId,
    required this.comparisonId,
    required this.userName,
    required this.initialScore,
    required this.finalScore,
    required this.improvementText,
    required this.growthLevelText,
    required this.imageUrl,
    required this.generatedAt,
    required this.shareUrl,
    required this.shareTemplate,
  });

  factory VideoShareCard.fromJson(Map<String, dynamic> json) =>
      _$VideoShareCardFromJson(json);

  Map<String, dynamic> toJson() => _$VideoShareCardToJson(this);
}

/// 発音動画関連の統計とマイルストーン
@JsonSerializable()
class PronunciationVideoStats {
  /// 統計ID
  final String statsId;

  /// ユーザーID
  final String userId;

  /// 総スコア改善（全動画合計）
  final int totalImprovement;

  /// 最高スコア改善を記録したフレーズ
  final String? bestImprovementPhrase;

  /// 最高スコア改善の幅
  final int? bestImprovementValue;

  /// 全動画の平均継続日数
  final double averageConsistencyDays;

  /// 達成したマイルストーン
  final List<String> unlockedMilestones; // 例: "first_video", "10_point_milestone", "consistency_30days"

  /// 獲得した報酬コイン合計
  final int totalRewardCoins;

  /// 獲得した特別バッジ数
  final int specialBadgesEarned;

  /// 親向け課金インセンティブ（継続意欲）
  final double subscriptionRetentionScore; // 0.0-1.0

  /// 最後の成功した動画比較日
  final DateTime? lastSuccessfulComparisonAt;

  /// 更新日時
  final DateTime updatedAt;

  PronunciationVideoStats({
    required this.statsId,
    required this.userId,
    required this.totalImprovement,
    this.bestImprovementPhrase,
    this.bestImprovementValue,
    required this.averageConsistencyDays,
    required this.unlockedMilestones,
    required this.totalRewardCoins,
    required this.specialBadgesEarned,
    required this.subscriptionRetentionScore,
    this.lastSuccessfulComparisonAt,
    required this.updatedAt,
  });

  factory PronunciationVideoStats.fromJson(Map<String, dynamic> json) =>
      _$PronunciationVideoStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationVideoStatsToJson(this);
}

/// マイルストーン定義
@JsonSerializable()
class PronunciationMilestone {
  /// マイルストーンID
  final String milestoneId;

  /// マイルストーン名
  final String name;

  /// 説明
  final String description;

  /// アイコン
  final String icon;

  /// 達成条件の種類
  final String conditionType; // "first_video", "improvement_threshold", "consistency", "total_videos"

  /// 達成条件の値
  final dynamic conditionValue;

  /// 報酬コイン
  final int rewardCoins;

  /// 獲得可能な特別バッジ
  final String? specialBadge;

  /// 親への説得力スコア（課金継続への効果）
  final double parental_appealScore; // 0.0-1.0

  PronunciationMilestone({
    required this.milestoneId,
    required this.name,
    required this.description,
    required this.icon,
    required this.conditionType,
    required this.conditionValue,
    required this.rewardCoins,
    this.specialBadge,
    required this.parental_appealScore,
  });

  factory PronunciationMilestone.fromJson(Map<String, dynamic> json) =>
      _$PronunciationMilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationMilestoneToJson(this);
}
