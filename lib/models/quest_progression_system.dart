import 'package:eigo/models/event_system.dart';

/// クエストシステム
/// マルチステップのクエスト進行、ブランチング、リワード管理

/// クエスト管理システム
class QuestProgressionSystem {
  static final QuestProgressionSystem _instance =
      QuestProgressionSystem._internal();

  factory QuestProgressionSystem.getInstance() {
    return _instance;
  }

  QuestProgressionSystem._internal();

  // プレイヤーが受けたクエスト: quest_id -> QuestProgress
  final Map<String, QuestProgress> _activeQuests = {};

  // 完了したクエスト: quest_id -> completion timestamp
  final Map<String, DateTime> _completedQuests = {};

  // クエスト定義: quest_id -> QuestDefinition
  final Map<String, QuestDefinition> _questDefinitions = {};

  final GameEventSystem _eventSystem = GameEventSystem.getInstance();

  /// システムを初期化
  void initialize() {
    _activeQuests.clear();
    _completedQuests.clear();
    _questDefinitions.clear();
    _initializeAllQuests();
  }

  /// すべてのクエスト定義を初期化
  void _initializeAllQuests() {
    // Aria's quests
    _registerQuest(QuestDefinition(
      id: 'aria_fireball_001',
      title: 'Learn Fireball',
      description: 'Master the basic fireball spell from Aria',
      giverNPCId: 'aria_001',
      region: 'Mage Tower',
      difficultyLevel: 1,
      steps: [
        QuestStep(
          id: 'aria_fireball_meet',
          title: 'Meet Aria at the Tower',
          description: 'Find Aria in the Mage Tower',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'aria_fireball_learn',
          title: 'Practice Fireball Spell',
          description: 'Learn the fireball incantation and gestures',
          type: QuestStepType.skill,
        ),
        QuestStep(
          id: 'aria_fireball_test',
          title: 'Demonstrate Mastery',
          description: 'Show Aria you can cast fireball',
          type: QuestStepType.combat,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 250,
        affectionGain: {
          'aria_001': 20,
        },
        factionRepGain: {
          'mage_tower': 30,
        },
        itemRewards: ['Mage Pendant'],
      ),
      preRequisites: [],
      followUpQuests: ['aria_ice_storm_001'],
    ));

    // Kai's quests
    _registerQuest(QuestDefinition(
      id: 'kai_bandits_001',
      title: 'Defeat the Bandits',
      description: 'Help Kai protect the village from bandits',
      giverNPCId: 'kai_004',
      region: 'Adventurers Village',
      difficultyLevel: 2,
      steps: [
        QuestStep(
          id: 'kai_bandits_meet',
          title: 'Report to Kai',
          description: 'Meet Kai at the village entrance',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'kai_bandits_scout',
          title: 'Scout Bandit Location',
          description: 'Find where the bandits are hiding',
          type: QuestStepType.exploration,
        ),
        QuestStep(
          id: 'kai_bandits_fight',
          title: 'Defeat the Bandits',
          description: 'Defeat the bandit leader and their crew',
          type: QuestStepType.combat,
        ),
        QuestStep(
          id: 'kai_bandits_return',
          title: 'Return to Kai',
          description: 'Report your success to Kai',
          type: QuestStepType.dialogue,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 500,
        affectionGain: {
          'kai_004': 30,
        },
        factionRepGain: {
          'adventurers_guild': 40,
        },
        itemRewards: ['Warrior Gauntlets'],
      ),
      preRequisites: [],
      followUpQuests: ['kai_legendary_sword_001'],
    ));

    // Luna's quests
    _registerQuest(QuestDefinition(
      id: 'luna_research_001',
      title: 'Research Ancient Spells',
      description: 'Help Luna gather research on ancient magical texts',
      giverNPCId: 'luna_002',
      region: 'Mage Tower',
      difficultyLevel: 1,
      steps: [
        QuestStep(
          id: 'luna_research_meet',
          title: 'Meet Luna at the Library',
          description: 'Find Luna in the Mage Tower library',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'luna_research_gather',
          title: 'Gather Ancient Texts',
          description: 'Collect 5 ancient texts from the tower',
          type: QuestStepType.collection,
        ),
        QuestStep(
          id: 'luna_research_translate',
          title: 'Decode Runes',
          description: 'Help Luna decipher the ancient script',
          type: QuestStepType.puzzle,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 300,
        affectionGain: {
          'luna_002': 25,
        },
        factionRepGain: {
          'mage_tower': 35,
        },
        itemRewards: ['Scholar\'s Glasses'],
      ),
      preRequisites: [],
      followUpQuests: ['luna_lost_books_001'],
    ));

    // Thorn's quests
    _registerQuest(QuestDefinition(
      id: 'thorn_herbs_001',
      title: 'Gather Healing Herbs',
      description: 'Collect rare herbs for Thorn\'s medical supplies',
      giverNPCId: 'thorn_006',
      region: 'Adventurers Village',
      difficultyLevel: 1,
      steps: [
        QuestStep(
          id: 'thorn_herbs_meet',
          title: 'Meet Thorn',
          description: 'Visit Thorn at the healing clinic',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'thorn_herbs_collect',
          title: 'Collect Rare Herbs',
          description: 'Gather moonflower and silverleaf from the forest',
          type: QuestStepType.collection,
        ),
        QuestStep(
          id: 'thorn_herbs_deliver',
          title: 'Deliver to Thorn',
          description: 'Return the herbs to Thorn',
          type: QuestStepType.dialogue,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 200,
        affectionGain: {
          'thorn_006': 20,
        },
        factionRepGain: {
          'adventurers_guild': 25,
        },
        itemRewards: ['Healer\'s Satchel'],
      ),
      preRequisites: [],
      followUpQuests: ['thorn_antidote_001'],
    ));

    // Zephyr's quests
    _registerQuest(QuestDefinition(
      id: 'zephyr_trade_001',
      title: 'Deliver Trade Goods',
      description: 'Help Zephyr deliver goods to neighboring towns',
      giverNPCId: 'zephyr_007',
      region: 'Merchants City',
      difficultyLevel: 1,
      steps: [
        QuestStep(
          id: 'zephyr_trade_meet',
          title: 'Meet Zephyr',
          description: 'Visit Zephyr at the market',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'zephyr_trade_load',
          title: 'Load the Cargo',
          description: 'Prepare goods for transport',
          type: QuestStepType.task,
        ),
        QuestStep(
          id: 'zephyr_trade_deliver',
          title: 'Deliver to Three Towns',
          description: 'Travel to three different towns and deliver goods',
          type: QuestStepType.exploration,
        ),
        QuestStep(
          id: 'zephyr_trade_return',
          title: 'Return to Zephyr',
          description: 'Report back with profits',
          type: QuestStepType.dialogue,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 350,
        affectionGain: {
          'zephyr_007': 15,
        },
        factionRepGain: {
          'merchant_cartel': 40,
        },
        itemRewards: ['Merchant\'s Ring'],
        goldReward: 500,
      ),
      preRequisites: [],
      followUpQuests: ['zephyr_monopoly_001'],
    ));

    // Isabella's quests
    _registerQuest(QuestDefinition(
      id: 'isabella_stories_001',
      title: 'Collect Stories for the Bard',
      description: 'Help Isabella gather interesting stories from around the world',
      giverNPCId: 'isabella_010',
      region: 'Merchants City',
      difficultyLevel: 1,
      steps: [
        QuestStep(
          id: 'isabella_stories_meet',
          title: 'Meet Isabella',
          description: 'Find Isabella at the tavern',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'isabella_stories_gather',
          title: 'Gather 5 Stories',
          description: 'Talk to different NPCs and collect their stories',
          type: QuestStepType.dialogue,
        ),
        QuestStep(
          id: 'isabella_stories_perform',
          title: 'Attend Performance',
          description: 'Watch Isabella perform the stories at the festival',
          type: QuestStepType.dialogue,
        ),
      ],
      rewards: QuestReward(
        experienceGain: 250,
        affectionGain: {
          'isabella_010': 25,
        },
        factionRepGain: {
          'merchant_cartel': 30,
        },
        itemRewards: ['Bard\'s Lute'],
      ),
      preRequisites: [],
      followUpQuests: ['isabella_festival_001'],
    ));
  }

  /// クエスト定義を登録
  void _registerQuest(QuestDefinition quest) {
    _questDefinitions[quest.id] = quest;
  }

  /// クエストを受け入れる
  void acceptQuest(String questId) {
    final definition = _questDefinitions[questId];
    if (definition == null) return;

    _activeQuests[questId] = QuestProgress(
      questDefinition: definition,
      startedAt: DateTime.now(),
      currentStepIndex: 0,
      completedSteps: [],
    );

    // イベントを発火
    _eventSystem.fireEvent(GameEvent(
      id: 'quest_accepted_$questId',
      type: EventType.questAccepted,
      title: 'Quest Accepted: ${definition.title}',
      description: definition.description,
      data: {
        'questId': questId,
        'questTitle': definition.title,
        'giverNPCId': definition.giverNPCId,
      },
    ));
  }

  /// クエストステップを完了
  void completeStep(String questId, String stepId) {
    final progress = _activeQuests[questId];
    if (progress == null) return;

    final currentStep = progress.questDefinition.steps[progress.currentStepIndex];
    if (currentStep.id != stepId) return;

    progress.completedSteps.add(stepId);

    // 次のステップへ
    if (progress.currentStepIndex < progress.questDefinition.steps.length - 1) {
      progress.currentStepIndex++;
    } else {
      // クエスト完了
      completeQuest(questId);
    }
  }

  /// クエストを完了
  void completeQuest(String questId) {
    final progress = _activeQuests[questId];
    if (progress == null) return;

    // 完了済みマップに移動
    _completedQuests[questId] = DateTime.now();
    _activeQuests.remove(questId);

    final definition = progress.questDefinition;

    // イベントを発火
    _eventSystem.fireEvent(GameEvent(
      id: 'quest_completed_$questId',
      type: EventType.questCompleted,
      title: 'Quest Completed: ${definition.title}',
      description: 'You have completed ${definition.title}!',
      data: {
        'questId': questId,
        'questTitle': definition.title,
        'reward': definition.rewards.toMap(),
      },
    ));
  }

  /// アクティブなクエストを取得
  QuestProgress? getActiveQuest(String questId) {
    return _activeQuests[questId];
  }

  /// すべてのアクティブなクエストを取得
  List<QuestProgress> getAllActiveQuests() {
    return _activeQuests.values.toList();
  }

  /// クエスト定義を取得
  QuestDefinition? getQuestDefinition(String questId) {
    return _questDefinitions[questId];
  }

  /// クエストが完了済みかチェック
  bool isQuestCompleted(String questId) {
    return _completedQuests.containsKey(questId);
  }

  /// 完了したクエストの数
  int getCompletedQuestCount() {
    return _completedQuests.length;
  }

  /// NPCのクエストをすべて取得
  List<QuestDefinition> getNPCQuests(String npcId) {
    return _questDefinitions.values
        .where((q) => q.giverNPCId == npcId)
        .toList();
  }

  /// 利用可能なクエストを取得（前置条件を満たしている）
  List<QuestDefinition> getAvailableQuests() {
    return _questDefinitions.values.where((quest) {
      // 前置条件をチェック
      for (final prereq in quest.preRequisites) {
        if (!isQuestCompleted(prereq)) {
          return false;
        }
      }
      // まだ受けていないクエスト
      return !_activeQuests.containsKey(quest.id) &&
          !_completedQuests.containsKey(quest.id);
    }).toList();
  }

  /// フォローアップクエストを取得
  List<QuestDefinition> getFollowUpQuests(String questId) {
    final definition = _questDefinitions[questId];
    if (definition == null) return [];

    return definition.followUpQuests
        .map((id) => _questDefinitions[id])
        .whereType<QuestDefinition>()
        .toList();
  }

  /// クエスト進捗を取得
  double getQuestProgress(String questId) {
    final progress = _activeQuests[questId];
    if (progress == null) return 0.0;

    return progress.currentStepIndex /
        progress.questDefinition.steps.length;
  }
}

/// クエスト定義
class QuestDefinition {
  final String id;
  final String title;
  final String description;
  final String giverNPCId;
  final String region;
  final int difficultyLevel; // 1-5
  final List<QuestStep> steps;
  final QuestReward rewards;
  final List<String> preRequisites; // 前置条件となるクエストID
  final List<String> followUpQuests; // フォローアップクエストID

  QuestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.giverNPCId,
    required this.region,
    required this.difficultyLevel,
    required this.steps,
    required this.rewards,
    required this.preRequisites,
    required this.followUpQuests,
  });

  /// 所要時間を推定（ステップ数 * 5分）
  int getEstimatedMinutes() {
    return steps.length * 5;
  }

  /// 難易度を文字列で表示
  String getDifficultyText() {
    switch (difficultyLevel) {
      case 1:
        return 'Easy';
      case 2:
        return 'Normal';
      case 3:
        return 'Hard';
      case 4:
        return 'Very Hard';
      case 5:
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }
}

/// クエストステップ
class QuestStep {
  final String id;
  final String title;
  final String description;
  final QuestStepType type;

  QuestStep({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });

  /// ステップタイプを文字列で表示
  String getTypeText() {
    switch (type) {
      case QuestStepType.dialogue:
        return 'Talk to NPC';
      case QuestStepType.combat:
        return 'Defeat Enemies';
      case QuestStepType.collection:
        return 'Collect Items';
      case QuestStepType.exploration:
        return 'Explore Area';
      case QuestStepType.skill:
        return 'Learn Skill';
      case QuestStepType.puzzle:
        return 'Solve Puzzle';
      case QuestStepType.task:
        return 'Complete Task';
    }
  }
}

/// クエストステップのタイプ
enum QuestStepType {
  dialogue, // NPCとの会話
  combat, // 敵との戦闘
  collection, // アイテム収集
  exploration, // 探索
  skill, // スキル習得
  puzzle, // パズル解定
  task, // その他タスク
}

/// クエスト進捗
class QuestProgress {
  final QuestDefinition questDefinition;
  final DateTime startedAt;
  int currentStepIndex;
  final List<String> completedSteps;

  QuestProgress({
    required this.questDefinition,
    required this.startedAt,
    required this.currentStepIndex,
    required this.completedSteps,
  });

  /// 現在のステップを取得
  QuestStep getCurrentStep() {
    return questDefinition.steps[currentStepIndex];
  }

  /// 進捗率を取得 (0.0-1.0)
  double getProgressPercentage() {
    return currentStepIndex / questDefinition.steps.length;
  }

  /// 進行時間を取得
  Duration getElapsedTime() {
    return DateTime.now().difference(startedAt);
  }
}

/// クエストリワード
class QuestReward {
  final int experienceGain;
  final Map<String, int> affectionGain; // NPC ID -> affection gain
  final Map<String, int> factionRepGain; // Faction ID -> rep gain
  final List<String> itemRewards;
  final int goldReward;

  QuestReward({
    required this.experienceGain,
    required this.affectionGain,
    required this.factionRepGain,
    this.itemRewards = const [],
    this.goldReward = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'experience': experienceGain,
      'affection': affectionGain,
      'factionRep': factionRepGain,
      'items': itemRewards,
      'gold': goldReward,
    };
  }
}

/// クエスト結果
class QuestOutcome {
  final String questId;
  final String questTitle;
  final QuestResult result;
  final DateTime completedAt;
  final QuestReward reward;

  QuestOutcome({
    required this.questId,
    required this.questTitle,
    required this.result,
    required this.completedAt,
    required this.reward,
  });

  String getResultText() {
    switch (result) {
      case QuestResult.success:
        return 'Quest Completed Successfully!';
      case QuestResult.partial:
        return 'Quest Completed (Partial Success)';
      case QuestResult.failed:
        return 'Quest Failed';
      case QuestResult.abandoned:
        return 'Quest Abandoned';
    }
  }
}

/// クエスト結果のタイプ
enum QuestResult {
  success, // 完全成功
  partial, // 部分的成功
  failed, // 失敗
  abandoned, // 放棄
}
