import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../services/english_town_notification_service.dart';

/// Represents an activity event in the game
class ActivityEvent {
  final String id;
  final String userId;
  final String playerName;
  final ActivityEventType type;
  final String title;
  final String description;
  final String emoji;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  ActivityEvent({
    required this.id,
    required this.userId,
    required this.playerName,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.data,
    required this.timestamp,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'playerName': playerName,
      'type': type.toString(),
      'title': title,
      'description': description,
      'emoji': emoji,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory ActivityEvent.fromFirestore(Map<String, dynamic> doc) {
    return ActivityEvent(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      playerName: doc['playerName'] as String,
      type: _parseActivityEventType(doc['type'] as String),
      title: doc['title'] as String,
      description: doc['description'] as String,
      emoji: doc['emoji'] as String,
      data: Map<String, dynamic>.from(doc['data'] as Map? ?? {}),
      timestamp: DateTime.parse(doc['timestamp'] as String),
    );
  }

  static ActivityEventType _parseActivityEventType(String type) {
    return ActivityEventType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => ActivityEventType.conversation,
    );
  }
}

/// Types of activity events
enum ActivityEventType {
  conversation,
  achievementUnlocked,
  streakMilestone,
  levelUp,
  rankChange,
  leaderboardEntry,
  challengeCompleted,
  friendAdded,
}

/// Service for managing activity feed
class EnglishTownActivityFeedService {
  static final EnglishTownActivityFeedService _instance =
      EnglishTownActivityFeedService._internal();

  factory EnglishTownActivityFeedService() {
    return _instance;
  }

  EnglishTownActivityFeedService._internal();

  // Activity store
  final List<ActivityEvent> _activities = [];

  /// Get all activities
  List<ActivityEvent> get activities => List.unmodifiable(_activities);

  /// Get activities (most recent first)
  List<ActivityEvent> getRecentActivities({int limit = 50}) {
    return _activities.take(limit).toList();
  }

  /// Get activities by type
  List<ActivityEvent> getActivitiesByType(ActivityEventType type) {
    return _activities.where((a) => a.type == type).toList();
  }

  /// Get activities from last N hours
  List<ActivityEvent> getActivitiesSince(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _activities.where((a) => a.timestamp.isAfter(cutoff)).toList();
  }

  /// Record conversation activity
  ActivityEvent recordConversation({
    required String userId,
    required String playerName,
    required String npcName,
    required String locationName,
    required int xpEarned,
    required int difficulty,
  }) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.conversation,
      title: 'Conversed with $npcName',
      description: 'Talked to $npcName at $locationName (Difficulty: $difficulty)',
      emoji: '💬',
      data: {
        'npcName': npcName,
        'locationName': locationName,
        'xpEarned': xpEarned,
        'difficulty': difficulty,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Record achievement unlock
  ActivityEvent recordAchievementUnlock({
    required String userId,
    required String playerName,
    required String achievementTitle,
    required String achievementDescription,
    required int rewardXp,
  }) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.achievementUnlocked,
      title: 'Unlocked $achievementTitle',
      description: achievementDescription,
      emoji: '🏆',
      data: {
        'achievementTitle': achievementTitle,
        'rewardXp': rewardXp,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Record streak milestone
  ActivityEvent recordStreakMilestone({
    required String userId,
    required String playerName,
    required int streakDays,
    required int milestone,
  }) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.streakMilestone,
      title: '$streakDays-day streak!',
      description: 'Maintained a $streakDays day streak',
      emoji: '🔥',
      data: {
        'streakDays': streakDays,
        'milestone': milestone,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Record rank change
  ActivityEvent recordRankChange({
    required String userId,
    required String playerName,
    required int previousRank,
    required int currentRank,
  }) {
    final improved = currentRank < previousRank;
    final rankDiff = (previousRank - currentRank).abs();

    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.rankChange,
      title: improved
          ? 'Climbed $rankDiff positions!'
          : 'Rank changed by $rankDiff positions',
      description: 'New rank: #$currentRank',
      emoji: improved ? '📈' : '📉',
      data: {
        'previousRank': previousRank,
        'currentRank': currentRank,
        'improved': improved,
        'rankDiff': rankDiff,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Record leaderboard entry
  ActivityEvent recordLeaderboardEntry({
    required String userId,
    required String playerName,
    required int rank,
    required int totalXp,
  }) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.leaderboardEntry,
      title: 'Entered the global leaderboard!',
      description: 'Ranked #$rank with $totalXp XP',
      emoji: rank <= 10 ? '👑' : '⭐',
      data: {
        'rank': rank,
        'totalXp': totalXp,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Record challenge completion
  ActivityEvent recordChallengeCompletion({
    required String userId,
    required String playerName,
    required String challengeTitle,
    required int xpReward,
  }) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      playerName: playerName,
      type: ActivityEventType.challengeCompleted,
      title: 'Completed $challengeTitle',
      description: 'Challenge complete! (+$xpReward XP)',
      emoji: '⭐',
      data: {
        'challengeTitle': challengeTitle,
        'xpReward': xpReward,
      },
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    _trimActivities();
    return activity;
  }

  /// Trim activities to keep only recent ones (max 500)
  void _trimActivities() {
    if (_activities.length > 500) {
      _activities.removeRange(500, _activities.length);
    }
  }

  /// Clear all activities
  void clearAll() {
    _activities.clear();
  }

  /// Get activity feed summary for time period
  Map<String, int> getActivitySummary({Duration? timeRange}) {
    List<ActivityEvent> filteredActivities = _activities;

    if (timeRange != null) {
      final cutoff = DateTime.now().subtract(timeRange);
      filteredActivities =
          _activities.where((a) => a.timestamp.isAfter(cutoff)).toList();
    }

    final summary = <String, int>{};

    for (final activity in filteredActivities) {
      final key = activity.type.toString();
      summary[key] = (summary[key] ?? 0) + 1;
    }

    return summary;
  }

  /// Check if milestone achieved (e.g., 5 conversations today)
  bool checkMilestone(ActivityEventType type, int count,
      {Duration? timeRange}) {
    final activities = timeRange != null
        ? getActivitiesSince(timeRange)
        : _activities;
    return activities.where((a) => a.type == type).length >= count;
  }
}
