import 'package:json_annotation/json_annotation.dart';

part 'dialogue_template_model.g.dart';

/// ダイアログ難易度
enum DialogueDifficulty {
  beginner('初級', 'Beginner', 1),
  intermediate('中級', 'Intermediate', 2),
  advanced('上級', 'Advanced', 3),
  expert('エキスパート', 'Expert', 4);

  final String japanese;
  final String english;
  final int level;

  const DialogueDifficulty(this.japanese, this.english, this.level);
}

/// 会話フェーズ
enum ConversationPhase {
  greeting('挨拶', 'Greeting', 'Initial NPC greeting'),
  main('メイン', 'Main', 'Main conversation exchange'),
  climax('クライマックス', 'Climax', 'Key moment/decision point'),
  resolution('解決', 'Resolution', 'Wrapping up'),
  closing('終了', 'Closing', 'Farewell');

  final String japanese;
  final String english;
  final String description;

  const ConversationPhase(this.japanese, this.english, this.description);
}

/// 応答評価基準
@JsonSerializable()
class ResponseEvaluationCriteria {
  /// 最小単語数
  final int minWordCount;

  /// 最大単語数
  final int maxWordCount;

  /// 必須キーワード
  final List<String> keywordsMustInclude;

  /// 避けるべき単語
  final List<String> keywordsToAvoid;

  /// 文法ルール
  final List<String> grammarRules;

  /// 発音精度閾値（0.0-1.0）
  final double pronunciationAccuracyThreshold;

  /// 一般的な間違い
  final List<String> commonMistakes;

  /// 完璧な応答の例
  final List<String> perfectResponseExamples;

  ResponseEvaluationCriteria({
    required this.minWordCount,
    required this.maxWordCount,
    required this.keywordsMustInclude,
    required this.keywordsToAvoid,
    required this.grammarRules,
    required this.pronunciationAccuracyThreshold,
    required this.commonMistakes,
    required this.perfectResponseExamples,
  });

  /// copyWith メソッド
  ResponseEvaluationCriteria copyWith({
    int? minWordCount,
    int? maxWordCount,
    List<String>? keywordsMustInclude,
    List<String>? keywordsToAvoid,
    List<String>? grammarRules,
    double? pronunciationAccuracyThreshold,
    List<String>? commonMistakes,
    List<String>? perfectResponseExamples,
  }) {
    return ResponseEvaluationCriteria(
      minWordCount: minWordCount ?? this.minWordCount,
      maxWordCount: maxWordCount ?? this.maxWordCount,
      keywordsMustInclude: keywordsMustInclude ?? this.keywordsMustInclude,
      keywordsToAvoid: keywordsToAvoid ?? this.keywordsToAvoid,
      grammarRules: grammarRules ?? this.grammarRules,
      pronunciationAccuracyThreshold: pronunciationAccuracyThreshold ??
          this.pronunciationAccuracyThreshold,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      perfectResponseExamples:
          perfectResponseExamples ?? this.perfectResponseExamples,
    );
  }

  factory ResponseEvaluationCriteria.fromJson(Map<String, dynamic> json) =>
      _$ResponseEvaluationCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseEvaluationCriteriaToJson(this);
}

/// ダイアログテンプレート
@JsonSerializable()
class DialogueTemplate {
  /// テンプレートID
  final String templateId;

  /// NPC ID
  final String npcId;

  /// トピック
  final String topic;

  /// 難易度
  final String difficulty; // DialogueDifficulty name

  /// イニシエーター（NPC の開始フレーズ）
  final List<String> initiatorPhrases;

  /// 応答テンプレート
  final List<String> responseTemplates;

  /// フォローアップ質問
  final List<String> followUpQuestions;

  /// コンテキストバリエーション
  final Map<String, List<String>> contextualVariations; // context_type -> variations

  /// 評価基準
  final ResponseEvaluationCriteria evaluationCriteria;

  /// 推奨XP報酬
  final int recommendedXPReward;

  /// 推奨コイン報酬
  final int recommendedCoinReward;

  /// 会話フェーズ
  final String conversationPhase; // ConversationPhase name

  /// 先行条件（トピックやプレイヤーレベル）
  final Map<String, dynamic>? prerequisites;

  /// 後続トピック
  final List<String>? followUpTopics;

  /// ストーリー関連フラグ
  final bool isStoryRelated;

  /// 作成日時
  final DateTime createdAt;

  DialogueTemplate({
    required this.templateId,
    required this.npcId,
    required this.topic,
    required this.difficulty,
    required this.initiatorPhrases,
    required this.responseTemplates,
    required this.followUpQuestions,
    required this.contextualVariations,
    required this.evaluationCriteria,
    required this.recommendedXPReward,
    required this.recommendedCoinReward,
    required this.conversationPhase,
    this.prerequisites,
    this.followUpTopics,
    required this.isStoryRelated,
    required this.createdAt,
  });

