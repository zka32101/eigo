import 'package:flutter/foundation.dart';

/// ペットの種類
enum PetSpecies {
  parrot('🦜 オウム', 'parrot'),
  turtle('🐢 カメ', 'turtle'),
  fish('🐠 さかな', 'fish'),
  lion('🦁 ライオン', 'lion'),
  fox('🦊 キツネ', 'fox');

  final String displayName;
  final String id;

  const PetSpecies(this.displayName, this.id);

  static PetSpecies fromId(String id) {
    return values.firstWhere((e) => e.id == id, orElse: () => PetSpecies.parrot);
  }
}

/// ペットの進化段階
enum PetEvolutionStage {
  egg('たまご', 0),
  baby('ベビー', 5),
  kids('キッズ', 15),
  adult('アダルト', 25);

  final String displayName;
  final int requiredLevel;

  const PetEvolutionStage(this.displayName, this.requiredLevel);

  static PetEvolutionStage fromLevel(int level) {
    if (level >= 25) return PetEvolutionStage.adult;
    if (level >= 15) return PetEvolutionStage.kids;
    if (level >= 5) return PetEvolutionStage.baby;
    return PetEvolutionStage.egg;
  }
}

/// ペットの状態
enum PetMood {
  happy('😊 嬉しい', 1.0),
  normal('😌 普通', 0.8),
  sad('😢 悲しい', 0.6),
  hungry('😫 お腹すいた', 0.4),
  starving('😵 飢えている', 0.2);

  final String displayName;
  final double moodMultiplier; // 経験値獲得倍率

  const PetMood(this.displayName, this.moodMultiplier);

  static PetMood fromHungerAndHappiness(int hunger, int happiness) {
    if (hunger >= 80) return PetMood.starving;
    if (hunger >= 60) return PetMood.hungry;
    if (happiness >= 80) return PetMood.happy;
    if (happiness >= 50) return PetMood.normal;
    return PetMood.sad;
  }
}

/// ペットの装飾品
class PetDecoration {
  final String id;
  final String name;
  final String emoji;
  final int price; // コイン価格

  const PetDecoration({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
  });

  factory PetDecoration.fromJson(Map<String, dynamic> json) {
    return PetDecoration(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'price': price,
    };
  }
}

/// メインのペットモデル
class PetModel {
  final String userId;
  final PetSpecies species;
  final int level; // 1-30
  final int exp; // 0-100（100で level up）
  final int hunger; // 0-100（60+ で不幸）
  final int happiness; // 0-100（50+ で喜び）
  final DateTime lastFedDate;
  final DateTime createdAt;
  final List<DateTime> evolveDates; // 進化した日時（最大 3回）
  final List<String> decorationIds; // 装備中の装飾品 ID

  PetModel({
    required this.userId,
    required this.species,
    this.level = 1,
    this.exp = 0,
    this.hunger = 50,
    this.happiness = 50,
    required this.lastFedDate,
    required this.createdAt,
    this.evolveDates = const [],
    this.decorationIds = const [],
  });

  /// ペットの現在の進化段階を取得
  PetEvolutionStage get currentStage => PetEvolutionStage.fromLevel(level);

  /// ペットの現在の気分を取得
  PetMood get currentMood => PetMood.fromHungerAndHappiness(hunger, happiness);

  /// 次のレベルアップまでに必要な EXP
  int get expToNextLevel => 100 - exp;

  /// 次の進化までに必要なレベル
  int? get levelToNextEvolution {
    if (currentStage == PetEvolutionStage.adult) return null;
    return currentStage.requiredLevel - level;
  }

  /// 今日既にエサをやったか
  bool get isFedToday {
    final today = DateTime.now();
    return lastFedDate.year == today.year &&
        lastFedDate.month == today.month &&
        lastFedDate.day == today.day;
  }

