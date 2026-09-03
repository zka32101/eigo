import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../models/english_town_advanced.dart';
import '../providers/english_town_provider.dart';

/// ==================== POLISH & OPTIMIZATION (Phase 5) ====================

/// NPC mood state for current session
final npcMoodProvider = StateProvider<NPCMoodState>((ref) {
  // Initialize with random mood for variety
  final hour = DateTime.now().hour;
  if (hour >= 22 || hour < 7) {
    return NPCMoodState.tired;
  } else if (hour >= 15 && hour < 18) {
    return NPCMoodState.happy;
  } else if (hour >= 19 && hour < 22) {
    return NPCMoodState.excited;
  }
  return NPCMoodState.neutral;
});

/// Current weather effect
final weatherEffectProvider = StateProvider<WeatherEffect>((ref) {
  // In real implementation, fetch from weather API
  // For now, return based on time of day for variation
  final hour = DateTime.now().hour;
  if (hour % 4 == 0) return WeatherEffect.rainy;
  if (hour % 4 == 1) return WeatherEffect.snowy;
  if (hour % 4 == 2) return WeatherEffect.sunny;
  return WeatherEffect.cloudy;
});

/// Get dialogue variation based on time, weather, and mood
final npcDialogueVariationProvider =
    Provider.family<String, ({
      NPC npc,
      Location location,
      TimeOfDay timeOfDay,
      WeatherEffect weather,
      NPCMoodState mood,
    })>((ref, params) {
  // This would use DialogueVariationPool in full implementation
  // For now, return context-aware variation
  final baseGreeting = "Hello! Nice to see you today.";

  // Modify based on conditions
  if (params.mood == NPCMoodState.happy) {
    return "$baseGreeting I'm in such a great mood!";
  } else if (params.mood == NPCMoodState.excited) {
    return "$baseGreeting I'm so excited to chat with you!";
  } else if (params.mood == NPCMoodState.tired) {
    return "$baseGreeting... how can I help?";
  }

  // Time-of-day variations
  if (params.timeOfDay == TimeOfDay.morning) {
    return "Good morning! Ready to practice English?";
  } else if (params.timeOfDay == TimeOfDay.evening) {
    return "Good evening! Shall we have a conversation?";
  } else if (params.timeOfDay == TimeOfDay.night) {
    return "Wow, you're studying late! That's dedication.";
  }

  // Weather variations
  if (params.weather == WeatherEffect.snowy) {
    return "Such beautiful snowy weather! Let's chat to stay warm.";
  } else if (params.weather == WeatherEffect.rainy) {
    return "Perfect rainy day for learning English indoors!";
  }

  return baseGreeting;
});

/// XP modifier based on time of day
final timeOfDayXpModifierProvider =
    Provider.family<double, TimeOfDay>((ref, timeOfDay) {
  switch (timeOfDay) {
    case TimeOfDay.morning:
      return 1.0; // Normal
    case TimeOfDay.afternoon:
      return 1.1; // 10% bonus
    case TimeOfDay.evening:
      return 1.2; // 20% bonus (prime learning time)
    case TimeOfDay.night:
      return 1.05; // 5% bonus
  }
});

/// XP modifier based on weather
final weatherXpModifierProvider =
    Provider.family<double, WeatherEffect>((ref, weather) {
  switch (weather) {
    case WeatherEffect.sunny:
      return 1.0; // Normal
    case WeatherEffect.rainy:
      return 1.1; // 10% bonus (cozy learning)
    case WeatherEffect.cloudy:
      return 1.0; // Normal
    case WeatherEffect.snowy:
      return 1.2; // 20% bonus (festive)
  }
});

/// Combined XP modifier for current conditions
final currentXpModifierProvider = Provider<double>((ref) {
  final timeOfDay = ref.watch(townProgressProvider).currentTimeOfDay;
  final weather = ref.watch(townProgressProvider).currentWeather;

  final timeModifier = ref.watch(timeOfDayXpModifierProvider(timeOfDay));
  final weatherModifier = ref.watch(weatherXpModifierProvider(weather));

  return timeModifier * weatherModifier;
});

/// Performance metrics provider
final performanceMetricsProvider =
    StateProvider<ConversationPerformanceMetrics>((ref) {
  final progress = ref.watch(townProgressProvider);

  return ConversationPerformanceMetrics(
    totalConversations: progress.totalConversations,
    averageResponseTimeMs: 800, // Baseline
    memoryUsedMb: 45,
    avgFrameRate: 60,
    cachedDialoguesCount: 250,
  );
});

