import 'english_town_model.dart';

/// Advanced features for English-Only Town Phase 5

/// NPC mood variations affect dialogue tone and response
enum NPCMoodState {
  happy,      // More encouraging, generous rewards
  neutral,    // Standard dialogue
  tired,      // Shorter responses, reduced rewards
  excited,    // More engaging, bonus rewards
  sad,        // Less responsive, lower rewards
}

/// Weather effects dialogue context and NPC behavior
enum WeatherEffect {
  sunny,      // Outdoor NPCs more talkative, bonus to outdoor locations
  rainy,      // Indoor NPCs more available, bonus to indoor locations
  cloudy,     // Neutral effect
  snowy,      // Festive dialogue, holiday-themed rewards
}

/// Time-of-day specific dialogue variations
class TimeOfDayDialogueVariation {
  final TimeOfDay timeOfDay;
  final String dialoguePrefix;
  final String dialogueSuffix;
  final int xpModifier; // +/-% XP modifier
  final List<String> topicKeywords;

  TimeOfDayDialogueVariation({
    required this.timeOfDay,
    required this.dialoguePrefix,
    required this.dialogueSuffix,
    required this.xpModifier,
    required this.topicKeywords,
  });
}

/// Weather-based dialogue context
class WeatherDialogueContext {
  final WeatherEffect weather;
  final String weatherDescription;
  final Map<String, int> locationAccessibilityModifier;
  final List<String> weatherTopics;

  WeatherDialogueContext({
    required this.weather,
    required this.weatherDescription,
    required this.locationAccessibilityModifier,
    required this.weatherTopics,
  });
}

/// Animation configuration for reward popups
class RewardAnimationConfig {
  final Duration slideInDuration;
  final Duration holdDuration;
  final Duration slideOutDuration;
  final Duration coinSpinDuration;
  final Duration xpPulseDuration;

  const RewardAnimationConfig({
    this.slideInDuration = const Duration(milliseconds: 500),
    this.holdDuration = const Duration(milliseconds: 2000),
    this.slideOutDuration = const Duration(milliseconds: 300),
    this.coinSpinDuration = const Duration(milliseconds: 800),
    this.xpPulseDuration = const Duration(milliseconds: 600),
  });
}

/// Dialogue variation pool for each NPC and location combination
class DialogueVariationPool {
  final String npcId;
  final String locationId;
  final Map<TimeOfDay, List<String>> timeSpecificDialogues;
  final Map<WeatherEffect, List<String>> weatherSpecificDialogues;
  final Map<NPCMoodState, List<String>> moodSpecificDialogues;
  final List<String> casualDialogues;

  DialogueVariationPool({
    required this.npcId,
    required this.locationId,
    required this.timeSpecificDialogues,
    required this.weatherSpecificDialogues,
    required this.moodSpecificDialogues,
    required this.casualDialogues,
  });

  /// Get appropriate dialogue based on current conditions
  String getDialogue({
    required TimeOfDay timeOfDay,
    required WeatherEffect weather,
    required NPCMoodState mood,
  }) {
    // Priority: mood-specific > time-specific > weather-specific > casual
    final moodDialogues = moodSpecificDialogues[mood];
    if (moodDialogues != null && moodDialogues.isNotEmpty) {
      return moodDialogues[(DateTime.now().millisecondsSinceEpoch) % moodDialogues.length];
    }

    final timeDialogues = timeSpecificDialogues[timeOfDay];
    if (timeDialogues != null && timeDialogues.isNotEmpty) {
      return timeDialogues[(DateTime.now().millisecondsSinceEpoch) % timeDialogues.length];
    }

    final weatherDialogues = weatherSpecificDialogues[weather];
    if (weatherDialogues != null && weatherDialogues.isNotEmpty) {
      return weatherDialogues[(DateTime.now().millisecondsSinceEpoch) % weatherDialogues.length];
    }

    if (casualDialogues.isNotEmpty) {
      return casualDialogues[(DateTime.now().millisecondsSinceEpoch) % casualDialogues.length];
    }

    return "Hello! How are you today?";
  }
}

/// Performance metrics for optimization
class ConversationPerformanceMetrics {
  final int totalConversations;
  final int averageResponseTimeMs;
  final int memoryUsedMb;
  final double avgFrameRate;
  final int cachedDialoguesCount;

  ConversationPerformanceMetrics({
    required this.totalConversations,
    required this.averageResponseTimeMs,
    required this.memoryUsedMb,
    required this.avgFrameRate,
    required this.cachedDialoguesCount,
  });

  bool get isOptimized {
    return averageResponseTimeMs < 1000 && avgFrameRate >= 50;
  }
}

/// Dialogue caching strategy
class DialogueCache {
  final int maxCacheSize; // Max dialogues to keep in memory
  final Duration cacheTtl; // Time to live for cached dialogues
  final Map<String, CachedDialogue> _cache = {};

  DialogueCache({
    this.maxCacheSize = 500,
    this.cacheTtl = const Duration(hours: 1),
  });

  void cacheDialogue(String key, String dialogue) {
    if (_cache.length >= maxCacheSize) {
      // Remove oldest entry
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = CachedDialogue(
      dialogue: dialogue,
      cachedAt: DateTime.now(),
    );
  }

  String? getDialogue(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    // Check if cache expired
    if (DateTime.now().difference(cached.cachedAt) > cacheTtl) {
      _cache.remove(key);
      return null;
    }

    return cached.dialogue;
  }

  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((_, cached) {
      return now.difference(cached.cachedAt) > cacheTtl;
    });
  }

  void clear() => _cache.clear();
  int get size => _cache.length;
}

class CachedDialogue {
  final String dialogue;
  final DateTime cachedAt;

  CachedDialogue({
    required this.dialogue,
    required this.cachedAt,
  });
}

/// Analytics for understanding player behavior and engagement
class EngagementAnalytics {
  final int totalSessionsPlayed;
  final Duration totalPlayTime;
  final Map<String, int> npcPreferences; // npcId -> interaction count
  final Map<String, int> locationPreferences; // locationId -> visit count
  final Map<ConversationDifficulty, int> difficultyProgress;
  final double averageResponseAccuracy;
  final int longestStreak;

  EngagementAnalytics({
    required this.totalSessionsPlayed,
    required this.totalPlayTime,
    required this.npcPreferences,
    required this.locationPreferences,
    required this.difficultyProgress,
    required this.averageResponseAccuracy,
    required this.longestStreak,
  });

  /// Calculate player engagement score (0-100)
  int getEngagementScore() {
    int score = 0;

    // Session frequency (max 20 points)
    score += (totalSessionsPlayed / 50).toInt().clamp(0, 20);

    // Total playtime (max 20 points)
    score += (totalPlayTime.inMinutes / 300).toInt().clamp(0, 20);

    // Accuracy (max 20 points)
    score += (averageResponseAccuracy / 5).toInt().clamp(0, 20);

    // Streak consistency (max 20 points)
    score += (longestStreak / 10).toInt().clamp(0, 20);

    // Location diversity (max 20 points)
    score += (locationPreferences.length / 0.4).toInt().clamp(0, 20);

    return score.clamp(0, 100);
  }

  /// Get next recommended NPC based on preferences
  String? getRecommendedNPC() {
    // Recommend least-talked-to NPC
    if (npcPreferences.isEmpty) return null;
    return npcPreferences.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }
}
