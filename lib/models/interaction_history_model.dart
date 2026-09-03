import 'package:json_annotation/json_annotation.dart';

part 'interaction_history_model.g.dart';

/// インタラクションレコード（個別の会話ターン）
@JsonSerializable()
class InteractionRecord {
  /// レコードID
  final String recordId;

  /// ユーザーID
  final String userId;

  /// NPC ID
  final String npcId;

  /// タイムスタンプ
  final DateTime timestamp;

  /// プレイヤー入力
  final String userInput;

  /// NPC応答
  final String npcResponse;

  /// 応答スコア（0-100）
  final int responseScore;

  /// 獲得XP
  final int xpEarned;

  /// 獲得コイン
  final int coinsEarned;

  /// 会話トピック
  final String conversationTopic;

  /// 難易度
  final String difficulty;

  /// 成功したか
  final bool wasSuccessful;

  /// フィードバック（オプション）
  final String? feedbackProvided;

  /// 時間帯
  final String? timeOfDay;

  /// NPC気分（当時）
  final String? npcMoodAtTime;

  InteractionRecord({
    required this.recordId,
    required this.userId,
    required this.npcId,
    required this.timestamp,
    required this.userInput,
    required this.npcResponse,
    required this.responseScore,
    required this.xpEarned,
    required this.coinsEarned,
    required this.conversationTopic,
    required this.difficulty,
    required this.wasSuccessful,
    this.feedbackProvided,
    this.timeOfDay,
    this.npcMoodAtTime,
  });

  /// copyWith メソッド
  InteractionRecord copyWith({
    String? recordId,
    String? userId,
    String? npcId,
    DateTime? timestamp,
    String? userInput,
    String? npcResponse,
    int? responseScore,
    int? xpEarned,
    int? coinsEarned,
    String? conversationTopic,
    String? difficulty,
    bool? wasSuccessful,
    String? feedbackProvided,
    String? timeOfDay,
    String? npcMoodAtTime,
  }) {
    return InteractionRecord(
      recordId: recordId ?? this.recordId,
      userId: userId ?? this.userId,
      npcId: npcId ?? this.npcId,
      timestamp: timestamp ?? this.timestamp,
      userInput: userInput ?? this.userInput,
      npcResponse: npcResponse ?? this.npcResponse,
      responseScore: responseScore ?? this.responseScore,
      xpEarned: xpEarned ?? this.xpEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      conversationTopic: conversationTopic ?? this.conversationTopic,
      difficulty: difficulty ?? this.difficulty,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      feedbackProvided: feedbackProvided ?? this.feedbackProvided,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      npcMoodAtTime: npcMoodAtTime ?? this.npcMoodAtTime,
    );
  }

  factory InteractionRecord.fromJson(Map<String, dynamic> json) =>
      _$InteractionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionRecordToJson(this);
}

/// NPC インタラクションメトリクス
@JsonSerializable()
class NPCInteractionMetrics {
  /// NPC ID
  final String npcId;

  /// 総インタラクション数
  final int totalInteractions;

  /// 平均スコア（0-100）
  final double averageScore;

  /// 発見されたトピック
  final List<String> discoveredTopics;

  /// 関係レベル（0-100）
  final int relationshipLevel;

  /// 最初のインタラクション
  final DateTime? firstInteractionAt;

  /// 最後のインタラクション
  final DateTime? lastInteractionAt;

  /// トピック別頻度
  final Map<String, int> topicFrequency;

  /// 難易度別成功率
  final Map<String, double> successRateByDifficulty;

  /// 総獲得XP
  final int totalXPEarned;

  /// 総獲得コイン
  final int totalCoinsEarned;

  /// 平均スコア上昇傾向
  final List<double> scoreProgressionTrend;

  /// 連続会話日数
  final int currentConsecutiveDays;

  /// 最高連続日数
  final int maxConsecutiveDays;

  NPCInteractionMetrics({
    required this.npcId,
    required this.totalInteractions,
    required this.averageScore,
    required this.discoveredTopics,
    required this.relationshipLevel,
    this.firstInteractionAt,
    this.lastInteractionAt,
    required this.topicFrequency,
    required this.successRateByDifficulty,
    required this.totalXPEarned,
    required this.totalCoinsEarned,
    required this.scoreProgressionTrend,
    required this.currentConsecutiveDays,
    required this.maxConsecutiveDays,
  });

  /// copyWith メソッド
  NPCInteractionMetrics copyWith({
    String? npcId,
    int? totalInteractions,
    double? averageScore,
    List<String>? discoveredTopics,
    int? relationshipLevel,
    DateTime? firstInteractionAt,
    DateTime? lastInteractionAt,
    Map<String, int>? topicFrequency,
    Map<String, double>? successRateByDifficulty,
    int? totalXPEarned,
    int? totalCoinsEarned,
    List<double>? scoreProgressionTrend,
    int? currentConsecutiveDays,
    int? maxConsecutiveDays,
  }) {
    return NPCInteractionMetrics(
      npcId: npcId ?? this.npcId,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      averageScore: averageScore ?? this.averageScore,
      discoveredTopics: discoveredTopics ?? this.discoveredTopics,
      relationshipLevel: relationshipLevel ?? this.relationshipLevel,
      firstInteractionAt: firstInteractionAt ?? this.firstInteractionAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      topicFrequency: topicFrequency ?? this.topicFrequency,
      successRateByDifficulty:
          successRateByDifficulty ?? this.successRateByDifficulty,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      scoreProgressionTrend:
          scoreProgressionTrend ?? this.scoreProgressionTrend,
      currentConsecutiveDays:
          currentConsecutiveDays ?? this.currentConsecutiveDays,
      maxConsecutiveDays: maxConsecutiveDays ?? this.maxConsecutiveDays,
    );
  }

