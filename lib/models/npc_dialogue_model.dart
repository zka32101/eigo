import 'package:json_annotation/json_annotation.dart';
import 'package:eigo/models/npc_behavior_model.dart';

part 'npc_dialogue_model.g.dart';

/// 対話タイプ
enum DialogueType {
  greeting('挨拶', 'Greeting'),
  farewell('別れ', 'Farewell'),
  small_talk('世間話', 'Small Talk'),
  quest_offer('クエスト提示', 'Quest Offer'),
  quest_complete('クエスト完了', 'Quest Complete'),
  shop('商売', 'Shop'),
  romance('ロマンス', 'Romance'),
  sad('悲しい話', 'Sad'),
  excited('興奮', 'Excited'),
  angry('怒り', 'Angry'),
  custom('カスタム', 'Custom');

  final String japanese;
  final String english;

  const DialogueType(this.japanese, this.english);
}

/// 対話の条件
@JsonSerializable()
class DialogueCondition {
  /// 最小親密度
  final int? minAffection;

  /// 最大親密度
  final int? maxAffection;

  /// 必要なムード
  final List<NPCMood>? requiredMoods;

  /// 必要な性格タイプ
  final List<PersonalityType>? requiredPersonalities;

  /// 必要なフラグ
  final List<String>? requiredFlags;

  /// 禁止されたフラグ
  final List<String>? forbiddenFlags;

  /// 最小開放性
  final int? minOpenness;

  /// 最小協調性
  final int? minAgreeableness;

  /// 最小外向性
  final int? minExtraversion;

  /// 時間帯の制限
  final List<String>? allowedTimeOfDay; // "morning", "afternoon", "evening", "night"

  /// 必要な最小回数のインタラクション
  final int? minInteractionCount;

  DialogueCondition({
    this.minAffection,
    this.maxAffection,
    this.requiredMoods,
    this.requiredPersonalities,
    this.requiredFlags,
    this.forbiddenFlags,
    this.minOpenness,
    this.minAgreeableness,
    this.minExtraversion,
    this.allowedTimeOfDay,
    this.minInteractionCount,
  });

  factory DialogueCondition.fromJson(Map<String, dynamic> json) =>
      _$DialogueConditionFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueConditionToJson(this);
}

/// 対話オプション（プレイヤーの選択肢）
@JsonSerializable()
class DialogueOption {
  /// オプション ID
  final String optionId;

  /// 表示テキスト
  final String text;

  /// 日本語版
  final String? textJa;

  /// アフィニティへの影響
  final int affectionChange;

  /// 次の対話ノード ID
  final String? nextNodeId;

  /// フラグを設定
  final List<String>? setFlags;

  /// NPC のムードへの影響
  final NPCMood? moodChange;

  /// ツールチップ（オプションの説明）
  final String? tooltip;

  DialogueOption({
    required this.optionId,
    required this.text,
    this.textJa,
    this.affectionChange = 0,
    this.nextNodeId,
    this.setFlags,
    this.moodChange,
    this.tooltip,
  });

  factory DialogueOption.fromJson(Map<String, dynamic> json) =>
      _$DialogueOptionFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueOptionToJson(this);
}

/// 対話ノード（会話の1ステップ）
@JsonSerializable()
class DialogueNode {
  /// ノード ID
  final String nodeId;

  /// NPC のセリフ
  final String npcText;

  /// 日本語版
  final String? npcTextJa;

  /// 対話タイプ
  final DialogueType dialogueType;

  /// 感情表現（絵文字など）
  final String? emoticon;

  /// 条件
  final DialogueCondition? condition;

  /// プレイヤーの選択肢
  final List<DialogueOption> options;

  /// 自動進行の次ノード（選択肢がない場合）
  final String? autoNextNodeId;

  /// 対話完了時の報酬
  final DialogueReward? reward;

  DialogueNode({
    required this.nodeId,
    required this.npcText,
    this.npcTextJa,
    required this.dialogueType,
    this.emoticon,
    this.condition,
    this.options = const [],
    this.autoNextNodeId,
    this.reward,
  });

  factory DialogueNode.fromJson(Map<String, dynamic> json) =>
      _$DialogueNodeFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueNodeToJson(this);
}

/// 対話の報酬
@JsonSerializable()
class DialogueReward {
  /// アフィニティの増加
  final int affectionBonus;

  /// 経験値
  final int xpReward;

  /// アイテム報酬 ID
  final String? itemRewardId;

  /// クエスト進行フラグ
  final String? questProgressFlag;

  /// カスタムスクリプト（イベントトリガー）
  final String? customScript;

  DialogueReward({
    this.affectionBonus = 0,
    this.xpReward = 0,
    this.itemRewardId,
    this.questProgressFlag,
    this.customScript,
  });

