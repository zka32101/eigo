/// アチーブメント・進行度システム
/// プレイヤー達成、マイルストーン、進行度追跡

/// アチーブメント・進行度システム
class AchievementsProgressionSystem {
  static final AchievementsProgressionSystem _instance =
      AchievementsProgressionSystem._internal();

  factory AchievementsProgressionSystem.getInstance() {
    return _instance;
  }

  AchievementsProgressionSystem._internal();

  // アチーブメント: achievement_id -> Achievement
  final Map<String, Achievement> _achievements = {};

  // プレイヤーアチーブメント: player_id -> List<earned_achievement_id>
  final Map<String, List<String>> _playerAchievements = {};

  // プレイヤー進行度: player_id -> List<ProgressTracker>
  final Map<String, List<ProgressTracker>> _playerProgress = {};

  // マイルストーン: milestone_id -> Milestone
  final Map<String, Milestone> _milestones = {};

  // プレイヤーマイルストーン: player_id -> List<milestone_id>
  final Map<String, List<String>> _playerMilestones = {};

  // 進行度カテゴリ: category -> List<achievement_id>
  final Map<String, List<String>> _achievementsByCategory = {};

  // アチーブメント統計: player_id -> Statistics
  final Map<String, AchievementStatistics> _statistics = {};

  /// システムを初期化
  void initialize() {
    _achievements.clear();
    _playerAchievements.clear();
    _playerProgress.clear();
    _milestones.clear();
    _playerMilestones.clear();
    _achievementsByCategory.clear();
    _statistics.clear();

    _initializeAchievements();
    _initializeMilestones();
  }

  /// アチーブメントを初期化
  void _initializeAchievements() {
    // 戦闘カテゴリ
    _addAchievement(Achievement(
      id: 'first_victory',
      name: 'First Victory',
      description: 'Win your first battle',
      category: AchievementCategory.combat,
      points: 10,
      reward: 100,
      requirement: 1,
    ));

    _addAchievement(Achievement(
      id: 'battle_master',
      name: 'Battle Master',
      description: 'Win 50 battles',
      category: AchievementCategory.combat,
      points: 50,
      reward: 500,
      requirement: 50,
    ));

    _addAchievement(Achievement(
      id: 'boss_slayer',
      name: 'Boss Slayer',
      description: 'Defeat 10 bosses',
      category: AchievementCategory.combat,
      points: 75,
      reward: 750,
      requirement: 10,
    ));

    // 探索カテゴリ
    _addAchievement(Achievement(
      id: 'explorer',
      name: 'Explorer',
      description: 'Visit all areas',
      category: AchievementCategory.exploration,
      points: 40,
      reward: 400,
      requirement: 6,
    ));

    _addAchievement(Achievement(
      id: 'dungeon_delver',
      name: 'Dungeon Delver',
      description: 'Complete 20 dungeons',
      category: AchievementCategory.exploration,
      points: 60,
      reward: 600,
      requirement: 20,
    ));

    // 経済カテゴリ
    _addAchievement(Achievement(
      id: 'merchant',
      name: 'Merchant',
      description: 'Trade 100 items',
      category: AchievementCategory.economy,
      points: 35,
      reward: 350,
      requirement: 100,
    ));

    _addAchievement(Achievement(
      id: 'wealthy',
      name: 'Wealthy',
      description: 'Accumulate 10000 gold',
      category: AchievementCategory.economy,
      points: 50,
      reward: 500,
      requirement: 10000,
    ));

    // 社交カテゴリ
    _addAchievement(Achievement(
      id: 'matchmaker',
      name: 'Matchmaker',
      description: 'Marry an NPC',
      category: AchievementCategory.social,
      points: 55,
      reward: 550,
      requirement: 1,
    ));

    _addAchievement(Achievement(
      id: 'family_tree',
      name: 'Family Tree',
      description: 'Have 3 children',
      category: AchievementCategory.social,
      points: 65,
      reward: 650,
      requirement: 3,
    ));

    // スキルカテゴリ
    _addAchievement(Achievement(
      id: 'skill_collector',
      name: 'Skill Collector',
      description: 'Learn 10 skills',
      category: AchievementCategory.skills,
      points: 45,
      reward: 450,
      requirement: 10,
    ));

    _addAchievement(Achievement(
      id: 'master_crafter',
      name: 'Master Crafter',
      description: 'Craft 50 items',
      category: AchievementCategory.skills,
      points: 55,
      reward: 550,
      requirement: 50,
    ));
  }

