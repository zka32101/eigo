import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/character_model.dart';

final characterCollectionProvider =
    StateNotifierProvider<CharacterCollectionNotifier, List<CollectedCharacter>>((ref) {
  return CharacterCollectionNotifier();
});

class CharacterCollectionNotifier extends StateNotifier<List<CollectedCharacter>> {
  static const String _storageKey = 'eigo_kore_character_collection';

  CharacterCollectionNotifier() : super([]) {
    _loadCollection();
  }

  /// コレクションをロード
  Future<void> _loadCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items = decoded
            .map((json) => CollectedCharacter.fromJson(json as Map<String, dynamic>))
            .toList();
        state = items;
      } catch (e) {
        print('Error loading character collection: $e');
      }
    }
  }

  /// コレクションを保存
  Future<void> _saveCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// キャラクターを収集
  Future<void> collectCharacter(Character character) async {
    final existingIndex = state.indexWhere((c) => c.character.id == character.id);

    if (existingIndex >= 0) {
      // すでに収集済みの場合は好感度を上げる
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(affection: (existing.affection + 10).clamp(0, 100)),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // 新しいキャラクターを収集
      state = [
        ...state,
        CollectedCharacter(
          character: character,
          collectedAt: DateTime.now(),
          level: 1,
          affection: 0,
        ),
      ];
    }
    await _saveCollection();
  }

  /// キャラクターのレベルアップ
  Future<bool> levelUpCharacter(String characterId) async {
    final existingIndex = state.indexWhere((c) => c.character.id == characterId);

    if (existingIndex < 0) {
      return false; // キャラクターが見つからない
    }

    final existing = state[existingIndex];
    if (existing.level >= 10) {
      return false; // 最大レベルに達している
    }

    state = [
      ...state.sublist(0, existingIndex),
      existing.copyWith(level: existing.level + 1),
      ...state.sublist(existingIndex + 1),
    ];
    await _saveCollection();
    return true;
  }

  /// キャラクターの好感度を上げる
  Future<void> increaseAffection(String characterId, {int amount = 5}) async {
    final existingIndex = state.indexWhere((c) => c.character.id == characterId);

    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(affection: (existing.affection + amount).clamp(0, 100)),
        ...state.sublist(existingIndex + 1),
      ];
      await _saveCollection();
    }
  }

  /// キャラクターをお気に入りに設定
  Future<void> setFavorite(String characterId, bool isFavorite) async {
    final existingIndex = state.indexWhere((c) => c.character.id == characterId);

    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(isFavorite: isFavorite),
        ...state.sublist(existingIndex + 1),
      ];
      await _saveCollection();
    }
  }

  /// キャラクターを取得
  CollectedCharacter? getCharacter(String characterId) {
    try {
      return state.firstWhere((c) => c.character.id == characterId);
    } catch (e) {
      return null;
    }
  }

  /// キャラクターを持っているか確認
  bool hasCharacter(String characterId) {
    return getCharacter(characterId) != null;
  }

  /// お気に入りキャラクターを取得
  List<CollectedCharacter> getFavorites() {
    return state.where((c) => c.isFavorite).toList();
  }

  /// レアリティ別キャラクターを取得
  List<CollectedCharacter> getCharactersByRarity(String rarity) {
    return state.where((c) => c.character.rarity == rarity).toList();
  }

  /// タイプ別キャラクターを取得
  List<CollectedCharacter> getCharactersByType(String type) {
    return state.where((c) => c.character.type == type).toList();
  }

  /// すべてのキャラクターをクリア（テスト用）
  Future<void> clear() async {
    state = [];
    await _saveCollection();
  }
}

/// キャラクター収集の統計情報
final characterCollectionStatsProvider =
    Provider<CharacterCollectionStats>((ref) {
  final collection = ref.watch(characterCollectionProvider);
  final totalAvailable = characterCatalog.length;
  final collected = collection.length;
  final totalLevel = collection.fold<int>(0, (sum, c) => sum + c.level);
  final averageAffection =
      collected > 0 ? collection.fold<int>(0, (sum, c) => sum + c.affection) ~/ collected : 0;

  return CharacterCollectionStats(
    totalAvailable: totalAvailable,
    collected: collected,
    completionRate: (collected / totalAvailable * 100).round(),
    totalLevel: totalLevel,
    averageAffection: averageAffection,
    commonCount: collection.where((c) => c.character.rarity == 'common').length,
    uncommonCount: collection.where((c) => c.character.rarity == 'uncommon').length,
    rareCount: collection.where((c) => c.character.rarity == 'rare').length,
    legendaryCount: collection.where((c) => c.character.rarity == 'legendary').length,
  );
});

class CharacterCollectionStats {
  final int totalAvailable;
  final int collected;
  final int completionRate; // パーセント
  final int totalLevel;
  final int averageAffection;
  final int commonCount;
  final int uncommonCount;
  final int rareCount;
  final int legendaryCount;

  CharacterCollectionStats({
    required this.totalAvailable,
    required this.collected,
    required this.completionRate,
    required this.totalLevel,
    required this.averageAffection,
    required this.commonCount,
    required this.uncommonCount,
    required this.rareCount,
    required this.legendaryCount,
  });
}

/// 未収集のキャラクターを取得
final uncollectedCharactersProvider =
    Provider<List<Character>>((ref) {
  final collection = ref.watch(characterCollectionProvider);
  final collectedIds = collection.map((c) => c.character.id).toSet();
  return characterCatalog.where((c) => !collectedIds.contains(c.id)).toList();
});