  factory DialogueReward.fromJson(Map<String, dynamic> json) =>
      _$DialogueRewardFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueRewardToJson(this);
}

/// 対話ツリー
@JsonSerializable()
class DialogueTree {
  /// ツリー ID
  final String treeId;

  /// NPC ID
  final String npcId;

  /// タイトル
  final String title;

  /// 説明
  final String description;

  /// ルートノード ID
  final String rootNodeId;

  /// すべてのノード
  final Map<String, DialogueNode> nodes;

  /// 有効かどうか
  final bool isActive;

  /// 作成日時
  final DateTime createdAt;

  /// 更新日時
  final DateTime updatedAt;

  DialogueTree({
    required this.treeId,
    required this.npcId,
    required this.title,
    required this.description,
    required this.rootNodeId,
    required this.nodes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DialogueTree.fromJson(Map<String, dynamic> json) =>
      _$DialogueTreeFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueTreeToJson(this);

  /// ルートノードを取得
  DialogueNode? getRootNode() => nodes[rootNodeId];

  /// ノードを取得
  DialogueNode? getNode(String nodeId) => nodes[nodeId];
}

/// 対話セッション（進行中の会話）
@JsonSerializable()
class DialogueSession {
  /// セッション ID
  final String sessionId;

  /// 対話ツリー ID
  final String treeId;

  /// NPC ID
  final String npcId;

  /// 現在のノード ID
  final String currentNodeId;

  /// 対話履歴
  final List<DialogueExchange> history;

  /// セッションが完了したか
  final bool isComplete;

  /// セッション開始時刻
  final DateTime startedAt;

  /// セッション更新時刻
  final DateTime updatedAt;

  DialogueSession({
    required this.sessionId,
    required this.treeId,
    required this.npcId,
    required this.currentNodeId,
    this.history = const [],
    this.isComplete = false,
    required this.startedAt,
    required this.updatedAt,
  });

  factory DialogueSession.fromJson(Map<String, dynamic> json) =>
      _$DialogueSessionFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueSessionToJson(this);

  /// セッションをコピー
  DialogueSession copyWith({
    String? sessionId,
    String? treeId,
    String? npcId,
    String? currentNodeId,
    List<DialogueExchange>? history,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) {
    return DialogueSession(
      sessionId: sessionId ?? this.sessionId,
      treeId: treeId ?? this.treeId,
      npcId: npcId ?? this.npcId,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      history: history ?? this.history,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 対話の交換（1つのやり取り）
@JsonSerializable()
class DialogueExchange {
  /// NPC のセリフ
  final String npcText;

  /// プレイヤーの選択肢テキスト（選択した場合）
  final String? playerChoice;

  /// 選択肢 ID
  final String? chosenOptionId;

  /// 時刻
  final DateTime timestamp;

  /// この交換での親密度変化
  final int affectionDelta;

  DialogueExchange({
    required this.npcText,
    this.playerChoice,
    this.chosenOptionId,
    required this.timestamp,
    this.affectionDelta = 0,
  });

  factory DialogueExchange.fromJson(Map<String, dynamic> json) =>
      _$DialogueExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueExchangeToJson(this);
}

/// 対話フロー（複数のツリーを管理）
@JsonSerializable()
class DialogueFlow {
  /// フロー ID
  final String flowId;

  /// NPC ID
  final String npcId;

  /// 対話ツリー ID のリスト（優先順位順）
  final List<String> treeIds;

  /// デフォルトツリー ID
  final String defaultTreeId;

  /// フローが有効か
  final bool isActive;

  DialogueFlow({
    required this.flowId,
    required this.npcId,
    required this.treeIds,
    required this.defaultTreeId,
    this.isActive = true,
  });

  factory DialogueFlow.fromJson(Map<String, dynamic> json) =>
      _$DialogueFlowFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueFlowToJson(this);
}

/// 対話統計
@JsonSerializable()
class DialogueStatistics {
  /// NPC ID
  final String npcId;

  /// 合計対話数
  final int totalConversations;

  /// ユニークな対話ツリー数
  final int uniqueTreesUsed;

  /// 総アフィニティ変化
  final int totalAffectionChange;

  /// 最後の対話時刻
  final DateTime? lastDialogueTime;

  /// 好みの対話タイプ
  final List<DialogueType>? preferredDialogueTypes;

  DialogueStatistics({
    required this.npcId,
    this.totalConversations = 0,
    this.uniqueTreesUsed = 0,
    this.totalAffectionChange = 0,
    this.lastDialogueTime,
    this.preferredDialogueTypes,
  });

  factory DialogueStatistics.fromJson(Map<String, dynamic> json) =>
      _$DialogueStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueStatisticsToJson(this);
}
