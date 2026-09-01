import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/camera_scan_model.dart';

/// My Dictionary - all scanned vocabulary items
final myDictionaryProvider = StateNotifierProvider<MyDictionaryNotifier, List<ScannedVocabulary>>((ref) {
  return MyDictionaryNotifier();
});

class MyDictionaryNotifier extends StateNotifier<List<ScannedVocabulary>> {
  static const String _storageKey = 'eigo_kore_my_dictionary';
  
  MyDictionaryNotifier() : super([]) {
    _loadDictionary();
  }
  
  Future<void> _loadDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => ScannedVocabulary.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading dictionary: $e');
    }
  }
  
  Future<void> _saveDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving dictionary: $e');
    }
  }
  
  /// Add scanned vocabulary to dictionary
  Future<void> addVocabulary(ScannedVocabulary vocabulary) async {
    state = [...state, vocabulary];
    await _saveDictionary();
  }
  
  /// Remove vocabulary from dictionary
  Future<void> removeVocabulary(String itemId) async {
    state = state.where((item) => item.itemId != itemId).toList();
    await _saveDictionary();
  }
  
  /// Increment use count (when reviewing)
  Future<void> incrementUseCount(String itemId) async {
    state = state.map((item) {
      if (item.itemId == itemId) {
        return item.copyWith(useCount: item.useCount + 1);
      }
      return item;
    }).toList();
    await _saveDictionary();
  }
  
  /// Get vocabulary by ID
  ScannedVocabulary? getVocabulary(String itemId) {
    try {
      return state.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get vocabulary by category
  List<ScannedVocabulary> getByCategory(String category) {
    return state.where((item) => item.category == category).toList();
  }
}

/// Vocabulary categories
final vocabularyCategoriesProvider = StateNotifierProvider<CategoriesNotifier, List<VocabularyCategory>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<VocabularyCategory>> {
  static const String _storageKey = 'eigo_kore_vocab_categories';
  
  CategoriesNotifier() : super(_initializeCategories()) {
    _loadCategories();
  }
  
  static List<VocabularyCategory> _initializeCategories() {
    return [
      VocabularyCategory(
        categoryId: 'furniture',
        categoryName: 'Furniture',
        icon: '🪑',
        itemCount: 0,
        vocabularyIds: [],
      ),
      VocabularyCategory(
        categoryId: 'food',
        categoryName: 'Food',
        icon: '🍎',
        itemCount: 0,
        vocabularyIds: [],
      ),
      VocabularyCategory(
        categoryId: 'animals',
        categoryName: 'Animals',
        icon: '🐾',
        itemCount: 0,
        vocabularyIds: [],
      ),
      VocabularyCategory(
        categoryId: 'nature',
        categoryName: 'Nature',
        icon: '🌿',
        itemCount: 0,
        vocabularyIds: [],
      ),
      VocabularyCategory(
        categoryId: 'objects',
        categoryName: 'Objects',
        icon: '🔧',
        itemCount: 0,
        vocabularyIds: [],
      ),
    ];
  }
  
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => VocabularyCategory.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }
  
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((cat) => cat.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving categories: $e');
    }
  }
  
  /// Add vocabulary to category
  Future<void> addToCategory(String categoryId, String vocabularyId) async {
    state = state.map((cat) {
      if (cat.categoryId == categoryId) {
        final ids = [...cat.vocabularyIds, vocabularyId];
        return cat.copyWith(
          itemCount: ids.length,
          vocabularyIds: ids,
        );
      }
      return cat;
    }).toList();
    await _saveCategories();
  }
}

/// Dictionary statistics
final dictionaryStatsProvider = StateNotifierProvider<DictionaryStatsNotifier, DictionaryStats>((ref) {
  return DictionaryStatsNotifier();
});

class DictionaryStatsNotifier extends StateNotifier<DictionaryStats> {
  static const String _storageKey = 'eigo_kore_dictionary_stats';
  
  DictionaryStatsNotifier() : super(
    DictionaryStats(
      totalItems: 0,
      totalScans: 0,
      categories: [],
      lastScanAt: DateTime.now(),
      longestStreak: 0,
      currentStreak: 0,
      unlockedBadges: [],
    ),
  ) {
    _loadStats();
  }
  
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = DictionaryStats.fromJson(json);
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }
  
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving stats: $e');
    }
  }
  
  /// Record a new scan
  Future<void> recordScan(String category) async {
    final now = DateTime.now();
    final lastScan = state.lastScanAt;
    
    // Check if consecutive day
    final isConsecutive = now.difference(lastScan).inHours < 24;
    final newCurrentStreak = isConsecutive ? state.currentStreak + 1 : 1;
    
    // Update longest streak
    final newLongestStreak = newCurrentStreak > state.longestStreak 
        ? newCurrentStreak 
        : state.longestStreak;
    
    // Update categories list
    final newCategories = {...state.categories, category}.toList();
    
    state = DictionaryStats(
      totalItems: state.totalItems + 1,
      totalScans: state.totalScans + 1,
      categories: newCategories,
      lastScanAt: now,
      longestStreak: newLongestStreak,
      currentStreak: newCurrentStreak,
      unlockedBadges: state.unlockedBadges,
    );
    
    await _saveStats();
  }
  
  /// Unlock badge
  Future<void> unlockBadge(String badgeId) async {
    if (!state.unlockedBadges.contains(badgeId)) {
      state = state.copyWith(
        unlockedBadges: [...state.unlockedBadges, badgeId],
      );
      await _saveStats();
    }
  }
}