  factory NPCInteractionMetrics.fromJson(Map<String, dynamic> json) =>
      _$NPCInteractionMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$NPCInteractionMetricsToJson(this);
}

/// NPC学習進捗（エピソード方式）
@JsonSerializable()
class NPCLearningEpisode {
  /// エピソードID
  final String episodeId;

  /// NPC ID
  final String npcId;

  /// ユーザーID
  final String userId;

  /// エピソード名
  final String episodeName;

  /// エピソード説明
  final String description;

  /// 発生日時
  final DateTime occurredAt;

  /// エピソードタイプ（'milestone', 'discovery', 'story', 'relationship'）
  final String episodeType;

  /// 関連トピック
  final List<String> relatedTopics;

  /// 報酬（XP/コイン）
  final int rewardXP;
  final int rewardCoins;

  /// バッジアンロック（存在する場合）
  final String? unlockedBadgeId;

  /// ストーリー進捗（このエピソードで進捗した割合）
  final double storyProgressAdvancement;

  NPCLearningEpisode({
    required this.episodeId,
    required this.npcId,
    required this.userId,
    required this.episodeName,
    required this.description,
    required this.occurredAt,
    required this.episodeType,
    required this.relatedTopics,
    required this.rewardXP,
    required this.rewardCoins,
    this.unlockedBadgeId,
    required this.storyProgressAdvancement,
  });

  /// copyWith メソッド
  NPCLearningEpisode copyWith({
    String? episodeId,
    String? npcId,
    String? userId,
    String? episodeName,
    String? description,
    DateTime? occurredAt,
    String? episodeType,
    List<String>? relatedTopics,
    int? rewardXP,
    int? rewardCoins,
    String? unlockedBadgeId,
    double? storyProgressAdvancement,
  }) {
    return NPCLearningEpisode(
      episodeId: episodeId ?? this.episodeId,
      npcId: npcId ?? this.npcId,
      userId: userId ?? this.userId,
      episodeName: episodeName ?? this.episodeName,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      episodeType: episodeType ?? this.episodeType,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      rewardXP: rewardXP ?? this.rewardXP,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      unlockedBadgeId: unlockedBadgeId ?? this.unlockedBadgeId,
      storyProgressAdvancement:
          storyProgressAdvancement ?? this.storyProgressAdvancement,
    );
  }

  factory NPCLearningEpisode.fromJson(Map<String, dynamic> json) =>
      _$NPCLearningEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$NPCLearningEpisodeToJson(this);
}

/// 会話セッション（複数ターンの会話）
@JsonSerializable()
class ConversationSession {
  /// セッションID
  final String sessionId;

  /// ユーザーID
  final String userId;

  /// NPC ID
  final String npcId;

  /// セッション開始時刻
  final DateTime startedAt;

  /// セッション終了時刻
  final DateTime? endedAt;

  /// セッションの会話ターン数
  final int turnCount;

  /// セッションの平均スコア
  final double averageScore;

  /// セッション中の総獲得XP
  final int totalXPEarned;

  /// セッション中の総獲得コイン
  final int totalCoinsEarned;

  /// セッション中に発見されたトピック
  final List<String> discoveredTopics;

  /// セッション中の関係変化
  final int relationshipChange;

  /// セッションテーマ（主なトピック）
  final String sessionTheme;

  /// NPC気分変化（セッション前後）
  final String? moodChangeDescription;

  ConversationSession({
    required this.sessionId,
    required this.userId,
    required this.npcId,
    required this.startedAt,
    this.endedAt,
    required this.turnCount,
    required this.averageScore,
    required this.totalXPEarned,
    required this.totalCoinsEarned,
    required this.discoveredTopics,
    required this.relationshipChange,
    required this.sessionTheme,
    this.moodChangeDescription,
  });

  /// セッション期間（分）
  int get durationMinutes {
    if (endedAt == null) {
      return DateTime.now().difference(startedAt).inMinutes;
    }
    return endedAt!.difference(startedAt).inMinutes;
  }

  /// copyWith メソッド
  ConversationSession copyWith({
    String? sessionId,
    String? userId,
    String? npcId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? turnCount,
    double? averageScore,
    int? totalXPEarned,
    int? totalCoinsEarned,
    List<String>? discoveredTopics,
    int? relationshipChange,
    String? sessionTheme,
    String? moodChangeDescription,
  }) {
    return ConversationSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      npcId: npcId ?? this.npcId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      turnCount: turnCount ?? this.turnCount,
      averageScore: averageScore ?? this.averageScore,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      discoveredTopics: discoveredTopics ?? this.discoveredTopics,
      relationshipChange: relationshipChange ?? this.relationshipChange,
      sessionTheme: sessionTheme ?? this.sessionTheme,
      moodChangeDescription:
          moodChangeDescription ?? this.moodChangeDescription,
    );
  }

  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
      _$ConversationSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSessionToJson(this);
}