  /// マイルストーンを初期化
  void _initializeMilestones() {
    _addMilestone(Milestone(
      id: 'level_10',
      name: 'Reach Level 10',
      description: 'Achieve level 10',
      category: MilestoneCategory.progression,
      requirement: 10,
      reward: 200,
    ));

    _addMilestone(Milestone(
      id: 'level_25',
      name: 'Reach Level 25',
      description: 'Achieve level 25',
      category: MilestoneCategory.progression,
      requirement: 25,
      reward: 500,
    ));

    _addMilestone(Milestone(
      id: 'level_50',
      name: 'Reach Level 50',
      description: 'Achieve level 50',
      category: MilestoneCategory.progression,
      requirement: 50,
      reward: 1000,
    ));

    _addMilestone(Milestone(
      id: 'reputation_100',
      name: 'Honored Reputation',
      description: 'Reach 100 total reputation',
      category: MilestoneCategory.social,
      requirement: 100,
      reward: 300,
    ));

    _addMilestone(Milestone(
      id: 'gold_5000',
      name: 'Prosperous',
      description: 'Accumulate 5000 gold',
      category: MilestoneCategory.economy,
      requirement: 5000,
      reward: 400,
    ));
  }

  /// アチーブメントを追加
  void _addAchievement(Achievement achievement) {
    _achievements[achievement.id] = achievement;
    _achievementsByCategory
        .putIfAbsent(achievement.category.name, () => [])
        .add(achievement.id);
  }

  /// マイルストーンを追加
  void _addMilestone(Milestone milestone) {
    _milestones[milestone.id] = milestone;
  }

  /// アチーブメントを獲得
  bool unlockAchievement(String playerId, String achievementId) {
    if (!_achievements.containsKey(achievementId)) return false;

    _playerAchievements.putIfAbsent(playerId, () => []);
    if (_playerAchievements[playerId]!.contains(achievementId)) {
      return false; // 既に獲得済み
    }

    _playerAchievements[playerId]!.add(achievementId);
    _updateStatistics(playerId);

    return true;
  }

  /// 進行度を更新
  bool updateProgress(
    String playerId,
    String progressId,
    int currentValue,
    String category,
  ) {
    _playerProgress.putIfAbsent(playerId, () => []);

    // 既存の進行度を探す
    ProgressTracker? tracker;
    try {
      tracker = _playerProgress[playerId]!
          .firstWhere((p) => p.id == progressId);
    } catch (e) {
      // 新しい進行度を作成
      tracker = ProgressTracker(
        id: progressId,
        category: category,
        currentValue: 0,
        maxValue: 100,
        startedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _playerProgress[playerId]!.add(tracker);
    }

    // 進行度を更新
    tracker.currentValue = currentValue;
    tracker.lastUpdatedAt = DateTime.now().millisecondsSinceEpoch;

    // アチーブメント解除をチェック
    _checkAchievementCompletion(playerId, currentValue, category);

    return true;
  }

  /// アチーブメント完了をチェック
  void _checkAchievementCompletion(
    String playerId,
    int currentValue,
    String category,
  ) {
    final categoryAchievements =
        _achievementsByCategory[category] ?? [];

    for (final achievementId in categoryAchievements) {
      final achievement = _achievements[achievementId];
      if (achievement != null &&
          currentValue >= achievement.requirement &&
          !(_playerAchievements[playerId] ?? [])
              .contains(achievementId)) {
        unlockAchievement(playerId, achievementId);
      }
    }
  }

  /// マイルストーン完了をチェック
  void _checkMilestoneCompletion(String playerId, int value) {
    for (final milestone in _milestones.values) {
      if (value >= milestone.requirement &&
          !(_playerMilestones[playerId] ?? [])
              .contains(milestone.id)) {
        _playerMilestones.putIfAbsent(playerId, () => []);
        _playerMilestones[playerId]!.add(milestone.id);
        _updateStatistics(playerId);
      }
    }
  }

  /// 統計を更新
  void _updateStatistics(String playerId) {
    final achievements = _playerAchievements[playerId] ?? [];
    final milestones = _playerMilestones[playerId] ?? [];

    int totalPoints = 0;
    int totalRewards = 0;

    for (final achievementId in achievements) {
      final achievement = _achievements[achievementId];
      if (achievement != null) {
        totalPoints += achievement.points;
        totalRewards += achievement.reward;
      }
    }

    for (final milestoneId in milestones) {
      final milestone = _milestones[milestoneId];
      if (milestone != null) {
        totalRewards += milestone.reward;
      }
    }

    _statistics[playerId] = AchievementStatistics(
      playerId: playerId,
      totalAchievements: achievements.length,
      totalMilestones: milestones.length,
      totalPoints: totalPoints,
      totalRewards: totalRewards,
      completionPercentage: (_achievements.isNotEmpty
          ? (achievements.length / _achievements.length * 100).toInt()
          : 0),
    );
  }

  /// プレイヤーの進行度を取得
  List<ProgressTracker> getPlayerProgress(String playerId) {
    return _playerProgress[playerId] ?? [];
  }

  /// アチーブメントを取得
  Achievement? getAchievement(String achievementId) {
    return _achievements[achievementId];
  }

  /// プレイヤーのアチーブメント一覧を取得
  List<Achievement> getPlayerAchievements(String playerId) {
    final achievementIds = _playerAchievements[playerId] ?? [];
    return achievementIds
        .map((id) => _achievements[id])
        .whereType<Achievement>()
        .toList();
  }

  /// カテゴリ別アチーブメントを取得
  List<Achievement> getAchievementsByCategory(
    AchievementCategory category,
  ) {
    final achievementIds = _achievementsByCategory[category.name] ?? [];
    return achievementIds
        .map((id) => _achievements[id])
        .whereType<Achievement>()
        .toList();
  }

  /// マイルストーン一覧を取得
  Map<String, Milestone> getAllMilestones() {
    return Map.from(_milestones);
  }

  /// プレイヤーのマイルストーン一覧を取得
  List<Milestone> getPlayerMilestones(String playerId) {
    final milestoneIds = _playerMilestones[playerId] ?? [];
    return milestoneIds
        .map((id) => _milestones[id])
        .whereType<Milestone>()
        .toList();
  }

  /// 統計を取得
  AchievementStatistics? getStatistics(String playerId) {
    return _statistics[playerId];
  }

  /// 未獲得アチーブメントを取得
  List<Achievement> getUnlockedAchievements(String playerId) {
    final unlockedIds = _playerAchievements[playerId] ?? [];
    return _achievements.values
        .where((a) => !unlockedIds.contains(a.id))
        .toList();
  }

  /// 進行状況レポートを取得
  String getProgressionReport(String playerId) {
    final stats = _statistics[playerId];
    if (stats == null) return 'No data';

    return '''
Player: $playerId

Achievements:
  Total: ${stats.totalAchievements}/${_achievements.length}
  Completion: ${stats.completionPercentage}%
  Points: ${stats.totalPoints}

Milestones:
  Completed: ${stats.totalMilestones}/${_milestones.length}
  Rewards: ${stats.totalRewards}G
''';
  }

  /// 進行度の詳細を取得
  String getDetailedProgress(String playerId) {
    final progress = getPlayerProgress(playerId);
    if (progress.isEmpty) return 'No progress tracked';

    return progress
        .map((p) =>
            '${p.category}: ${p.currentValue}/${p.maxValue} (${(p.currentValue / p.maxValue * 100).toInt()}%)')
        .join('\n');
  }
}

/// アチーブメント
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final int points;
  final int reward;
  final int requirement;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.points,
    required this.reward,
    required this.requirement,
  });

  /// アチーブメント進行度を取得（0-100）
  int getProgressPercentage(int currentValue) {
    return ((currentValue / requirement) * 100).toInt().clamp(0, 100);
  }
}

