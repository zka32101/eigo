import 'package:eigo/models/npc_relationship_model.dart';

/// NPC関係管理サービス
class NPCRelationshipService {
  static final NPCRelationshipService _instance =
      NPCRelationshipService._internal();

  factory NPCRelationshipService.getInstance() {
    return _instance;
  }

  NPCRelationshipService._internal();

  /// 新しい関係を初期化
  NPCRelationship initializeRelationship(
    String npcId,
    String userId,
  ) {
    return NPCRelationship(
      npcId: npcId,
      userId: userId,
      affectionScore: 0,
      totalInteractions: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ダイアログ後に親密度を更新
  NPCRelationship updateAffectionAfterDialogue(
    NPCRelationship relationship,
    int score,
    String? feedback,
  ) {
    int affectionGain = 0;

    // スコアに基づいて親密度を計算
    if (score >= 90) {
      affectionGain = 10;
    } else if (score >= 80) {
      affectionGain = 7;
    } else if (score >= 70) {
      affectionGain = 5;
    } else if (score >= 60) {
      affectionGain = 3;
    } else if (score >= 50) {
      affectionGain = 1;
    }

    final updatedRelationship = relationship.copyWith();
    updatedRelationship.increaseAffection(affectionGain);
    updatedRelationship.totalInteractions += 1;
    updatedRelationship.lastInteractionTime = DateTime.now();

    if (feedback != null) {
      updatedRelationship.addAffectionEvent(feedback);
    }

    return updatedRelationship;
  }

  /// 関係ステータスを取得
  RelationshipStatus getRelationshipStatus(NPCRelationship relationship) {
    return relationship.getStatus();
  }

  /// ダイアログをアンロック（親密度ベース）
  NPCRelationship unlockDialoguesForAffectionLevel(
    NPCRelationship relationship,
    List<DialogueChain> availableChains,
  ) {
    final updatedRelationship = relationship.copyWith();

    for (final chain in availableChains) {
      if (relationship.affectionScore >= chain.requiredAffectionLevel &&
          !updatedRelationship.unlockedDialogues.contains(chain.chainId)) {
        updatedRelationship.unlockDialogue(chain.chainId);
      }
    }

    return updatedRelationship;
  }

  /// マイルストーンをチェック
  List<RelationshipMilestone> checkMilestones(
    NPCRelationship relationship,
    List<RelationshipMilestone> milestones,
  ) {
    final achievedMilestones = <RelationshipMilestone>[];

    for (final milestone in milestones) {
      if (relationship.affectionScore >= milestone.requiredAffectionScore &&
          !milestone.isAchieved()) {
        achievedMilestones.add(
          milestone.copyWith(
            achievedAt: DateTime.now(),
          ),
        );
      }
    }

    return achievedMilestones;
  }

  /// ダイアログチェーンの進捗を計算
  double getDialogueChainProgress(
    NPCRelationship relationship,
    DialogueChain chain,
  ) {
    if (relationship.unlockedDialogues.isEmpty) return 0.0;

    int completedDialogues = 0;
    for (final dialogueId in chain.dialogueSequence) {
      if (relationship.unlockedDialogues.contains(dialogueId)) {
        completedDialogues++;
      }
    }

    return completedDialogues / chain.dialogueSequence.length;
  }

  /// 特別なダイアログをアンロック
  NPCRelationship unlockSpecialDialogue(
    NPCRelationship relationship,
    String dialogueId,
  ) {
    final updatedRelationship = relationship.copyWith();
    updatedRelationship.unlockDialogue(dialogueId);
    updatedRelationship.addAffectionEvent('Special dialogue unlocked: $dialogueId');
    return updatedRelationship;
  }

  /// ダイアログの選択を記録
  NPCRelationship recordDialogueChoice(
    NPCRelationship relationship,
    String dialogueId,
    String choicePath,
  ) {
    final updatedRelationship = relationship.copyWith();
    updatedRelationship.recordDialoguePath(dialogueId, choicePath);
    return updatedRelationship;
  }

  /// NPC視点の親密度を更新
  NPCRelationship updateNPCAffection(
    NPCRelationship relationship,
    int changeAmount,
    String reason,
  ) {
    final updatedRelationship = relationship.copyWith();
    updatedRelationship.npcAffectionLevel =
        (updatedRelationship.npcAffectionLevel + changeAmount).clamp(0, 100);
    updatedRelationship.addAffectionEvent('NPC affection: $reason');
    return updatedRelationship;
  }

  /// プレイヤー視点の親密度を更新
  NPCRelationship updatePlayerAffection(
    NPCRelationship relationship,
    int changeAmount,
    String reason,
  ) {
    final updatedRelationship = relationship.copyWith();
    updatedRelationship.playerAffectionLevel =
        (updatedRelationship.playerAffectionLevel + changeAmount).clamp(0, 100);
    updatedRelationship.addAffectionEvent('Player affection: $reason');
    return updatedRelationship;
  }

  /// 関係イベントを作成
  RelationshipEvent createRelationshipEvent(
    String eventType,
    String npcId,
    String description,
    {int affectionChange = 0,
    Map<String, dynamic>? eventData}) {
    return RelationshipEvent(
      eventType: eventType,
      npcId: npcId,
      description: description,
      affectionChange: affectionChange,
      timestamp: DateTime.now(),
      eventData: eventData ?? {},
    );
  }

  /// 関係サマリーを生成
  RelationshipSummary generateRelationshipSummary(
    NPCRelationship relationship,
  ) {
    return RelationshipSummary(
      npcId: relationship.npcId,
      status: relationship.getStatus(),
      affectionScore: relationship.affectionScore,
      totalInteractions: relationship.totalInteractions,
      unlockedDialoguesCount: relationship.unlockedDialogues.length,
      achievementsCount: relationship.specialEventAchievements.length,
      lastInteractionTime: relationship.lastInteractionTime,
    );
  }

  /// 複数のNPCの関係を比較
  List<NPCRelationship> rankRelationshipsByAffection(
    List<NPCRelationship> relationships,
  ) {
    final sorted = List<NPCRelationship>.from(relationships);
    sorted.sort((a, b) => b.affectionScore.compareTo(a.affectionScore));
    return sorted;
  }

  /// 関係をリセット
  NPCRelationship resetRelationship(
    NPCRelationship relationship,
  ) {
    return NPCRelationship(
      npcId: relationship.npcId,
      userId: relationship.userId,
      affectionScore: 0,
      totalInteractions: 0,
      createdAt: relationship.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 関係サマリー
class RelationshipSummary {
  final String npcId;
  final RelationshipStatus status;
  final int affectionScore;
  final int totalInteractions;
  final int unlockedDialoguesCount;
  final int achievementsCount;
  final DateTime? lastInteractionTime;

  RelationshipSummary({
    required this.npcId,
    required this.status,
    required this.affectionScore,
    required this.totalInteractions,
    required this.unlockedDialoguesCount,
    required this.achievementsCount,
    this.lastInteractionTime,
  });

  /// 関係の進捗率（0.0-1.0）
  double getProgressPercentage() {
    return affectionScore / 100.0;
  }

  /// 次のステータスまでの距離
  int getPointsToNextStatus() {
    final nextThreshold = _getNextStatusThreshold(affectionScore);
    return (nextThreshold - affectionScore).clamp(0, 100);
  }

  int _getNextStatusThreshold(int currentScore) {
    if (currentScore < 10) return 10;
    if (currentScore < 25) return 25;
    if (currentScore < 50) return 50;
    if (currentScore < 75) return 75;
    if (currentScore < 90) return 90;
    return 100;
  }
}

/// ダイアログチェーンのコピー拡張
extension DialogueChainCopy on RelationshipMilestone {
  RelationshipMilestone copyWith({
    String? milestoneId,
    String? name,
    String? description,
    int? requiredAffectionScore,
    DateTime? achievedAt,
    RelationshipMilestoneReward? reward,
  }) {
    return RelationshipMilestone(
      milestoneId: milestoneId ?? this.milestoneId,
      name: name ?? this.name,
      description: description ?? this.description,
      requiredAffectionScore:
          requiredAffectionScore ?? this.requiredAffectionScore,
      achievedAt: achievedAt ?? this.achievedAt,
      reward: reward ?? this.reward,
    );
  }
}
