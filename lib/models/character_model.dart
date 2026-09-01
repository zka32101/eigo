/// キャラクター収集システムのモデル

class Character {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String rarity; // common, uncommon, rare, legendary
  final String type; // teacher, friend, mascot, wizard
  final int collectPoints; // 収集に必要なポイント
  final List<String> skills; // キャラクターが持つスキル
  final String background; // キャラクターの背景ストーリー

  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.rarity,
    required this.type,
    required this.collectPoints,
    required this.skills,
    required this.background,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      rarity: json['rarity'] as String,
      type: json['type'] as String,
      collectPoints: json['collectPoints'] as int,
      skills: List<String>.from(json['skills'] as List? ?? []),
      background: json['background'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'rarity': rarity,
    'type': type,
    'collectPoints': collectPoints,
    'skills': skills,
    'background': background,
  };
}

/// ユーザーが収集したキャラクター
class CollectedCharacter {
  final Character character;
  final DateTime collectedAt; // 収集日時
  final int level; // キャラクターレベル (1-10)
  final int affection; // 好感度 (0-100)
  final bool isFavorite; // お気に入り設定

  const CollectedCharacter({
    required this.character,
    required this.collectedAt,
    this.level = 1,
    this.affection = 0,
    this.isFavorite = false,
  });

  factory CollectedCharacter.fromJson(Map<String, dynamic> json) {
    return CollectedCharacter(
      character: Character.fromJson(json['character'] as Map<String, dynamic>),
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      level: json['level'] as int? ?? 1,
      affection: json['affection'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'character': character.toJson(),
    'collectedAt': collectedAt.toIso8601String(),
    'level': level,
    'affection': affection,
    'isFavorite': isFavorite,
  };

  CollectedCharacter copyWith({
    Character? character,
    DateTime? collectedAt,
    int? level,
    int? affection,
    bool? isFavorite,
  }) {
    return CollectedCharacter(
      character: character ?? this.character,
      collectedAt: collectedAt ?? this.collectedAt,
      level: level ?? this.level,
      affection: affection ?? this.affection,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// キャラクターカタログ（すべての利用可能なキャラクター）
final List<Character> characterCatalog = [
  Character(
    id: 'char_001',
    name: 'エイコ先生',
    description: '英語教えるプロフェッショナル',
    emoji: '👨‍🏫',
    rarity: 'common',
    type: 'teacher',
    collectPoints: 100,
    skills: ['基本文法', '発音指導', '励ましボーナス'],
    background: '25年の教育経験を持つベテラン英語教師。明るく親切で、すべての学習者の味方。',
  ),
  Character(
    id: 'char_002',
    name: 'ルナ',
    description: '魔法の言葉を知る妖精',
    emoji: '🧚‍♀️',
    rarity: 'uncommon',
    type: 'mascot',
    collectPoints: 150,
    skills: ['単語力UP', '集中力強化', '魔法ボーナス'],
    background: '英語の魔法を知る妖精。彼女に出会うと、単語をもっと簡単に覚えられるようになる。',
  ),
  Character(
    id: 'char_003',
    name: 'トム',
    description: 'アメリカ出身の友達',
    emoji: '🦸‍♂️',
    rarity: 'common',
    type: 'friend',
    collectPoints: 100,
    skills: ['リスニング強化', 'スラング習得', '応援エモート'],
    background: 'テキサス出身の陽気な青年。アメリカ英語の発音と文化を教えてくれる。',
  ),
  Character(
    id: 'char_004',
    name: 'ハーマイオニー',
    description: '魔法学の天才少女',
    emoji: '🧙‍♀️',
    rarity: 'rare',
    type: 'wizard',
    collectPoints: 300,
    skills: ['高度な文法', '読解力UP', '魔法の加護'],
    background: '魔法の学校で最年少の首席。完璧主義者だが、学習者の成長を全力でサポート。',
  ),
  Character(
    id: 'char_005',
    name: 'サリー',
    description: 'イギリス英語の貴族',
    emoji: '👑',
    rarity: 'rare',
    type: 'teacher',
    collectPoints: 250,
    skills: ['イギリス英語', '発音矯正', '上品ボーナス'],
    background: 'ロンドン出身の優雅な女性。イギリス英語とマナーを同時に学べる。',
  ),
  Character(
    id: 'char_006',
    name: 'ウィズ',
    description: '科学少年エンジニア',
    emoji: '🔬',
    rarity: 'uncommon',
    type: 'friend',
    collectPoints: 150,
    skills: ['科学用語習得', '論理力UP', 'テック知識'],
    background: '天才的な少年エンジニア。科学や技術に関する英語表現が得意。',
  ),
  Character(
    id: 'char_007',
    name: 'ゼウス',
    description: '神話の王神',
    emoji: '⚡',
    rarity: 'legendary',
    type: 'wizard',
    collectPoints: 500,
    skills: ['全言語力UP', '究極の力', '神の祝福'],
    background: '神話の王。その力は絶大で、すべてのスキルを最高レベルに引き上げる。',
  ),
  Character(
    id: 'char_008',
    name: 'アリス',
    description: '不思議の国の冒険家',
    emoji: '🎩',
    rarity: 'uncommon',
    type: 'friend',
    collectPoints: 150,
    skills: ['想像力UP', 'ストーリー理解', '冒険ボーナス'],
    background: '不思議の国での冒険が得意。物語を通じた英語学習を手助けする。',
  ),
];
