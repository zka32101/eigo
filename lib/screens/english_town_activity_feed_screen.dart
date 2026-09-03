import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_activity_feed_provider.dart';
import '../design_system/design_system.dart';

/// Activity feed screen showing recent player activities
class EnglishTownActivityFeedScreen extends ConsumerWidget {
  const EnglishTownActivityFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityFeedProvider);
    final todaySummary = ref.watch(todayActivitySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          '📊 Activity Feed',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: activities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(),
        data: (activityList) {
          if (activityList.isEmpty) {
            return _buildEmptyWidget();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.lg),

                // Today's summary
                _buildTodaySummary(todaySummary),

                SizedBox(height: AppSpacing.lg),

                // Activity list
                Text(
                  'Recent Activity',
                  style: AppTypography.headlineSmall,
                ),
                SizedBox(height: AppSpacing.md),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityList.length,
                  itemBuilder: (context, index) {
                    final activity = activityList[index];
                    return _buildActivityCard(activity, index);
                  },
                ),

                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build today's activity summary
  Widget _buildTodaySummary(Map<String, int> summary) {
    final conversationCount = summary['ActivityEventType.conversation'] ?? 0;
    final achievementCount =
        summary['ActivityEventType.achievementUnlocked'] ?? 0;
    final streakCount = summary['ActivityEventType.streakMilestone'] ?? 0;
    final challengeCount = summary['ActivityEventType.challengeCompleted'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: AppTypography.titleSmall,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('💬', conversationCount, 'Conversations'),
              _buildSummaryItem('🏆', achievementCount, 'Achievements'),
              _buildSummaryItem('🔥', streakCount, 'Streaks'),
              _buildSummaryItem('⭐', challengeCount, 'Challenges'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(String emoji, int count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        SizedBox(height: AppSpacing.xs),
        Text(
          count.toString(),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build activity card
  Widget _buildActivityCard(ActivityEvent activity, int index) {
    final color = _getActivityColor(activity.type);
    final timeAgo = _getTimeAgo(activity.timestamp);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          color: color.withOpacity(0.03),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(AppSpacing.md),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                activity.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            activity.title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xs),
              Text(
                activity.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    timeAgo,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '•',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getActivityLabel(activity.type),
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color for activity type
  Color _getActivityColor(ActivityEventType type) {
    switch (type) {
      case ActivityEventType.conversation:
        return Colors.blue;
      case ActivityEventType.achievementUnlocked:
        return Colors.purple;
      case ActivityEventType.streakMilestone:
        return Colors.orange;
      case ActivityEventType.levelUp:
        return Colors.green;
      case ActivityEventType.rankChange:
        return Colors.pink;
      case ActivityEventType.leaderboardEntry:
        return Colors.amber;
      case ActivityEventType.challengeCompleted:
        return Colors.cyan;
      case ActivityEventType.friendAdded:
        return Colors.red;
    }
  }

  /// Get label for activity type
  String _getActivityLabel(ActivityEventType type) {
    switch (type) {
      case ActivityEventType.conversation:
        return 'Conversation';
      case ActivityEventType.achievementUnlocked:
        return 'Achievement';
      case ActivityEventType.streakMilestone:
        return 'Streak';
      case ActivityEventType.levelUp:
        return 'Level Up';
      case ActivityEventType.rankChange:
        return 'Rank Change';
      case ActivityEventType.leaderboardEntry:
        return 'Leaderboard';
      case ActivityEventType.challengeCompleted:
        return 'Challenge';
      case ActivityEventType.friendAdded:
        return 'Friend';
    }
  }

  /// Get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '⚠️',
            style: const TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load activity feed',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build empty widget
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📊',
            style: const TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No activity yet',
            style: AppTypography.bodyMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Start playing to see activities!',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
