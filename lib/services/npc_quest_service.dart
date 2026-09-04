import 'package:eigo/models/npc_quest_model.dart';
import 'package:eigo/models/npc_event_model.dart';

/// NPC クエスト管理サービス
class NPCQuestService {
  static final NPCQuestService _instance = NPCQuestService._internal();

  factory NPCQuestService.getInstance() {
    return _instance;
  }

  NPCQuestService._internal();

  // クエストキャッシュ
  final Map<String, NPCQuest> _questCache = {};

  // クエスト統計キャッシュ
  final Map<String, QuestStatistics> _statsCache = {};

  /// クエストを作成
  NPCQuest createQuest({
    required String questId,
    required String npcId,
    required String questName,
    required String description,
    required List<QuestStep> steps,
    required QuestReward reward,
    QuestCondition? condition,
    DateTime? deadline,
    bool isRepeatable = false,
  }) {
    final quest = NPCQuest(
      questId: questId,
      npcId: npcId,
      questName: questName,
      description: description,
      status: QuestStatus.available,
      steps: steps,
      reward: reward,
      condition: condition,
      startedAt: DateTime.now(),
      deadline: deadline,
      isRepeatable: isRepeatable,
    );

    _questCache[questId] = quest;
    return quest;
  }

  /// クエストを取得
  NPCQuest? getQuest(String questId) {
    return _questCache[questId];
  }

  /// NPC のすべてのクエストを取得
  List<NPCQuest> getNPCQuests(String npcId) {
    return _questCache.values.where((q) => q.npcId == npcId).toList();
  }

  /// NPC のアクティブなクエストを取得
  List<NPCQuest> getActiveQuests(String npcId) {
    return getNPCQuests(npcId).where((q) => q.isActive).toList();
  }

  /// NPC の完了したクエストを取得
  List<NPCQuest> getCompletedQuests(String npcId) {
    return getNPCQuests(npcId)
        .where((q) => q.status == QuestStatus.completed)
        .toList();
  }

  /// クエストを受け入れる
  NPCQuest acceptQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updated = quest.copyWith(
      status: QuestStatus.accepted,
      startedAt: DateTime.now(),
    );

    _questCache[questId] = updated;
    return updated;
  }

  /// クエストを進行中にする
  NPCQuest startQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updated = quest.copyWith(status: QuestStatus.in_progress);
    _questCache[questId] = updated;
    return updated;
  }

  /// 次のステップに進む
  NPCQuest advanceQuestStep(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    if (quest.currentStepIndex >= quest.steps.length - 1) {
      // すべてのステップが完了した場合、クエスト完了
      return completeQuest(questId);
    }

    final nextIndex = quest.currentStepIndex + 1;
    final updated = quest.copyWith(
      currentStepIndex: nextIndex,
      status: QuestStatus.in_progress,
    );

    _questCache[questId] = updated;
    return updated;
  }

  /// クエストステップを完了
  NPCQuest completeQuestStep(String questId, String stepId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updatedSteps = quest.steps.map((step) {
      if (step.stepId == stepId) {
        return step.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return step;
    }).toList();

    final updated = quest.copyWith(steps: updatedSteps);
    _questCache[questId] = updated;

    // 次のステップに進む
    return advanceQuestStep(questId);
  }

  /// クエストを完了
  NPCQuest completeQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updated = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );

    _questCache[questId] = updated;
    _updateStatistics(quest.npcId);

    return updated;
  }

  /// クエストを失敗
  NPCQuest failQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updated = quest.copyWith(status: QuestStatus.failed);
    _questCache[questId] = updated;
    _updateStatistics(quest.npcId);

    return updated;
  }

  /// クエストを放棄
  NPCQuest abandonQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    final updated = quest.copyWith(status: QuestStatus.abandoned);
    _questCache[questId] = updated;
    _updateStatistics(quest.npcId);

    return updated;
  }

  /// クエストをリセット（リピート用）
  NPCQuest resetQuest(String questId) {
    final quest = _questCache[questId];
    if (quest == null) {
      throw Exception('Quest $questId not found');
    }

    if (!quest.isRepeatable) {
      throw Exception('Quest $questId is not repeatable');
    }

    final resetSteps = quest.steps.map((step) {
      return step.copyWith(
        isCompleted: false,
        completedAt: null,
      );
    }).toList();

    final updated = quest.copyWith(
      status: QuestStatus.available,
      currentStepIndex: 0,
      completedAt: null,
      steps: resetSteps,
      lastRepeatAt: DateTime.now(),
    );

    _questCache[questId] = updated;
    return updated;
  }

  /// クエスト統計を生成
  QuestStatistics generateStatistics(String npcId) {
    final quests = getNPCQuests(npcId);

    final completedCount = quests
        .where((q) => q.status == QuestStatus.completed)
        .length;
    final activeCount = quests.where((q) => q.isActive).length;
    final failedCount = quests.where((q) => q.status == QuestStatus.failed).length;
    final abandonedCount =
        quests.where((q) => q.status == QuestStatus.abandoned).length;

    var totalXp = 0;
    var totalGold = 0;
    var totalAffection = 0;
    DateTime? lastCompletedAt;

    for (final quest in quests) {
      if (quest.status == QuestStatus.completed) {
        totalXp += quest.reward.xpReward;
        totalGold += quest.reward.goldReward;
        totalAffection += quest.reward.affectionBonus;

        if (lastCompletedAt == null || quest.completedAt!.isAfter(lastCompletedAt)) {
          lastCompletedAt = quest.completedAt;
        }
      }
    }

    final stats = QuestStatistics(
      npcId: npcId,
      completedCount: completedCount,
      activeCount: activeCount,
      failedCount: failedCount,
      abandonedCount: abandonedCount,
      totalXpEarned: totalXp,
      totalGoldEarned: totalGold,
      totalAffectionEarned: totalAffection,
      lastCompletedAt: lastCompletedAt,
    );

    _statsCache[npcId] = stats;
    return stats;
  }

  /// クエスト統計を取得
  QuestStatistics? getStatistics(String npcId) {
    return _statsCache[npcId];
  }

  /// クエストが期限切れか確認
  bool isQuestDeadlineExpired(String questId) {
    final quest = _questCache[questId];
    if (quest == null || quest.deadline == null) {
      return false;
    }

    return DateTime.now().isAfter(quest.deadline!);
  }

  /// 期限切れのクエストを自動的に失敗させる
  void checkAndFailExpiredQuests(String npcId) {
    final activeQuests = getActiveQuests(npcId);

    for (final quest in activeQuests) {
      if (isQuestDeadlineExpired(quest.questId)) {
        failQuest(quest.questId);
      }
    }
  }

  /// クエストを削除
  void removeQuest(String questId) {
    _questCache.remove(questId);
  }

  /// NPC のすべてのクエストを削除
  void removeNPCQuests(String npcId) {
    final quests = getNPCQuests(npcId);
    for (final quest in quests) {
      removeQuest(quest.questId);
    }
  }

  /// 統計を更新
  void _updateStatistics(String npcId) {
    generateStatistics(npcId);
  }

  /// キャッシュをクリア
  void clearCache() {
    _questCache.clear();
    _statsCache.clear();
  }
}