/// アチーブメントカテゴリ
enum AchievementCategory {
  combat,
  exploration,
  economy,
  social,
  skills,
}

/// マイルストーン
class Milestone {
  final String id;
  final String name;
  final String description;
  final MilestoneCategory category;
  final int requirement;
  final int reward;

  Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.requirement,
    required this.reward,
  });
}

/// マイルストーンカテゴリ
enum MilestoneCategory {
  progression,
  economy,
  social,
  exploration,
}

/// 進行度追跡
class ProgressTracker {
  final String id;
  final String category;
  int currentValue;
  final int maxValue;
  final int startedAt;
  late int lastUpdatedAt;

  ProgressTracker({
    required this.id,
    required this.category,
    required this.currentValue,
    required this.maxValue,
    required this.startedAt,
  }) {
    lastUpdatedAt = startedAt;
  }

  /// 進行率を取得（0-100）
  int getProgress() {
    return ((currentValue / maxValue) * 100).toInt().clamp(0, 100);
  }

  /// 経過日数を取得
  int getDaysElapsed() {
    return (DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 86400000;
  }
}

/// アチーブメント統計
class AchievementStatistics {
  final String playerId;
  final int totalAchievements;
  final int totalMilestones;
  final int totalPoints;
  final int totalRewards;
  final int completionPercentage;

  AchievementStatistics({
    required this.playerId,
    required this.totalAchievements,
    required this.totalMilestones,
    required this.totalPoints,
    required this.totalRewards,
    required this.completionPercentage,
  });

  /// ランクを取得
  String getRank() {
    if (completionPercentage >= 90) return 'Legendary';
    if (completionPercentage >= 75) return 'Diamond';
    if (completionPercentage >= 50) return 'Platinum';
    if (completionPercentage >= 25) return 'Gold';
    return 'Bronze';
  }

  /// レベルを計算
  int getLevel() {
    return (totalPoints ~/ 100) + 1;
  }
}
