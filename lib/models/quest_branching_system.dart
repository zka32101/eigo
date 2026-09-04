/// クエストブランチングシステム
/// プレイヤーの選択に基づいたクエスト結果の分岐

/// ブランチングクエストシステム
class QuestBranchingSystem {
  static final QuestBranchingSystem _instance =
      QuestBranchingSystem._internal();

  factory QuestBranchingSystem.getInstance() {
    return _instance;
  }

  QuestBranchingSystem._internal();

  // クエストの分岐パス: quest_id -> list of branches
  final Map<String, List<QuestBranch>> _questBranches = {};

  // プレイヤーが選んだ分岐: quest_id -> chosen branch id
  final Map<String, String> _playerChoices = {};

  /// システムを初期化
  void initialize() {
    _questBranches.clear();
    _playerChoices.clear();
    _initializeAllBranches();
  }

  /// すべてのクエスト分岐を初期化
  void _initializeAllBranches() {
    // Aria's fireball quest branches
    _registerBranch('aria_fireball_001', [
      QuestBranch(
        id: 'aria_fireball_eager',
        title: 'Eager Learner',
        description: 'Learn fireball quickly with high interest',
        choice: 'Show enthusiasm for learning magic',
        successRate: 100,
        affectionGain: {
          'aria_001': 30, // Higher affection for eager approach
        },
        factionRepGain: {
          'mage_tower': 40,
        },
        completionText: 'Aria is impressed by your enthusiasm and teaches you advanced techniques.',
      ),
      QuestBranch(
        id: 'aria_fireball_cautious',
        title: 'Cautious Approach',
        description: 'Learn fireball carefully and thoroughly',
        choice: 'Ask questions and proceed carefully',
        successRate: 100,
        affectionGain: {
          'aria_001': 15,
        },
        factionRepGain: {
          'mage_tower': 35,
        },
        completionText: 'Aria appreciates your careful approach and respects your caution.',
      ),
    ]);

    // Kai's bandit quest branches
    _registerBranch('kai_bandits_001', [
      QuestBranch(
        id: 'kai_bandits_direct',
        title: 'Direct Assault',
        description: 'Attack the bandits head-on with force',
        choice: 'Charge in and defeat them directly',
        successRate: 85,
        affectionGain: {
          'kai_004': 40, // Kai loves directness
        },
        factionRepGain: {
          'adventurers_guild': 50,
        },
        completionText: 'Kai admires your courage and warrior spirit. You are worthy allies!',
      ),
      QuestBranch(
        id: 'kai_bandits_stealth',
        title: 'Stealth Approach',
        description: 'Sneak up and ambush the bandits',
        choice: 'Scout and plan a careful ambush',
        successRate: 95,
        affectionGain: {
          'kai_004': 20,
          'eloise_005': 25, // Eloise respects stealth
        },
        factionRepGain: {
          'adventurers_guild': 40,
        },
        completionText: 'The bandits never saw you coming. Kai respects your cunning tactics.',
      ),
      QuestBranch(
        id: 'kai_bandits_negotiate',
        title: 'Negotiation',
        description: 'Try to convince the bandits to stand down',
        choice: 'Attempt to negotiate with the bandits',
        successRate: 40,
        affectionGain: {
          'kai_004': -5, // Kai dislikes negotiation
          'thorn_006': 30, // Thorn appreciates peaceful resolution
        },
        factionRepGain: {
          'adventurers_guild': 15,
        },
        completionText: 'Most bandits flee, avoiding bloodshed. A pyrrhic victory.',
      ),
    ]);

    // Luna's research quest branches
    _registerBranch('luna_research_001', [
      QuestBranch(
        id: 'luna_research_thorough',
        title: 'Thorough Researcher',
        description: 'Gather all texts and translate perfectly',
        choice: 'Take time to gather every single text',
        successRate: 100,
        affectionGain: {
          'luna_002': 35, // Luna loves thorough work
        },
        factionRepGain: {
          'mage_tower': 45,
        },
        completionText: 'Luna is delighted with your thoroughness. Your research is impeccable.',
      ),
      QuestBranch(
        id: 'luna_research_quick',
        title: 'Quick Collection',
        description: 'Gather texts quickly and move on',
        choice: 'Collect just enough texts to proceed',
        successRate: 100,
        affectionGain: {
          'luna_002': 10,
        },
        factionRepGain: {
          'mage_tower': 25,
        },
        completionText: 'You gathered the texts, but Luna notes they could be more comprehensive.',
      ),
    ]);

    // Thorn's herb quest branches
    _registerBranch('thorn_herbs_001', [
      QuestBranch(
        id: 'thorn_herbs_extra',
        title: 'Extra Care',
        description: 'Gather herbs and find rare variants',
        choice: 'Search extra thoroughly for rare herbs',
        successRate: 100,
        affectionGain: {
          'thorn_006': 30, // Thorn appreciates extra effort
        },
        factionRepGain: {
          'adventurers_guild': 35,
        },
        completionText: 'Thorn is thrilled! The rare herbs will help so many people.',
      ),
      QuestBranch(
        id: 'thorn_herbs_standard',
        title: 'Standard Gathering',
        description: 'Gather the requested herbs only',
        choice: 'Collect just what was asked for',
        successRate: 100,
        affectionGain: {
          'thorn_006': 15,
        },
        factionRepGain: {
          'adventurers_guild': 25,
        },
        completionText: 'Thorn thanks you for the herbs. They will help the sick villagers.',
      ),
    ]);

    // Zephyr's trade quest branches
    _registerBranch('zephyr_trade_001', [
      QuestBranch(
        id: 'zephyr_trade_negotiate',
        title: 'Master Negotiator',
        description: 'Negotiate the best possible prices',
        choice: 'Use diplomacy to get premium prices',
        successRate: 90,
        affectionGain: {
          'zephyr_007': 35, // Zephyr loves profit
        },
        factionRepGain: {
          'merchant_cartel': 50,
        },
        goldReward: 750,
        completionText: 'Zephyr is astounded! You\'ve made incredible profits. The cartel will hear of this!',
      ),
      QuestBranch(
        id: 'zephyr_trade_honest',
        title: 'Honest Merchant',
        description: 'Complete trade at fair prices',
        choice: 'Trade honestly at reasonable prices',
        successRate: 100,
        affectionGain: {
          'zephyr_007': 15,
          'thorn_006': 20, // Thorn respects honesty
        },
        factionRepGain: {
          'merchant_cartel': 35,
        },
        goldReward: 500,
        completionText: 'Zephyr appreciates your honesty. The clients are satisfied too.',
      ),
      QuestBranch(
        id: 'zephyr_trade_aggressive',
        title: 'Aggressive Tactics',
        description: 'Use pressure tactics to maximize profit',
        choice: 'Apply pressure to maximize margins',
        successRate: 70,
        affectionGain: {
          'zephyr_007': 25,
        },
        factionRepGain: {
          'merchant_cartel': 45,
        },
        goldReward: 600,
        completionText: 'You made good profits, but some clients seem unhappy with the terms.',
      ),
    ]);

    // Isabella's story quest branches
    _registerBranch('isabella_stories_001', [
      QuestBranch(
        id: 'isabella_stories_heroic',
        title: 'Epic Tales',
        description: 'Gather heroic and adventurous stories',
        choice: 'Seek out tales of great adventures',
        successRate: 100,
        affectionGain: {
          'isabella_010': 30, // Isabella loves exciting stories
          'kai_004': 25, // Kai likes heroic tales
        },
        factionRepGain: {
          'merchant_cartel': 40,
        },
        completionText: 'Isabella performs the most thrilling tales! The crowd is mesmerized!',
      ),
      QuestBranch(
        id: 'isabella_stories_heartfelt',
        title: 'Heartfelt Stories',
        description: 'Gather emotional and personal stories',
        choice: 'Seek out touching and emotional stories',
        successRate: 100,
        affectionGain: {
          'isabella_010': 35, // Isabella truly loves heartfelt stories
          'thorn_006': 30, // Thorn appreciates compassion
        },
        factionRepGain: {
          'merchant_cartel': 45,
        },
        completionText: 'Isabella is moved to tears. Her performance touches everyone\'s heart!',
      ),
      QuestBranch(
        id: 'isabella_stories_mysterious',
        title: 'Mysterious Tales',
        description: 'Gather mysterious and puzzling stories',
        choice: 'Seek out mysterious and enigmatic stories',
        successRate: 100,
        affectionGain: {
          'isabella_010': 25,
          'luna_002': 20, // Luna likes intellectual stories
        },
        factionRepGain: {
          'merchant_cartel': 40,
        },
        completionText: 'Isabella weaves the mysterious tales into an intriguing narrative!',
      ),
    ]);
  }

