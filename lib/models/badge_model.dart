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
