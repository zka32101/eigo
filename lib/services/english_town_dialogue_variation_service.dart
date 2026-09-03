import '../models/english_town_model.dart';
import '../models/english_town_advanced.dart';
import '../providers/english_town_polish_provider.dart';

/// Service for generating contextual dialogue variations
class EnglishTownDialogueVariationService {
  /// Get greeting based on multiple contextual factors
  static String getContextualGreeting({
    required NPC npc,
    required TimeOfDay timeOfDay,
    required WeatherEffect weather,
    required NPCMoodState mood,
  }) {
    final moodPrefix = _getMoodPrefix(mood);
    final timeGreeting = _getTimeGreeting(timeOfDay);
    final weatherContext = _getWeatherContext(weather);

    return '$moodPrefix $timeGreeting ${npc.name}! $weatherContext';
  }

  /// Get dialogue opening based on context
  static String getDialogueOpening({
    required NPCMoodState mood,
    required TimeOfDay timeOfDay,
    required WeatherEffect weather,
  }) {
    switch (mood) {
      case NPCMoodState.happy:
        return _getHappyOpening(timeOfDay, weather);
      case NPCMoodState.excited:
        return _getExcitedOpening(timeOfDay, weather);
      case NPCMoodState.tired:
        return _getTiredOpening(timeOfDay, weather);
      case NPCMoodState.sad:
        return _getSadOpening(timeOfDay, weather);
      case NPCMoodState.neutral:
        return _getNeutralOpening(timeOfDay, weather);
    }
  }

  /// Get dialogue closing based on context
  static String getDialogueClosing({
    required NPCMoodState mood,
    required TimeOfDay timeOfDay,
  }) {
    switch (mood) {
      case NPCMoodState.happy:
        return "That was wonderful to discuss with you!";
      case NPCMoodState.excited:
        return "I hope we can chat again soon! This was so much fun!";
      case NPCMoodState.tired:
        return "Thanks for the conversation... I need some rest.";
      case NPCMoodState.sad:
        return "I appreciate talking with you. It helps.";
      case NPCMoodState.neutral:
        return "Thank you for the conversation.";
    }
  }

  /// Get topic suggestion based on weather
  static String getWeatherTopic(WeatherEffect weather) {
    switch (weather) {
      case WeatherEffect.sunny:
        return "The sunshine is so beautiful! Have you been outdoors today?";
      case WeatherEffect.rainy:
        return "This rainy weather is perfect for having deep conversations indoors.";
      case WeatherEffect.cloudy:
        return "It's a bit cloudy today. How are you feeling?";
      case WeatherEffect.snowy:
        return "Look at this wonderful snow! Isn't it magical?";
    }
  }

  /// Get time-specific topic suggestion
  static String getTimeTopic(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return "How was your morning? Did you have a good breakfast?";
      case TimeOfDay.afternoon:
        return "How's your day going so far?";
      case TimeOfDay.evening:
        return "It's getting dark. What did you do today?";
      case TimeOfDay.night:
        return "It's quite late! Are you working hard on your English?";
    }
  }

  /// Get mood modifier for response quality
  static double getMoodResponseQuality(NPCMoodState mood) {
    switch (mood) {
      case NPCMoodState.happy:
        return 1.2; // More engaging responses
      case NPCMoodState.excited:
        return 1.3; // Very engaging
      case NPCMoodState.neutral:
        return 1.0; // Standard
      case NPCMoodState.tired:
        return 0.7; // Shorter responses
      case NPCMoodState.sad:
        return 0.8; // Less detailed
    }
  }

  /// Get mood modifier for reward
  static double getMoodRewardMultiplier(NPCMoodState mood) {
    switch (mood) {
      case NPCMoodState.happy:
        return 1.15; // 15% bonus
      case NPCMoodState.excited:
        return 1.25; // 25% bonus
      case NPCMoodState.neutral:
        return 1.0;
      case NPCMoodState.tired:
        return 0.85; // 15% penalty
      case NPCMoodState.sad:
        return 0.9; // 10% penalty
    }
  }

  /// Get weather modifier for reward
  static double getWeatherRewardMultiplier(WeatherEffect weather) {
    switch (weather) {
      case WeatherEffect.sunny:
        return 1.0;
      case WeatherEffect.rainy:
        return 1.1; // 10% bonus (cozy)
      case WeatherEffect.cloudy:
        return 1.0;
      case WeatherEffect.snowy:
        return 1.2; // 20% bonus (festive)
    }
  }

  /// Get time modifier for reward
  static double getTimeRewardMultiplier(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return 1.0;
      case TimeOfDay.afternoon:
        return 1.1; // 10% bonus
      case TimeOfDay.evening:
        return 1.2; // 20% bonus (prime time)
      case TimeOfDay.night:
        return 1.05; // 5% bonus
    }
  }

  // Private helper methods

  static String _getMoodPrefix(NPCMoodState mood) {
    switch (mood) {
      case NPCMoodState.happy:
        return "😊 Oh, how wonderful!";
      case NPCMoodState.excited:
        return "🎉 Wow, amazing!";
      case NPCMoodState.tired:
        return "😴 Oh, hello...";
      case NPCMoodState.sad:
        return "😔 Hello there...";
      case NPCMoodState.neutral:
        return "👋 Hello!";
    }
  }

  static String _getTimeGreeting(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return "Good morning!";
      case TimeOfDay.afternoon:
        return "Good afternoon!";
      case TimeOfDay.evening:
        return "Good evening!";
      case TimeOfDay.night:
        return "Good night!";
    }
  }

  static String _getWeatherContext(WeatherEffect weather) {
    switch (weather) {
      case WeatherEffect.sunny:
        return "What a beautiful sunny day!";
      case WeatherEffect.rainy:
        return "Perfect cozy weather for learning.";
      case WeatherEffect.cloudy:
        return "It's a peaceful cloudy day.";
      case WeatherEffect.snowy:
        return "The snow is so beautiful!";
    }
  }

  static String _getHappyOpening(TimeOfDay timeOfDay, WeatherEffect weather) {
    if (weather == WeatherEffect.sunny) {
      return "I'm in such a great mood with this lovely weather! Let's have an amazing conversation!";
    } else if (timeOfDay == TimeOfDay.morning) {
      return "What a great morning to start our chat! I'm feeling wonderful!";
    }
    return "I'm so happy to see you today! Let's make this conversation special!";
  }

  static String _getExcitedOpening(TimeOfDay timeOfDay, WeatherEffect weather) {
    if (weather == WeatherEffect.snowy) {
      return "Isn't this festive weather amazing? I'm so excited to talk with you!";
    } else if (timeOfDay == TimeOfDay.afternoon) {
      return "The day is still young and I'm so excited! Let's have a fantastic conversation!";
    }
    return "I'm absolutely thrilled to chat with you today!";
  }

  static String _getTiredOpening(TimeOfDay timeOfDay, WeatherEffect weather) {
    if (timeOfDay == TimeOfDay.night) {
      return "It's getting late... but I'm here to chat with you anyway.";
    }
    return "I'm feeling a bit tired today... but let's try to have a nice chat.";
  }

  static String _getSadOpening(TimeOfDay timeOfDay, WeatherEffect weather) {
    if (weather == WeatherEffect.rainy) {
      return "Rainy days make me feel a bit down... but talking to you helps.";
    }
    return "I'm feeling a bit down today... but I appreciate you being here.";
  }

  static String _getNeutralOpening(TimeOfDay timeOfDay, WeatherEffect weather) {
    return "Hello! How can we make today's conversation interesting?";
  }
}