/// Scan achievements
final scanAchievementsProvider = StateNotifierProvider<ScanAchievementsNotifier, List<ScanAchievement>>((ref) {
  return ScanAchievementsNotifier();
});

class ScanAchievementsNotifier extends StateNotifier<List<ScanAchievement>> {
  static const String _storageKey = 'eigo_kore_scan_achievements';
  
  ScanAchievementsNotifier() : super(_initializeAchievements()) {
    _loadAchievements();
  }
  
  static List<ScanAchievement> _initializeAchievements() {
    return [
      ScanAchievement(
        achievementId: 'first_scan',
        title: 'スキャナー',
        description: 'はじめて1つのアイテムをスキャン',
        icon: '📸',
        targetCount: 1,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        coinsReward: 50,
      ),
      ScanAchievement(
        achievementId: 'ten_items',
        title: 'コレクター',
        description: '10個のアイテムをスキャン',
        icon: '🎯',
        targetCount: 10,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        coinsReward: 200,
      ),
      ScanAchievement(
        achievementId: 'fifty_items',
        title: 'マスターコレクター',
        description: '50個のアイテムをスキャン',
        icon: '👑',
        targetCount: 50,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        coinsReward: 500,
      ),
      ScanAchievement(
        achievementId: 'all_categories',
        title: 'カテゴリー制覇',
        description: 'すべてのカテゴリーからアイテムをスキャン',
        icon: '🌈',
        targetCount: 5,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        coinsReward: 300,
      ),
      ScanAchievement(
        achievementId: 'daily_streak_7',
        title: 'スキャン習慣',
        description: '7日連続でスキャン',
        icon: '🔥',
        targetCount: 7,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        coinsReward: 250,
      ),
    ];
  }
  
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => ScanAchievement.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }
  
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }
  
  /// Update achievement progress
  Future<void> updateProgress(String achievementId, int newCount) async {
    state = state.map((achievement) {
      if (achievement.achievementId == achievementId) {
        final isNowUnlocked = newCount >= achievement.targetCount && !achievement.isUnlocked;
        return achievement.copyWith(
          currentCount: newCount,
          isUnlocked: isNowUnlocked ? true : achievement.isUnlocked,
          unlockedAt: isNowUnlocked ? DateTime.now() : achievement.unlockedAt,
        );
      }
      return achievement;
    }).toList();
    await _saveAchievements();
  }
  
  /// Get unlocked achievements
  List<ScanAchievement> getUnlocked() {
    return state.where((a) => a.isUnlocked).toList();
  }
  
  /// Get in-progress achievements
  List<ScanAchievement> getInProgress() {
    return state.where((a) => !a.isUnlocked && a.currentCount > 0).toList();
  }
}

/// Mock AI recognition results (simulates Gemini API)
final mockRecognitionDatabase = {
  'apple': AIRecognitionResult(
    objectName: 'apple',
    confidence: 0.95,
    japaneseTranslation: 'りんご',
    pronunciationIPA: 'ˈæpəl',
    category: 'food',
    relatedWords: ['fruit', 'red', 'sweet'],
    detailedDescription: 'A round red or green fruit grown on apple trees, sweet and crispy.',
  ),
  'chair': AIRecognitionResult(
    objectName: 'chair',
    confidence: 0.92,
    japaneseTranslation: 'いす',
    pronunciationIPA: 'tʃɛr',
    category: 'furniture',
    relatedWords: ['seat', 'furniture', 'sit'],
    detailedDescription: 'A piece of furniture with a backrest and four legs for sitting.',
  ),
  'cat': AIRecognitionResult(
    objectName: 'cat',
    confidence: 0.98,
    japaneseTranslation: 'ねこ',
    pronunciationIPA: 'kæt',
    category: 'animals',
    relatedWords: ['pet', 'animal', 'meow'],
    detailedDescription: 'A small domesticated carnivorous mammal with fur, whiskers, and a tail.',
  ),
  'flower': AIRecognitionResult(
    objectName: 'flower',
    confidence: 0.89,
    japaneseTranslation: 'はな',
    pronunciationIPA: 'ˈflaʊər',
    category: 'nature',
    relatedWords: ['plant', 'bloom', 'colorful'],
    detailedDescription: 'A reproductive structure of flowering plants, typically colorful and fragrant.',
  ),
  'book': AIRecognitionResult(
    objectName: 'book',
    confidence: 0.91,
    japaneseTranslation: 'ほん',
    pronunciationIPA: 'bʊk',
    category: 'objects',
    relatedWords: ['read', 'pages', 'knowledge'],
    detailedDescription: 'A set of printed or blank pages bound together with a cover.',
  ),
};

/// Simulate AI recognition (placeholder for Gemini API)
final aiRecognitionProvider = FutureProvider.autoDispose.family<AIRecognitionResult?, String>((ref, imageLabel) async {
  // In production, this would call Gemini API with the image
  // For now, return mock result based on label
  await Future.delayed(const Duration(milliseconds: 500));
  
  final lowerLabel = imageLabel.toLowerCase();
  for (final key in mockRecognitionDatabase.keys) {
    if (lowerLabel.contains(key) || key.contains(lowerLabel)) {
      return mockRecognitionDatabase[key];
    }
  }
  
  // Default mock result if not found
  return null;
});