  /// copyWith メソッド
  DialogueTemplate copyWith({
    String? templateId,
    String? npcId,
    String? topic,
    String? difficulty,
    List<String>? initiatorPhrases,
    List<String>? responseTemplates,
    List<String>? followUpQuestions,
    Map<String, List<String>>? contextualVariations,
    ResponseEvaluationCriteria? evaluationCriteria,
    int? recommendedXPReward,
    int? recommendedCoinReward,
    String? conversationPhase,
    Map<String, dynamic>? prerequisites,
    List<String>? followUpTopics,
    bool? isStoryRelated,
    DateTime? createdAt,
  }) {
    return DialogueTemplate(
      templateId: templateId ?? this.templateId,
      npcId: npcId ?? this.npcId,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      initiatorPhrases: initiatorPhrases ?? this.initiatorPhrases,
      responseTemplates: responseTemplates ?? this.responseTemplates,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      contextualVariations:
          contextualVariations ?? this.contextualVariations,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      recommendedXPReward: recommendedXPReward ?? this.recommendedXPReward,
      recommendedCoinReward:
          recommendedCoinReward ?? this.recommendedCoinReward,
      conversationPhase: conversationPhase ?? this.conversationPhase,
      prerequisites: prerequisites ?? this.prerequisites,
      followUpTopics: followUpTopics ?? this.followUpTopics,
      isStoryRelated: isStoryRelated ?? this.isStoryRelated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory DialogueTemplate.fromJson(Map<String, dynamic> json) =>
      _$DialogueTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueTemplateToJson(this);
}

/// ダイアログコンテキスト
@JsonSerializable()
class DialogueContext {
  /// NPC ID
  final String npcId;

  /// ロケーション ID
  final String locationId;

  /// 時間帯
  final String timeOfDay; // morning, afternoon, evening, night

  /// NPC 現在の気分
  final String currentMood; // NPCMoodState name

  /// NPC-ユーザー関係
  final Map<String, dynamic>? relationshipData;

  /// 会話履歴
  final List<DialogueMessage>? conversationHistory;

  /// 天気効果
  final String? weatherEffect;

  /// プレイヤー入力
  final String playerInput;

  DialogueContext({
    required this.npcId,
    required this.locationId,
    required this.timeOfDay,
    required this.currentMood,
    this.relationshipData,
    this.conversationHistory,
    this.weatherEffect,
    required this.playerInput,
  });

  /// copyWith メソッド
  DialogueContext copyWith({
    String? npcId,
    String? locationId,
    String? timeOfDay,
    String? currentMood,
    Map<String, dynamic>? relationshipData,
    List<DialogueMessage>? conversationHistory,
    String? weatherEffect,
    String? playerInput,
  }) {
    return DialogueContext(
      npcId: npcId ?? this.npcId,
      locationId: locationId ?? this.locationId,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      currentMood: currentMood ?? this.currentMood,
      relationshipData: relationshipData ?? this.relationshipData,
      conversationHistory:
          conversationHistory ?? this.conversationHistory,
      weatherEffect: weatherEffect ?? this.weatherEffect,
      playerInput: playerInput ?? this.playerInput,
    );
  }

  factory DialogueContext.fromJson(Map<String, dynamic> json) =>
      _$DialogueContextFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueContextToJson(this);
}

/// ダイアログメッセージ
@JsonSerializable()
class DialogueMessage {
  /// メッセージID
  final String messageId;

  /// スピーカー（'npc' または 'player'）
  final String speaker;

  /// メッセージテキスト
  final String text;

  /// メッセージの英語訳
  final String? englishTranslation;

  /// メッセージ日時
  final DateTime timestamp;

  /// 関連トピック
  final String? topic;

  /// 感情（NPC メッセージの場合）
  final String? emotion;

  DialogueMessage({
    required this.messageId,
    required this.speaker,
    required this.text,
    this.englishTranslation,
    required this.timestamp,
    this.topic,
    this.emotion,
  });

  /// copyWith メソッド
  DialogueMessage copyWith({
    String? messageId,
    String? speaker,
    String? text,
    String? englishTranslation,
    DateTime? timestamp,
    String? topic,
    String? emotion,
  }) {
    return DialogueMessage(
      messageId: messageId ?? this.messageId,
      speaker: speaker ?? this.speaker,
      text: text ?? this.text,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      timestamp: timestamp ?? this.timestamp,
      topic: topic ?? this.topic,
      emotion: emotion ?? this.emotion,
    );
  }

  factory DialogueMessage.fromJson(Map<String, dynamic> json) =>
      _$DialogueMessageFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueMessageToJson(this);
}

/// ダイアログ応答
@JsonSerializable()
class DialogueResponse {
  /// NPC スピーチ
  final String npcSpeech;

  /// 英語訳
  final String? englishTranslation;

  /// 提案されるプレイヤー応答
  final List<String> suggestedPlayerResponses;

  /// 現在の会話フェーズ
  final String currentPhase; // ConversationPhase name

  /// 最小難易度レベル
  final int minimumDifficultyLevel;

  /// 感情表現（EmojiやAI指示用）
  final String npcEmotion;

  /// フォローアップアクション
  final String? followUpAction;

  DialogueResponse({
    required this.npcSpeech,
    this.englishTranslation,
    required this.suggestedPlayerResponses,
    required this.currentPhase,
    required this.minimumDifficultyLevel,
    required this.npcEmotion,
    this.followUpAction,
  });

  /// copyWith メソッド
  DialogueResponse copyWith({
    String? npcSpeech,
    String? englishTranslation,
    List<String>? suggestedPlayerResponses,
    String? currentPhase,
    int? minimumDifficultyLevel,
    String? npcEmotion,
    String? followUpAction,
  }) {
    return DialogueResponse(
      npcSpeech: npcSpeech ?? this.npcSpeech,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      suggestedPlayerResponses:
          suggestedPlayerResponses ?? this.suggestedPlayerResponses,
      currentPhase: currentPhase ?? this.currentPhase,
      minimumDifficultyLevel:
          minimumDifficultyLevel ?? this.minimumDifficultyLevel,
      npcEmotion: npcEmotion ?? this.npcEmotion,
      followUpAction: followUpAction ?? this.followUpAction,
    );
  }

  factory DialogueResponse.fromJson(Map<String, dynamic> json) =>
      _$DialogueResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueResponseToJson(this);
}