  /// クエスト分岐を登録
  void _registerBranch(String questId, List<QuestBranch> branches) {
    _questBranches[questId] = branches;
  }

  /// クエストの利用可能な分岐を取得
  List<QuestBranch> getQuestBranches(String questId) {
    return _questBranches[questId] ?? [];
  }

  /// プレイヤーが分岐を選択
  void chooseBranch(String questId, String branchId) {
    final branches = _questBranches[questId];
    if (branches == null) return;

    // 有効な分岐かチェック
    if (branches.any((b) => b.id == branchId)) {
      _playerChoices[questId] = branchId;
    }
  }

  /// プレイヤーが選んだ分岐を取得
  QuestBranch? getChosenBranch(String questId) {
    final branchId = _playerChoices[questId];
    if (branchId == null) return null;

    final branches = _questBranches[questId];
    return branches?.firstWhere(
      (b) => b.id == branchId,
      orElse: () => null as QuestBranch,
    );
  }

  /// 分岐に基づいた報酬を計算
  QuestBranchReward calculateReward(String questId) {
    final branch = getChosenBranch(questId);
    if (branch == null) return QuestBranchReward();

    // 成功判定
    final succeeded = _rollSuccess(branch.successRate);

    return QuestBranchReward(
      branchId: branch.id,
      branchTitle: branch.title,
      succeeded: succeeded,
      completionText: branch.completionText,
      affectionGain: succeeded ? branch.affectionGain : {},
      factionRepGain: succeeded ? branch.factionRepGain : {},
      goldReward: succeeded ? branch.goldReward : 0,
    );
  }

