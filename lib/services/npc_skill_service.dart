import 'package:eigo/models/npc_skill_model.dart';

/// NPC スキル教えるサービス
class NPCSkillService {
  static final NPCSkillService _instance = NPCSkillService._internal();

  factory NPCSkillService.getInstance() {
    return _instance;
  }

  NPCSkillService._internal();

  // スキルキャッシュ
  final Map<String, NPCSkill> _skillCache = {};

  // 習得したスキルキャッシュ
  final Map<String, LearnedSkill> _learnedSkillCache = {};

  // スキル学習セッションキャッシュ
  final Map<String, SkillLearningSession> _sessionCache = {};

  // スキル統計キャッシュ
  final Map<String, SkillStatistics> _statsCache = {};

  /// スキルを登録
  NPCSkill registerSkill({
    required String skillId,
    required String skillName,
    required String description,
    required SkillCategory category,
    required String teachingNpcId,
    required SkillLevel maxLevel,
    required List<SkillTeachingMethod> teachingMethods,
    required int experienceRequired,
    required String effectDescription,
    String? prerequisiteSkillId,
  }) {
    final skill = NPCSkill(
      skillId: skillId,
      skillName: skillName,
      description: description,
      category: category,
      teachingNpcId: teachingNpcId,
      maxLevel: maxLevel,
      prerequisiteSkillId: prerequisiteSkillId,
      teachingMethods: teachingMethods,
      experienceRequired: experienceRequired,
      effectDescription: effectDescription,
    );

    _skillCache[skillId] = skill;
    return skill;
  }

  /// スキルを取得
  NPCSkill? getSkill(String skillId) {
    return _skillCache[skillId];
  }

  /// NPC が教えるスキル一覧を取得
  List<NPCSkill> getNPCSkills(String npcId) {
    return _skillCache.values.where((s) => s.teachingNpcId == npcId).toList();
  }

  /// カテゴリ別にスキルを取得
  List<NPCSkill> getSkillsByCategory(SkillCategory category) {
    return _skillCache.values.where((s) => s.category == category).toList();
  }

  /// スキル学習セッションを開始
  SkillLearningSession startLearningSession({
    required String sessionId,
    required String npcId,
    required String skillId,
    required String teachingMethodId,
  }) {
    final skill = getSkill(skillId);
    if (skill == null) {
      throw Exception('Skill $skillId not found');
    }

    final session = SkillLearningSession(
      sessionId: sessionId,
      npcId: npcId,
      skillId: skillId,
      teachingMethodId: teachingMethodId,
      startedAt: DateTime.now(),
    );

    _sessionCache[sessionId] = session;
    return session;
  }

  /// スキル学習セッションを完了
  SkillLearningSession completeLearningSession(
    String sessionId, {
    required int experienceGained,
  }) {
    final session = _sessionCache[sessionId];
    if (session == null) {
      throw Exception('Session $sessionId not found');
    }

    final completed = session.copyWith(
      completedAt: DateTime.now(),
      experienceGained: experienceGained,
      isCompleted: true,
    );

    _sessionCache[sessionId] = completed;
    _updateStatistics(session.npcId);

    return completed;
  }

  /// スキルを習得
  LearnedSkill learnSkill({
    required String skillId,
    required String skillName,
  }) {
    final learned = LearnedSkill(
      skillId: skillId,
      skillName: skillName,
      currentLevel: SkillLevel.novice,
      learnedAt: DateTime.now(),
    );

    _learnedSkillCache[skillId] = learned;
    return learned;
  }

  /// 習得したスキルを取得
  LearnedSkill? getLearnedSkill(String skillId) {
    return _learnedSkillCache[skillId];
  }

  /// スキル経験値を追加
  LearnedSkill addSkillExperience(
    String skillId,
    int experienceGained,
  ) {
    final skill = getLearnedSkill(skillId);
    if (skill == null) {
      throw Exception('Learned skill $skillId not found');
    }

    var newExperience = skill.skillExperience + experienceGained;
    var newLevel = skill.currentLevel;

    // レベルアップ確認
    while (newExperience >= _getExperienceForLevel(newLevel.level + 1) &&
        newLevel.level < SkillLevel.master.level) {
      newExperience -= _getExperienceForLevel(newLevel.level + 1);
      newLevel = SkillLevel.values.firstWhere((l) => l.level == newLevel.level + 1);
    }

    final updated = skill.copyWith(
      currentLevel: newLevel,
      skillExperience: newExperience,
    );

    _learnedSkillCache[skillId] = updated;
    return updated;
  }

  /// スキルを使用
  LearnedSkill useSkill(String skillId) {
    final skill = getLearnedSkill(skillId);
    if (skill == null) {
      throw Exception('Learned skill $skillId not found');
    }

    final updated = skill.copyWith(
      lastUsedAt: DateTime.now(),
      timesUsed: skill.timesUsed + 1,
    );

    _learnedSkillCache[skillId] = updated;
    return updated;
  }

  /// スキルレベルアップに必要な経験値を取得
  int _getExperienceForLevel(int level) {
    return 100 * level; // レベルごとに100 * レベルの経験値が必要
  }

  /// スキル統計を生成
  SkillStatistics generateStatistics(String npcId) {
    final skills = getNPCSkills(npcId);
    final sessions = _sessionCache.values
        .where((s) => s.npcId == npcId)
        .toList();

    final completedSessions = sessions.where((s) => s.isCompleted).length;
    var totalXp = 0;
    DateTime? lastTaughtAt;

    for (final session in sessions) {
      if (session.isCompleted) {
        totalXp += session.experienceGained;
        if (lastTaughtAt == null ||
            session.completedAt!.isAfter(lastTaughtAt)) {
          lastTaughtAt = session.completedAt;
        }
      }
    }

    final stats = SkillStatistics(
      npcId: npcId,
      skillsTaught: skills.length,
      totalSessions: sessions.length,
      completedSessions: completedSessions,
      totalExperienceGranted: totalXp,
      lastTaughtAt: lastTaughtAt,
    );

    _statsCache[npcId] = stats;
    return stats;
  }

  /// スキル統計を取得
  SkillStatistics? getStatistics(String npcId) {
    return _statsCache[npcId];
  }

  /// スキルを忘れる
  void forgetSkill(String skillId) {
    _learnedSkillCache.remove(skillId);
  }

  /// スキル学習セッションを削除
  void removeLearningSession(String sessionId) {
    _sessionCache.remove(sessionId);
  }

  /// NPC のスキル学習セッション一覧を取得
  List<SkillLearningSession> getNPCLearningSessions(String npcId) {
    return _sessionCache.values.where((s) => s.npcId == npcId).toList();
  }

  /// NPC の完了したスキル学習セッション一覧を取得
  List<SkillLearningSession> getCompletedLearningSessions(String npcId) {
    return getNPCLearningSessions(npcId)
        .where((s) => s.isCompleted)
        .toList();
  }

  /// キャッシュをクリア
  void clearCache() {
    _skillCache.clear();
    _learnedSkillCache.clear();
    _sessionCache.clear();
    _statsCache.clear();
  }

  /// 統計を更新
  void _updateStatistics(String npcId) {
    generateStatistics(npcId);
  }
}
