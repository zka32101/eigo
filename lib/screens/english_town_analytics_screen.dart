import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../models/english_town_advanced.dart';
import '../providers/english_town_provider.dart';
import '../providers/english_town_rewards_provider.dart';
import '../providers/english_town_polish_provider.dart';
import '../design_system/design_system.dart';

/// Engagement Analytics Screen
///
/// Displays comprehensive analytics about player engagement including:
/// - Engagement score (0-100)
/// - Total playtime and sessions
/// - NPC preferences and interaction counts
/// - Location visit patterns
/// - Difficulty progression
/// - Response accuracy
/// - Conversation streak
class EnglishTownAnalyticsScreen extends ConsumerWidget {
  const EnglishTownAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(engagementAnalyticsProvider);
    final score = ref.watch(engagementScoreProvider);
    final recommendedNPC = ref.watch(recommendedNPCProvider);
    final stats = ref.watch(extendedProgressStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          'Your Progress Analytics',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Engagement Score Card
            _buildEngagementScoreCard(score),

            SizedBox(height: AppSpacing.lg),

            // Quick Stats Row
            _buildQuickStatsRow(stats),

            SizedBox(height: AppSpacing.lg),

            // Playtime Analytics
            _buildPlaytimeAnalytics(analytics),

            SizedBox(height: AppSpacing.lg),

            // NPC Interaction Preferences
            _buildNPCPreferencesSection(ref, analytics),

            SizedBox(height: AppSpacing.lg),

            // Location Visit Patterns
            _buildLocationPatternsSection(ref, analytics, stats),

            SizedBox(height: AppSpacing.lg),

            // Recommendations Section
            if (recommendedNPC != null)
              _buildRecommendationsSection(recommendedNPC),

            SizedBox(height: AppSpacing.lg),

            // Achievement Progress
            _buildAchievementProgressSection(ref, stats),

            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Build engagement score card
  Widget _buildEngagementScoreCard(int score) {
    final color = _getScoreColor(score);
    final label = _getScoreLabel(score);

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Score',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white70,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                score.toString(),
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick stats row
  Widget _buildQuickStatsRow(
    ({
      int totalConversations,
      int totalXpEarned,
      int totalCoinsEarned,
      int unlockedAchievementsCount,
      int achievedMilestonesCount,
      int totalMilestonesCount,
      int milestoneProgressPercent,
      int locationProgressPercent,
    }) stats,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: '💬',
            label: 'Conversations',
            value: stats.totalConversations.toString(),
            color: AppColors.accentOrange,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: '⚡',
            label: 'Total XP',
            value: stats.totalXpEarned.toString(),
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: '💰',
            label: 'Total Coins',
            value: stats.totalCoinsEarned.toString(),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build playtime analytics
  Widget _buildPlaytimeAnalytics(EngagementAnalytics analytics) {
    final hoursPlayed = analytics.totalPlayTime.inMinutes / 60;

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏱️ Playtime Analytics',
            style: AppTypography.titleSmall,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Sessions',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    analytics.totalSessionsPlayed.toString(),
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Playtime',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    hoursPlayed < 1
                        ? '${analytics.totalPlayTime.inMinutes} min'
                        : '${hoursPlayed.toStringAsFixed(1)} hrs',
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accuracy',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '${analytics.averageResponseAccuracy.toStringAsFixed(1)}%',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build NPC preferences section
  Widget _buildNPCPreferencesSection(
    WidgetRef ref,
    EngagementAnalytics analytics,
  ) {
    final townMap = ref.watch(townMapProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🗣️ NPC Interaction Preferences',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border.all(color: Colors.blueAccent, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: [
              for (final entry in analytics.npcPreferences.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          townMap.getNPC(entry.key)?.name ?? entry.key,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value} chats',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build location patterns section
  Widget _buildLocationPatternsSection(
    WidgetRef ref,
    EngagementAnalytics analytics,
    dynamic stats,
  ) {
    final locations = ref.watch(townLocationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 Location Visit Patterns',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border.all(color: Colors.greenAccent, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: [
              Text(
                'Location Progress: ${stats.locationProgressPercent}%',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stats.locationProgressPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Visited ${analytics.locationPreferences.length} of ${locations.length} locations',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build recommendations section
  Widget _buildRecommendationsSection(NPC recommendedNPC) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        border: Border.all(color: AppColors.accentGreen, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Recommended Next Partner',
            style: AppTypography.titleSmall,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                recommendedNPC.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedNPC.name,
                      style: AppTypography.titleMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      recommendedNPC.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build achievement progress section
  Widget _buildAchievementProgressSection(
    WidgetRef ref,
    dynamic stats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Achievement Progress',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border.all(color: Colors.amber, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Achievements',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    '${stats.unlockedAchievementsCount} unlocked',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stats.unlockedAchievementsCount / 8,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Milestones',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    '${stats.achievedMilestonesCount}/${stats.totalMilestonesCount}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stats.milestoneProgressPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get color based on engagement score
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.blueAccent;
    if (score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  /// Get label for engagement score
  String _getScoreLabel(int score) {
    if (score >= 80) return '🌟 Excellent';
    if (score >= 60) return '👍 Good';
    if (score >= 40) return '⚠️ Fair';
    return '📈 Starting';
  }
}