  /// 成功判定（100を上限とする確率）
  bool _rollSuccess(int successRate) {
    final chance = (successRate / 100.0).clamp(0.0, 1.0);
    return (DateTime.now().millisecondsSinceEpoch % 100) < (chance * 100);
  }

  /// すべてのプレイヤー選択を取得
  Map<String, String> getAllPlayerChoices() {
    return Map.from(_playerChoices);
  }
}

/// クエスト分岐
class QuestBranch {
  final String id;
  final String title;
  final String description;
  final String choice; // プレイヤーの選択肢テキスト
  final int successRate; // 成功確率 (0-100)
  final Map<String, int> affectionGain; // NPC ID -> affection
  final Map<String, int> factionRepGain; // Faction ID -> rep
  final int goldReward;
  final String completionText;

  QuestBranch({
    required this.id,
    required this.title,
    required this.description,
    required this.choice,
    required this.successRate,
    required this.affectionGain,
    required this.factionRepGain,
    this.goldReward = 0,
    required this.completionText,
  });

  /// 難易度を推定
  String getDifficultyHint() {
    if (successRate >= 95) return '(Easy)';
    if (successRate >= 80) return '(Normal)';
    if (successRate >= 60) return '(Hard)';
    return '(Very Hard)';
  }
}

/// クエスト分岐報酬
class QuestBranchReward {
  final String branchId;
  final String branchTitle;
  final bool succeeded;
  final String completionText;
  final Map<String, int> affectionGain;
  final Map<String, int> factionRepGain;
  final int goldReward;

  QuestBranchReward({
    this.branchId = '',
    this.branchTitle = '',
    this.succeeded = false,
    this.completionText = '',
    this.affectionGain = const {},
    this.factionRepGain = const {},
    this.goldReward = 0,
  });

  String getResultText() {
    if (!succeeded) {
      return 'Your approach didn\'t work as planned...';
    }
    return completionText;
  }
}

/// グループクエスト用の情報
class GroupQuestInfo {
  final String questId;
  final List<String> participantNPCs; // クエストに参加するNPC
  final String scenario; // グループシナリオの説明
  final List<String> recommendedNPCs; // 推奨されるNPC

  GroupQuestInfo({
    required this.questId,
    required this.participantNPCs,
    required this.scenario,
    required this.recommendedNPCs,
  });
}
