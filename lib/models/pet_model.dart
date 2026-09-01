import 'package:json_annotation/json_annotation.dart';

part 'pet_model.g.dart';

/// ペットの種類
enum PetSpecies {
  @JsonValue('turtle')
  turtle, // 🐢 Turtle
  @JsonValue('parrot')
  parrot, // 🦜 Parrot
  @JsonValue('fish')
  fish, // 🐠 Fish
  @JsonValue('lion')
  lion, // 🦁 Lion
  @JsonValue('fox')
  fox, // 🦊 Fox
}

/// ペットの進化段階
enum EvolutionStage {
  @JsonValue('egg')
  egg, // たまご
  @JsonValue('baby')
  baby, // ベビー
  @JsonValue('kids')
  kids, // キッズ
  @JsonValue('adult')
  adult, // アダルト
}

/// ペットデータモデル
@JsonSerializable()
class Pet {
  final String petId;
  final PetSpecies species;
  final String nickname;
  final int level; // 1-100
  final int experience; // 0-100 (経験値、100で次レベル)
  final int satiety; // 0-100 (満腹度)
  final int happiness; // 0-100 (幸福度)
  final EvolutionStage evolutionStage;
  final List<String> learnedWords; // 学習した単語
  final DateTime createdAt;
  final DateTime lastFedAt;
  final DateTime lastPlayedAt;
  final int totalFeedsCount;
  final int totalPlayCount;

  const Pet({
    required this.petId,
    required this.species,
    required this.nickname,
    this.level = 1,
    this.experience = 0,
    this.satiety = 50,
    this.happiness = 50,
    this.evolutionStage = EvolutionStage.egg,
    this.learnedWords = const [],
    required this.createdAt,
    required this.lastFedAt,
    required this.lastPlayedAt,
    this.totalFeedsCount = 0,
    this.totalPlayCount = 0,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  Map<String, dynamic> toJson() => _$PetToJson(this);

  Pet copyWith({
    String? petId,
    PetSpecies? species,
    String? nickname,
    int? level,
    int? experience,
    int? satiety,
    int? happiness,
    EvolutionStage? evolutionStage,
    List<String>? learnedWords,
    DateTime? createdAt,
    DateTime? lastFedAt,
    DateTime? lastPlayedAt,
    int? totalFeedsCount,
    int? totalPlayCount,
  }) {
    return Pet(
      petId: petId ?? this.petId,
      species: species ?? this.species,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      satiety: satiety ?? this.satiety,
      happiness: happiness ?? this.happiness,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      learnedWords: learnedWords ?? this.learnedWords,
      createdAt: createdAt ?? this.createdAt,
      lastFedAt: lastFedAt ?? this.lastFedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalFeedsCount: totalFeedsCount ?? this.totalFeedsCount,
      totalPlayCount: totalPlayCount ?? this.totalPlayCount,
    );
  }

  /// ペットの絵文字を取得
  String get emoji {
    return {
      PetSpecies.turtle: '🐢',
      PetSpecies.parrot: '🦜',
      PetSpecies.fish: '🐠',
      PetSpecies.lion: '🦁',
      PetSpecies.fox: '🦊',
    }[species] ?? '🐢';
  }

  /// ペットの進化段階の日本語表記
  String get evolutionStageName {
    return {
      EvolutionStage.egg: 'たまご',
      EvolutionStage.baby: 'ベビー',
      EvolutionStage.kids: 'キッズ',
      EvolutionStage.adult: 'アダルト',
    }[evolutionStage] ?? 'たまご';
  }

  /// 満腹度の健康度合いを判定
  String get satietyStatus {
    if (satiety > 70) return 'げんき';
    if (satiety > 40) return 'ふつう';
    if (satiety > 20) return 'すこし..';
    return 'おなかすいた';
  }

  /// 幸福度の状態を判定
  String get happinessStatus {
    if (happiness > 70) return 'うれしい';
    if (happiness > 40) return 'ふつう';
    if (happiness > 20) return 'ちょっと..';
    return 'さびしい';
  }

  /// 次のレベルアップまでの経験値
  int get experienceToNextLevel => 100 - experience;

  /// 満腹度が低いかどうか
  bool get isHungry => satiety < 40;

  /// 幸福度が低いかどうか
  bool get isUnhappy => happiness < 40;
}

/// ペットフィードアイテム（エサ）
@JsonSerializable()
class PetFood {
  final String foodId;
  final String name;
  final String description;
  final int satietyRestore; // 回復量
  final int cost; // コイン価格
  final String icon;

  const PetFood({
    required this.foodId,
    required this.name,
    required this.description,
    required this.satietyRestore,
    required this.cost,
    required this.icon,
  });

  factory PetFood.fromJson(Map<String, dynamic> json) => _$PetFoodFromJson(json);

  Map<String, dynamic> toJson() => _$PetFoodToJson(this);
}

/// ペットのアクション履歴
@JsonSerializable()
class PetActionLog {
  final String actionId;
  final String petId;
  final String actionType; // 'feed', 'play', 'pet', etc.
  final Map<String, int> statsChange; // stat name -> change amount
  final String message; // ペットのセリフ
  final DateTime timestamp;

  const PetActionLog({
    required this.actionId,
    required this.petId,
    required this.actionType,
    required this.statsChange,
    required this.message,
    required this.timestamp,
  });

  factory PetActionLog.fromJson(Map<String, dynamic> json) =>
      _$PetActionLogFromJson(json);

  Map<String, dynamic> toJson() => _$PetActionLogToJson(this);
}

/// ペット統計
@JsonSerializable()
class PetStats {
  final int totalPets;
  final int maxLevel;
  final double averageSatiety;
  final double averageHappiness;
  final int totalFeeds;
  final int totalPlays;
  final DateTime lastInteractionAt;

  const PetStats({
    required this.totalPets,
    required this.maxLevel,
    required this.averageSatiety,
    required this.averageHappiness,
    required this.totalFeeds,
    required this.totalPlays,
    required this.lastInteractionAt,
  });

  factory PetStats.fromJson(Map<String, dynamic> json) =>
      _$PetStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PetStatsToJson(this);
}
