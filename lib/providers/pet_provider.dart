import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet_model.dart';
import '../services/logger_service.dart';
import '../services/pet_service.dart';

/// 現在のペットプロバイダー
final currentPetProvider = StateNotifierProvider<PetNotifier, Pet?>((ref) {
  return PetNotifier();
});

/// ペット統計プロバイダー
final petStatsProvider = StateNotifierProvider<PetStatsNotifier, PetStats>((ref) {
  return PetStatsNotifier();
});

/// ペット専門店の食べ物リスト
final petFoodShopProvider = Provider<List<PetFood>>((ref) {
  return [
    const PetFood(
      foodId: 'apple',
      name: 'りんご',
      description: 'あっさりした味',
      satietyRestore: 20,
      cost: 10,
      icon: '🍎',
    ),
    const PetFood(
      foodId: 'banana',
      name: 'バナナ',
      description: 'あまいあじ',
      satietyRestore: 25,
      cost: 15,
      icon: '🍌',
    ),
    const PetFood(
      foodId: 'fish',
      name: 'さかな',
      description: 'えいようまんてん',
      satietyRestore: 35,
      cost: 25,
      icon: '🐟',
    ),
    const PetFood(
      foodId: 'meat',
      name: 'にく',
      description: 'パワーアップ!',
      satietyRestore: 40,
      cost: 40,
      icon: '🍖',
    ),
    const PetFood(
      foodId: 'deluxe',
      name: 'ごほうび',
      description: 'ぜんぶもりもり',
      satietyRestore: 100,
      cost: 99,
      icon: '🎉',
    ),
  ];
});

class PetNotifier extends StateNotifier<Pet?> {
  static const String _petStorageKey = 'eigo_kore_current_pet';

  PetNotifier() : super(null) {
    _loadPet();
  }

  /// ペットを読み込む
  Future<void> _loadPet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petJson = prefs.getString(_petStorageKey);
      if (petJson != null) {
        final json = jsonDecode(petJson);
        state = Pet.fromJson(json);
      }
    } catch (e) {
      LoggerService.error('Error loading pet', tag: 'PetNotifier', exception: e);
    }
  }

  /// 新しいペットを作成
  Future<void> createPet(PetSpecies species, String nickname) async {
    final now = DateTime.now();
    state = Pet(
      petId: DateTime.now().millisecondsSinceEpoch.toString(),
      species: species,
      nickname: nickname,
      createdAt: now,
      lastFedAt: now,
      lastPlayedAt: now,
    );
    await _savePet();
  }

  /// ペットにエサをあげる（お腹を満たす）
  Future<void> feedPet(int satietyRestore) async {
    if (state == null) return;

    int newSatiety = (state!.satiety + satietyRestore).clamp(0, 100);
    int newHappiness = (state!.happiness + 5).clamp(0, 100); // エサをあげるとちょっと幸せ
    int newExp = state!.experience + 2; // 経験値 +2

    state = state!.copyWith(
      satiety: newSatiety,
      happiness: newHappiness,
      experience: newExp % 100,
      level: state!.level + (newExp ~/ 100),
      lastFedAt: DateTime.now(),
      totalFeedsCount: state!.totalFeedsCount + 1,
    );

    // 進化判定
    _checkEvolution();
    await _savePet();
  }

  /// ペットと遊ぶ
  Future<void> playWithPet() async {
    if (state == null) return;

    int newSatiety = (state!.satiety - 10).clamp(0, 100); // 遊ぶとお腹が減る
    int newHappiness = (state!.happiness + 20).clamp(0, 100);
    int newExp = state!.experience + 5;

    state = state!.copyWith(
      satiety: newSatiety,
      happiness: newHappiness,
      experience: newExp % 100,
      level: state!.level + (newExp ~/ 100),
      lastPlayedAt: DateTime.now(),
      totalPlayCount: state!.totalPlayCount + 1,
    );

    _checkEvolution();
    await _savePet();
  }

  /// ペットをなでる
  Future<void> petPet() async {
    if (state == null) return;

    int newHappiness = (state!.happiness + 10).clamp(0, 100);

    state = state!.copyWith(
      happiness: newHappiness,
    );

    await _savePet();
  }

  /// 毎日のケアチェック（朝に1回呼び出し）
  Future<void> dailyCheck() async {
    if (state == null) return;

    DateTime lastPlayed = state!.lastPlayedAt;
    bool playedToday = DateTime.now().difference(lastPlayed).inHours < 24;

    int newHappiness = state!.happiness;
    int newSatiety = (state!.satiety - 5).clamp(0, 100); // 毎日少しずつお腹が減る

    if (!playedToday) {
      newHappiness = (newHappiness - 10).clamp(0, 100); // 遊ばないと不幸に
    } else {
      newHappiness = (newHappiness + 5).clamp(0, 100); // 遊んだなら幸せ
    }

    state = state!.copyWith(
      satiety: newSatiety,
      happiness: newHappiness,
    );

    await _savePet();
  }

  /// 単語を学習させる
  Future<void> learnWord(String word) async {
    if (state == null) return;

    final newWords = [...state!.learnedWords];
    if (!newWords.contains(word)) {
      newWords.add(word);
    }

    // 単語学習でコイン報酬
    int newExp = state!.experience + 10;

    state = state!.copyWith(
      learnedWords: newWords,
      experience: newExp % 100,
      level: state!.level + (newExp ~/ 100),
    );

    _checkEvolution();
    await _savePet();
  }

  /// 進化チェック（レベルに基づいて進化）
  void _checkEvolution() {
    if (state == null) return;

    EvolutionStage newStage = state!.evolutionStage;

    if (state!.level >= 50 && state!.evolutionStage == EvolutionStage.adult) {
      return; // 最高段階
    }

    if (state!.level >= 40 && state!.evolutionStage != EvolutionStage.adult) {
      newStage = EvolutionStage.adult;
    } else if (state!.level >= 25 && state!.evolutionStage == EvolutionStage.kids) {
      return; // 既に kids
    } else if (state!.level >= 25) {
      newStage = EvolutionStage.kids;
    } else if (state!.level >= 10 && state!.evolutionStage == EvolutionStage.baby) {
      return; // 既に baby
    } else if (state!.level >= 10) {
      newStage = EvolutionStage.baby;
    }

    if (newStage != state!.evolutionStage) {
      state = state!.copyWith(evolutionStage: newStage);
    }
  }

  /// ペットを保存
  Future<void> _savePet() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_petStorageKey, jsonEncode(state!.toJson()));
    } catch (e) {
      LoggerService.error('Error saving pet', tag: 'PetNotifier', exception: e);
    }
  }

  /// ペットをリセット
  Future<void> deletePet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_petStorageKey);
      state = null;
    } catch (e) {
      LoggerService.error('Error deleting pet', tag: 'PetNotifier', exception: e);
    }
  }
}

