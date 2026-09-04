import 'package:json_annotation/json_annotation.dart';

part 'npc_skill_model.g.dart';

/// スキルカテゴリ
enum SkillCategory {
  language('言語', 'Language'),
  combat('戦闘', 'Combat'),
  magic('魔法', 'Magic'),
  crafting('工芸', 'Crafting'),
  social('社交', 'Social'),
  survival('生存', 'Survival'),
  knowledge('知識', 'Knowledge'),
  custom('カスタム', 'Custom');

  final String japanese;
  final String english;

  const SkillCategory(this.japanese, this.english);
}

/// スキルレベル
enum SkillLevel {
  novice('初心者', 'Novice', 1),
  apprentice('見習い', 'Apprentice', 2),
  intermediate('中級', 'Intermediate', 3),
  advanced('上級', 'Advanced', 4),
  expert('エキスパート', 'Expert', 5),
  master('マスター', 'Master', 6);

  final String japanese;
  final String english;
  final int level;

  const SkillLevel(this.japanese, this.english, this.level);
}

/// スキル教えるメソッド
@JsonSerializable()
class SkillTeachingMethod {
  /// メソッド ID
  final String methodId;

  /// メソッド名
  final String name;

  /// メソッド説明
  final String description;

  /// 必要な対話回数
  final int requiredInteractionCount;

  /// 必要な親密度
  final int requiredAffection;

  /// 教えるのに必要な時間（分）
  final int teachingDurationMinutes;

  /// このメソッドで教える効率（スキル経験値倍率）
  final double efficiencyMultiplier;

  SkillTeachingMethod({
    required this.methodId,
    required this.name,
    required this.description,
    required this.requiredInteractionCount,
    required this.requiredAffection,
    required this.teachingDurationMinutes,
    this.efficiencyMultiplier = 1.0,
  });

  factory SkillTeachingMethod.fromJson(Map<String, dynamic> json) =>
      _$SkillTeachingMethodFromJson(json);

  Map<String, dynamic> toJson() => _$SkillTeachingMethodToJson(this);
}

/// スキル（プレイヤーが学ぶことができる）
@JsonSerializable()
class NPCSkill {
  /// スキル ID
  final String skillId;

  /// スキル名
  final String skillName;

  /// スキル説明
  final String description;

  /// スキルカテゴリ
  final SkillCategory category;

  /// 教えるNPC ID
  final String teachingNpcId;

  /// スキルレベル
  final SkillLevel maxLevel;

  /// このスキルを教えるのに必要な条件
  final String? prerequisiteSkillId;

  /// 教えるメソッド一覧
  final List<SkillTeachingMethod> teachingMethods;

  /// このスキルを習得するのに必要な経験値
  final int experienceRequired;

  /// スキル効果説明
  final String effectDescription;

  NPCSkill({
    required this.skillId,
    required this.skillName,
    required this.description,
    required this.category,
    required this.teachingNpcId,
    required this.maxLevel,
    this.prerequisiteSkillId,
    required this.teachingMethods,
    required this.experienceRequired,
    required this.effectDescription,
  });

  factory NPCSkill.fromJson(Map<String, dynamic> json) =>
      _$NPCSkillFromJson(json);

  Map<String, dynamic> toJson() => _$NPCSkillToJson(this);
}

/// プレイヤーが習得したスキル
@JsonSerializable()
class LearnedSkill {
  /// スキル ID
  final String skillId;

  /// スキル名
  final String skillName;

  /// 現在のレベル
  final SkillLevel currentLevel;

  /// スキル経験値
  final int skillExperience;

  /// 習得日時
  final DateTime learnedAt;

  /// 最後に使用した日時
  final DateTime? lastUsedAt;

  /// 使用回数
  final int timesUsed;

  LearnedSkill({
    required this.skillId,
    required this.skillName,
    required this.currentLevel,
    this.skillExperience = 0,
    required this.learnedAt,
    this.lastUsedAt,
    this.timesUsed = 0,
  });

  factory LearnedSkill.fromJson(Map<String, dynamic> json) =>
      _$LearnedSkillFromJson(json);

  Map<String, dynamic> toJson() => _$LearnedSkillToJson(this);

  LearnedSkill copyWith({
    String? skillId,
    String? skillName,
    SkillLevel? currentLevel,
    int? skillExperience,
    DateTime? learnedAt,
    DateTime? lastUsedAt,
    int? timesUsed,
  }) {
    return LearnedSkill(
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      currentLevel: currentLevel ?? this.currentLevel,
      skillExperience: skillExperience ?? this.skillExperience,
      learnedAt: learnedAt ?? this.learnedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      timesUsed: timesUsed ?? this.timesUsed,
    );
  }
}

/// スキル学習セッション
@JsonSerializable()
class SkillLearningSession {
  /// セッション ID
  final String sessionId;

  /// NPC ID
  final String npcId;

  /// スキル ID
  final String skillId;

  /// 教えるメソッド ID
  final String teachingMethodId;

  /// セッション開始日時
  final DateTime startedAt;

  /// セッション終了日時
  final DateTime? completedAt;

  /// 獲得した経験値
  final int experienceGained;

  /// セッションが完了したか
  final bool isCompleted;

  SkillLearningSession({
    required this.sessionId,
    required this.npcId,
    required this.skillId,
    required this.teachingMethodId,
    required this.startedAt,
    this.completedAt,
    this.experienceGained = 0,
    this.isCompleted = false,
  });

  factory SkillLearningSession.fromJson(Map<String, dynamic> json) =>
      _$SkillLearningSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SkillLearningSessionToJson(this);

  SkillLearningSession copyWith({
    String? sessionId,
    String? npcId,
    String? skillId,
    String? teachingMethodId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? experienceGained,
    bool? isCompleted,
  }) {
    return SkillLearningSession(
      sessionId: sessionId ?? this.sessionId,
      npcId: npcId ?? this.npcId,
      skillId: skillId ?? this.skillId,
      teachingMethodId: teachingMethodId ?? this.teachingMethodId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      experienceGained: experienceGained ?? this.experienceGained,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// スキル統計
@JsonSerializable()
class SkillStatistics {
  /// NPC ID
  final String npcId;

  /// 教えたスキル数
  final int skillsTaught;

  /// 総学習セッション数
  final int totalSessions;

  /// 完了した学習セッション数
  final int completedSessions;

  /// 総経験値授与
  final int totalExperienceGranted;

  /// 最後の教えた日時
  final DateTime? lastTaughtAt;

  SkillStatistics({
    required this.npcId,
    this.skillsTaught = 0,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.totalExperienceGranted = 0,
    this.lastTaughtAt,
  });

  factory SkillStatistics.fromJson(Map<String, dynamic> json) =>
      _$SkillStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$SkillStatisticsToJson(this);
}