  /// 何日連続でエサをやっているか
  int get consecutiveFeedDays {
    int count = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      // 簡略化：lastFedDate で判定（実装時は履歴テーブルから取得）
      if (i == 0 && isFedToday) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// 発音スコアを受け取ってペットに反映
  /// [pronouncingScore] 0-100 の発音スコア
  /// 返却値：獲得したコイン数
  int feedPetWithScore(int pronouncingScore) {
    int newHunger = hunger;
    int newExp = exp;
    int coinsEarned = 0;

    // 発音スコア 60+ でエサやり
    if (pronouncingScore >= 60) {
      newHunger = (hunger - 10).clamp(0, 100);
      int scoreBonus = (pronouncingScore - 60) ~/ 10; // 0-4
      newExp = exp + 10 + scoreBonus;
      coinsEarned = 10 + (scoreBonus * 5);
    }

    return coinsEarned;
  }

  /// 毎日のプレイボーナス（朝通知など）
  int dailyPlayBonus() {
    int newHappiness = (happiness + 5).clamp(0, 100);
    return 5;
  }

  /// レベルアップ判定（EXP が 100 に達したら）
  PetModel? tryLevelUp() {
    if (exp < 100) return null;

    final newLevel = level + 1;
    final newExp = exp - 100;

    // 進化判定
    final oldStage = PetEvolutionStage.fromLevel(level);
    final newStage = PetEvolutionStage.fromLevel(newLevel);

    List<DateTime> newEvolveDates = [...evolveDates];
    if (oldStage != newStage && newStage != PetEvolutionStage.egg) {
      newEvolveDates.add(DateTime.now());
    }

    return PetModel(
      userId: userId,
      species: species,
      level: newLevel,
      exp: newExp,
      hunger: hunger,
      happiness: happiness,
      lastFedDate: lastFedDate,
      createdAt: createdAt,
      evolveDates: newEvolveDates,
      decorationIds: decorationIds,
    );
  }

  /// ペットの飢餓状態をシミュレート（毎時間呼ぶ想定）
  PetModel simulateTimePass() {
    final now = DateTime.now();
    final hoursPassed = now.difference(lastFedDate).inHours;

    // 1時間ごとに hunger +5
    int newHunger = (hunger + (hoursPassed * 5)).clamp(0, 100).toInt();

    // hunger が高いと happiness 減少
    int newHappiness = happiness;
    if (newHunger >= 80) {
      newHappiness = (happiness - (hoursPassed * 2)).clamp(0, 100).toInt();
    }

    return PetModel(
      userId: userId,
      species: species,
      level: level,
      exp: exp,
      hunger: newHunger,
      happiness: newHappiness,
      lastFedDate: lastFedDate,
      createdAt: createdAt,
      evolveDates: evolveDates,
      decorationIds: decorationIds,
    );
  }

  /// JSON シリアライズ（Firestore 保存用）
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'species': species.id,
      'level': level,
      'exp': exp,
      'hunger': hunger,
      'happiness': happiness,
      'lastFedDate': lastFedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'evolveDates': evolveDates.map((d) => d.toIso8601String()).toList(),
      'decorationIds': decorationIds,
    };
  }

  /// JSON デシリアライズ（Firestore 読み込み用）
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      userId: json['userId'] as String,
      species: PetSpecies.fromId(json['species'] as String),
      level: json['level'] as int,
      exp: json['exp'] as int,
      hunger: json['hunger'] as int,
      happiness: json['happiness'] as int,
      lastFedDate: DateTime.parse(json['lastFedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      evolveDates: (json['evolveDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      decorationIds: List<String>.from(json['decorationIds'] as List<dynamic>? ?? []),
    );
  }

  /// コピーコンストラクタ（更新時に使用）
  PetModel copyWith({
    String? userId,
    PetSpecies? species,
    int? level,
    int? exp,
    int? hunger,
    int? happiness,
    DateTime? lastFedDate,
    DateTime? createdAt,
    List<DateTime>? evolveDates,
    List<String>? decorationIds,
  }) {
    return PetModel(
      userId: userId ?? this.userId,
      species: species ?? this.species,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      lastFedDate: lastFedDate ?? this.lastFedDate,
      createdAt: createdAt ?? this.createdAt,
      evolveDates: evolveDates ?? this.evolveDates,
      decorationIds: decorationIds ?? this.decorationIds,
    );
  }

  @override
  String toString() => 'PetModel(species: ${species.id}, level: $level, '
      'exp: $exp, mood: ${currentMood.displayName})';
}

/// ペット装飾品のプリセット
class PetDecorationPresets {
  static const List<PetDecoration> all = [
    PetDecoration(id: 'hat_party', name: 'パーティー帽', emoji: '🎉', price: 100),
    PetDecoration(id: 'hat_crown', name: 'クラウン', emoji: '👑', price: 200),
    PetDecoration(id: 'glasses_cool', name: 'サングラス', emoji: '😎', price: 150),
    PetDecoration(id: 'bow_pink', name: 'ピンクリボン', emoji: '🎀', price: 100),
    PetDecoration(id: 'scarf_red', name: '赤いスカーフ', emoji: '🧣', price: 120),
    PetDecoration(id: 'medal_gold', name: '金メダル', emoji: '🥇', price: 300),
    PetDecoration(id: 'balloon', name: '風船', emoji: '🎈', price: 80),
    PetDecoration(id: 'star', name: 'キラキラ', emoji: '⭐', price: 90),
    PetDecoration(id: 'flower', name: 'お花', emoji: '🌸', price: 110),
    PetDecoration(id: 'heart', name: 'ハート', emoji: '💖', price: 140),
  ];

  static PetDecoration? fromId(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
