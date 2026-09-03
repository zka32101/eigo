import 'package:json_annotation/json_annotation.dart';

part 'npc_relationship_model.g.dart';

/// NPC関係ステータス
enum RelationshipStatus {
  stranger('見知らぬ人', 'Stranger'),
  acquaintance('知人', 'Acquaintance'),
  friend('友人', 'Friend'),
  goodFriend('良い友人', 'Good Friend'),
  bestFriend('親友', 'Best Friend'),
  soulmate('ソウルメイト', 'Soulmate');

  final String japanese;
  final String english;

  const RelationshipStatus(this.japanese, this.english);

  /// 親密度スコア（0-100）からステータスを取得
  static RelationshipStatus fromAffectionScore(int score) {
    if (score < 10) return RelationshipStatus.stranger;
    if (score < 25) return RelationshipStatus.acquaintance;
    if (score < 50) return RelationshipStatus.friend;
    if (score < 75) return RelationshipStatus.goodFriend;
    if (score < 90) return RelationshipStatus.bestFriend;
    return RelationshipStatus.soulmate;
  }
}

/// NPC関係情報
@JsonSerializable()
class NPCRelationship {
  /// NPC ID
  final String npcId;

  /// ユーザー ID
  final String userId;

  /// 親密度スコア（0-100）
  int affectionScore;

  /// 最後の相互作用日時
  DateTime? lastInteractionTime;

  /// 総相互作用回数
  int totalInteractions;

  /// 好感度アップイベント
  final List<String> affectionEvents;

  /// アンロック済みダイアログ
  final List<String> unlockedDialogues;

  /// 選択した対話パス
  final Map<String, String> chosenDialoguePaths;

  /// 特別なイベント達成
  final List<String> specialEventAchievements;

  /// プレイヤーの好意度（0-100）
  int playerAffectionLevel;

  /// NPC好意度（NPC視点、0-100）
  int npcAffectionLevel;

  /// 作成日時
  final DateTime createdAt;

  /// 更新日時
  DateTime updatedAt;