/// Dialogue cache instance
final dialogueCacheProvider =
    StateProvider<DialogueCache>((ref) => DialogueCache());

/// Engagement analytics
final engagementAnalyticsProvider =
    Provider<EngagementAnalytics>((ref) {
  final progress = ref.watch(townProgressProvider);
  final npcStats = ref.watch(npcStatsProvider);

  return EngagementAnalytics(
    totalSessionsPlayed: 1, // TODO: Track sessions
    totalPlayTime: Duration(
      minutes: (progress.totalConversations * 5), // Estimate 5 min per conversation
    ),
    npcPreferences: Map.from(progress.npcConversationCounts),
    locationPreferences: {}, // TODO: Track location visits with counts
    difficultyProgress: {}, // TODO: Track difficulty progression
    averageResponseAccuracy: 75.0, // TODO: Calculate from evaluations
    longestStreak: 0, // TODO: Track streaks
  );
});

/// Engagement score (0-100)
final engagementScoreProvider = Provider<int>((ref) {
  final analytics = ref.watch(engagementAnalyticsProvider);
  return analytics.getEngagementScore();
});

/// Recommended next NPC
final recommendedNPCProvider = Provider<NPC?>((ref) {
  final analytics = ref.watch(engagementAnalyticsProvider);
  final townMap = ref.watch(townMapProvider);

  final recommendedId = analytics.getRecommendedNPC();
  if (recommendedId == null) return null;

  return townMap.getNPC(recommendedId);
});

/// Animation configuration
final rewardAnimationConfigProvider =
    StateProvider<RewardAnimationConfig>((ref) {
  return const RewardAnimationConfig();
});

/// Should show performance optimizations UI
final showPerformanceOptimizationsProvider =
    StateProvider<bool>((ref) {
  final metrics = ref.watch(performanceMetricsProvider);
  return !metrics.isOptimized;
});

/// ==================== DIALOGUE VARIATIONS ====================

/// Get all time-based dialogue variations
final timeDialogueVariationsProvider =
    Provider<Map<TimeOfDay, String>>((ref) {
  return {
    TimeOfDay.morning: "Good morning! Let's practice English together.",
    TimeOfDay.afternoon: "Afternoon greetings! Ready for a conversation?",
    TimeOfDay.evening: "Good evening! The perfect time to learn.",
    TimeOfDay.night: "Late night learning? You're dedicated!",
  };
});

/// Get all weather-based dialogue variations
final weatherDialogueVariationsProvider =
    Provider<Map<WeatherEffect, String>>((ref) {
  return {
    WeatherEffect.sunny: "What a beautiful sunny day to learn English!",
    WeatherEffect.rainy: "Perfect cozy weather for learning indoors.",
    WeatherEffect.cloudy: "Let's make this day brighter by learning English.",
    WeatherEffect.snowy: "Wow, it's snowing! Perfect time for studying.",
  };
});

/// Get all mood-based dialogue variations
final moodDialogueVariationsProvider =
    Provider<Map<NPCMoodState, String>>((ref) {
  return {
    NPCMoodState.happy: "I'm so happy to chat with you today!",
    NPCMoodState.neutral: "Hello! How can I help you?",
    NPCMoodState.tired: "I'm a bit tired... but let's chat anyway.",
    NPCMoodState.excited: "I'm so excited to talk with you!",
    NPCMoodState.sad: "I'm feeling a bit down... talking to you helps though.",
  };
});

/// ==================== UI POLISH PROVIDERS ====================

/// Should show confetti animation on reward
final shouldShowConfettiProvider =
    StateProvider.family<bool, int>((ref, milestoneId) {
  return true; // Show for all milestones in Phase 5
});

/// Should play sound effects
final soundEffectsEnabledProvider = StateProvider<bool>((ref) {
  return true; // TODO: Connect to settings
});

/// Should show particle effects
final particleEffectsEnabledProvider = StateProvider<bool>((ref) {
  return true; // TODO: Connect to settings
});

/// Animation duration multiplier (for accessibility)
final animationDurationMultiplierProvider =
    StateProvider<double>((ref) {
  return 1.0; // TODO: Connect to system animation settings
});

export '../models/english_town_advanced.dart'
    show
        NPCMoodState,
        WeatherEffect,
        TimeOfDayDialogueVariation,
        RewardAnimationConfig,
        DialogueVariationPool,
        ConversationPerformanceMetrics,
        DialogueCache,
        EngagementAnalytics;
