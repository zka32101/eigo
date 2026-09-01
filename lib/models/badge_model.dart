import 'package:shared_core/shared_core.dart';

export 'package:shared_core/shared_core.dart' show BadgeModel, EarnedBadge, BadgeCategory;

const eigoBadges = <BadgeModel>[
  BadgeModel(id: 'firstLesson',       title: 'はじめの一歩',     description: '初めてレッスンを完了',       emoji: '🌟', category: BadgeCategory.special,  requiredCount: 1),
  BadgeModel(id: 'wordMaster',        title: '単語マスター',     description: '単語発音を30個練習',         emoji: '🗣️', category: BadgeCategory.content1, requiredCount: 30),
  BadgeModel(id: 'phraseMaster',      title: 'フレーズマスター', description: 'フレーズ発音を40個練習',     emoji: '💬', category: BadgeCategory.content1, requiredCount: 70),
  BadgeModel(id: 'conversationChamp', title: '会話チャンピオン', description: '会話練習を20回達成',         emoji: '🏆', category: BadgeCategory.content2, requiredCount: 20),
  BadgeModel(id: 'streakWeek',        title: '1週間連続',        description: '7日間連続で練習',           emoji: '🔥', category: BadgeCategory.streak,   requiredCount: 7),
  BadgeModel(id: 'streakMonth',       title: '1ヶ月連続',        description: '30日間連続で練習',          emoji: '🌈', category: BadgeCategory.streak,   requiredCount: 30),
  BadgeModel(id: 'perfectScore',      title: 'パーフェクト！',   description: 'レッスンで満点を達成',       emoji: '💯', category: BadgeCategory.score,    requiredCount: 1),
  BadgeModel(id: 'speakingPro',       title: 'スピーキングプロ', description: 'スピーキング平均85点以上',   emoji: '🎤', category: BadgeCategory.special,  requiredCount: 85),
  BadgeModel(id: 'listeningPro',      title: 'リスニングプロ',   description: 'リスニング正解率90%以上',    emoji: '👂', category: BadgeCategory.special,  requiredCount: 90),
  BadgeModel(id: 'stage1Clear',       title: 'ステージ1クリア',  description: 'ステージ1をすべてクリア',   emoji: '⭐', category: BadgeCategory.special,  requiredCount: 1),
  BadgeModel(id: 'stage5Clear',       title: '折り返し点',       description: 'ステージ5をクリア',         emoji: '🌟', category: BadgeCategory.special,  requiredCount: 5),
  BadgeModel(id: 'stage10Clear',      title: '学習マスター',     description: 'ステージ10をクリア',        emoji: '👑', category: BadgeCategory.special,  requiredCount: 10),
];

// Additional badge models for enhanced achievement system

/// バッジのレア度
enum BadgeRarity {
  common, // 一般
  uncommon, // レア
  rare, // 非常にレア
  legendary, // 伝説的
}

/// ユーザーが獲得したバッジ
class UnlockedBadge {
  final String badgeId;
  final String title;
  final String description;
  final String icon;
  final BadgeRarity rarity;
  final DateTime unlockedAt;
  final bool isNew; // 新しく獲得したかどうか

  const UnlockedBadge({
    required this.badgeId,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlockedAt,
    this.isNew = false,
  });

  UnlockedBadge copyWith({
    String? badgeId,
    String? title,
    String? description,
    String? icon,
    BadgeRarity? rarity,
    DateTime? unlockedAt,
    bool? isNew,
  }) {
    return UnlockedBadge(
      badgeId: badgeId ?? this.badgeId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toJson() => {
        'badgeId': badgeId,
        'title': title,
        'description': description,
        'icon': icon,
        'rarity': rarity.toString(),
        'unlockedAt': unlockedAt.toIso8601String(),
        'isNew': isNew,
      };

  factory UnlockedBadge.fromJson(Map<String, dynamic> json) => UnlockedBadge(
        badgeId: json['badgeId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        rarity: BadgeRarity.values.firstWhere(
          (e) => e.toString() == json['rarity'],
          orElse: () => BadgeRarity.common,
        ),
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
        isNew: json['isNew'] as bool? ?? false,
      );
}

/// バッジ進捗
class BadgeProgress {
  final String badgeId;
  final String title;
  final String icon;
  final BadgeRarity rarity;
  final int currentValue; // 現在の進捗
  final int targetValue; // 目標値
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeProgress({
    required this.badgeId,
    required this.title,
    required this.icon,
    required this.rarity,
    required this.currentValue,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => currentValue >= targetValue ? 1.0 : currentValue / targetValue;
  int get remaining => (targetValue - currentValue).clamp(0, targetValue);

  Map<String, dynamic> toJson() => {
        'badgeId': badgeId,
        'title': title,
        'icon': icon,
        'rarity': rarity.toString(),
        'currentValue': currentValue,
        'targetValue': targetValue,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory BadgeProgress.fromJson(Map<String, dynamic> json) => BadgeProgress(
        badgeId: json['badgeId'] as String,
        title: json['title'] as String,
        icon: json['icon'] as String,
        rarity: BadgeRarity.values.firstWhere(
          (e) => e.toString() == json['rarity'],
          orElse: () => BadgeRarity.common,
        ),
        currentValue: json['currentValue'] as int,
        targetValue: json['targetValue'] as int,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
      );
}