  NPCRelationship({
    required this.npcId,
    required this.userId,
    this.affectionScore = 0,
    this.lastInteractionTime,
    this.totalInteractions = 0,
    this.affectionEvents = const [],
    this.unlockedDialogues = const [],
    this.chosenDialoguePaths = const {},
    this.specialEventAchievements = const [],
    this.playerAffectionLevel = 0,
    this.npcAffectionLevel = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 関係ステータスを取得
  RelationshipStatus getStatus() => RelationshipStatus.fromAffectionScore(affectionScore);

  /// 親密度を増加
  void increaseAffection(int amount) {
    affectionScore = (affectionScore + amount).clamp(0, 100);
    updatedAt = DateTime.now();
  }

  /// 親密度を減少
  void decreaseAffection(int amount) {
    affectionScore = (affectionScore - amount).clamp(0, 100);
    updatedAt = DateTime.now();
  }

  /// ダイアログをアンロック
  void unlockDialogue(String dialogueId) {
    if (!unlockedDialogues.contains(dialogueId)) {
      unlockedDialogues.add(dialogueId);
      updatedAt = DateTime.now();
    }
  }

  /// ダイアログパスを記録
  void recordDialoguePath(String dialogueId, String choicePath) {
    chosenDialoguePaths[dialogueId] = choicePath;
    updatedAt = DateTime.now();
  }

  /// 特別なイベントを達成
  void achieveSpecialEvent(String eventId) {
    if (!specialEventAchievements.contains(eventId)) {
      specialEventAchievements.add(eventId);
      updatedAt = DateTime.now();
    }
  }

  /// 親密度イベントを追加
  void addAffectionEvent(String eventDescription) {
    affectionEvents.add(eventDescription);
    updatedAt = DateTime.now();
  }

  factory NPCRelationship.fromJson(Map<String, dynamic> json) =>
      _$NPCRelationshipFromJson(json);

  Map<String, dynamic> toJson() => _$NPCRelationshipToJson(this);

  /// コピー関数
  NPCRelationship copyWith({
    String? npcId,
    String? userId,
    int? affectionScore,
    DateTime? lastInteractionTime,
    int? totalInteractions,
    List<String>? affectionEvents,
    List<String>? unlockedDialogues,
    Map<String, String>? chosenDialoguePaths,
    List<String>? specialEventAchievements,
    int? playerAffectionLevel,
    int? npcAffectionLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NPCRelationship(
      npcId: npcId ?? this.npcId,
      userId: userId ?? this.userId,
      affectionScore: affectionScore ?? this.affectionScore,
      lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      affectionEvents: affectionEvents ?? this.affectionEvents,
      unlockedDialogues: unlockedDialogues ?? this.unlockedDialogues,
      chosenDialoguePaths: chosenDialoguePaths ?? this.chosenDialoguePaths,
      specialEventAchievements:
          specialEventAchievements ?? this.specialEventAchievements,
      playerAffectionLevel: playerAffectionLevel ?? this.playerAffectionLevel,
      npcAffectionLevel: npcAffectionLevel ?? this.npcAffectionLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// ダイアログチェーン
@JsonSerializable()
class DialogueChain {
  /// チェーンID
  final String chainId;

  /// チェーン名
  final String chainName;

  /// 説明
  final String description;

  /// 必要な親密度レベル
  final int requiredAffectionLevel;

  /// ダイアログIDのシーケンス
  final List<String> dialogueSequence;

  /// 分岐ポイント（ダイアログID → パス選択肢）
  final Map<String, List<String>> branchPoints;

  /// リワード
  final DialogueChainReward reward;

  /// アンロック条件
  final List<String>? unlockedByEvents;

  DialogueChain({
    required this.chainId,
    required this.chainName,
    required this.description,
    required this.requiredAffectionLevel,
    required this.dialogueSequence,
    required this.branchPoints,
    required this.reward,
    this.unlockedByEvents,
  });

  factory DialogueChain.fromJson(Map<String, dynamic> json) =>
      _$DialogueChainFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueChainToJson(this);
}

/// ダイアログチェーンリワード
@JsonSerializable()
class DialogueChainReward {
  /// XP獲得
  final int xpEarned;

  /// コイン獲得
  final int coinsEarned;

  /// 特別なアイテム
  final List<String>? specialItems;

  /// アンロック可能な特別ダイアログ
  final List<String>? unlocksSpecialDialogues;

  /// 達成バッジ
  final String? achievementBadge;

  DialogueChainReward({
    required this.xpEarned,
    required this.coinsEarned,
    this.specialItems,
    this.unlocksSpecialDialogues,
    this.achievementBadge,
  });

  factory DialogueChainReward.fromJson(Map<String, dynamic> json) =>
      _$DialogueChainRewardFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueChainRewardToJson(this);
}

/// NPC関係進捗
@JsonSerializable()
class RelationshipMilestone {
  /// マイルストーンID
  final String milestoneId;

  /// 名前
  final String name;

  /// 説明
  final String description;

  /// 必要な親密度
  final int requiredAffectionScore;

  /// 達成日時
  DateTime? achievedAt;

  /// 報酬
  final RelationshipMilestoneReward reward;

  RelationshipMilestone({
    required this.milestoneId,
    required this.name,
    required this.description,
    required this.requiredAffectionScore,
    this.achievedAt,
    required this.reward,
  });

  /// 達成済みか
  bool isAchieved() => achievedAt != null;

  factory RelationshipMilestone.fromJson(Map<String, dynamic> json) =>
      _$RelationshipMilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$RelationshipMilestoneToJson(this);
}

/// マイルストーン報酬
@JsonSerializable()
class RelationshipMilestoneReward {
  /// XP
  final int xp;

  /// コイン
  final int coins;

  /// バッジ
  final String? badge;

  /// スペシャルコンテンツ
  final String? specialContent;

  RelationshipMilestoneReward({
    required this.xp,
    required this.coins,
    this.badge,
    this.specialContent,
  });

  factory RelationshipMilestoneReward.fromJson(Map<String, dynamic> json) =>
      _$RelationshipMilestoneRewardFromJson(json);

  Map<String, dynamic> toJson() => _$RelationshipMilestoneRewardToJson(this);
}

/// 関係イベント
class RelationshipEvent {
  /// イベントタイプ
  final String eventType; // "affection_increase", "dialogue_unlock", "milestone_achieved"

  /// NPC ID
  final String npcId;

  /// イベント説明
  final String description;

  /// 親密度変更量
  final int affectionChange;

  /// タイムスタンプ
  final DateTime timestamp;

  /// イベント詳細
  final Map<String, dynamic> eventData;

  RelationshipEvent({
    required this.eventType,
    required this.npcId,
    required this.description,
    this.affectionChange = 0,
    required this.timestamp,
    this.eventData = const {},
  });
}