class PetStatsNotifier extends StateNotifier<PetStats> {
  static const String _statsStorageKey = 'eigo_kore_pet_stats';

  PetStatsNotifier()
      : super(
          const PetStats(
            totalPets: 0,
            maxLevel: 0,
            averageSatiety: 0,
            averageHappiness: 0,
            totalFeeds: 0,
            totalPlays: 0,
            lastInteractionAt: DateTime.epoch,
          ),
        ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsStorageKey);
      if (statsJson != null) {
        final json = jsonDecode(statsJson);
        state = PetStats.fromJson(json);
      }
    } catch (e) {
      LoggerService.error('Error loading pet stats', tag: 'PetStatsNotifier', exception: e);
    }
  }

  Future<void> updateStats(Pet pet) async {
    state = PetStats(
      totalPets: state.totalPets + 1,
      maxLevel: pet.level > state.maxLevel ? pet.level : state.maxLevel,
      averageSatiety: (state.averageSatiety + pet.satiety) / 2,
      averageHappiness: (state.averageHappiness + pet.happiness) / 2,
      totalFeeds: state.totalFeeds + pet.totalFeedsCount,
      totalPlays: state.totalPlays + pet.totalPlayCount,
      lastInteractionAt: DateTime.now(),
    );

    await _saveStats();
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsStorageKey, jsonEncode(state.toJson()));
    } catch (e) {
      LoggerService.error('Error saving pet stats', tag: 'PetStatsNotifier', exception: e);
    }
  }

  Future<void> resetStats() async {
    state = const PetStats(
      totalPets: 0,
      maxLevel: 0,
      averageSatiety: 0,
      averageHappiness: 0,
      totalFeeds: 0,
      totalPlays: 0,
      lastInteractionAt: DateTime.epoch,
    );
    await _saveStats();
  }
}

// ===== Firestore-backed Providers for Cloud Sync =====

/// Pet Service instance provider
final petServiceProvider = Provider((ref) {
  return PetService();
});

/// User's pet from Firestore
final userPetProvider = FutureProvider.family<Pet?, String>((ref, userId) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.getUserPet(userId);
});

/// Pet leaderboard provider
final petLeaderboardProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.getPetLeaderboard(limit: limit, orderBy: 'level');
});

/// User's pet rank provider
final userPetRankProvider = FutureProvider.family<int?, String>((ref, userId) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.getUserPetRank(userId, orderBy: 'level');
});

/// Pet status provider
final petStatusProvider = FutureProvider.family<PetStatus?, String>((ref, userId) async {
  final petService = ref.watch(petServiceProvider);
  try {
    return await petService.getPetStatus(userId);
  } catch (e) {
    LoggerService.error('Error getting pet status', tag: 'petStatusProvider', exception: e);
    return null;
  }
});

/// Pet statistics provider
final petStatsCloudProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.getPetStats(userId);
});
