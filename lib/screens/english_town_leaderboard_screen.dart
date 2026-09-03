import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_firebase_provider.dart';
import '../design_system/design_system.dart';

/// English-Only Town Global Leaderboard Screen
///
/// Displays global rankings of all players by XP earned
class EnglishTownLeaderboardScreen extends ConsumerWidget {
  const EnglishTownLeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(globalLeaderboardProvider);
    final userRank = ref.watch(userLeaderboardRankProvider);
    final cloudSyncAvailable = ref.watch(cloudSyncAvailableProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          '🏆 Global Leaderboard',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: leaderboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context),
        data: (entries) {
          if (!cloudSyncAvailable) {
            return _buildOfflineWidget();
          }

          if (entries.isEmpty) {
            return _buildEmptyWidget();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.lg),

                // User's rank card
                _buildUserRankCard(userRank),

                SizedBox(height: AppSpacing.lg),

                // Leaderboard list
                _buildLeaderboardList(entries),

                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build user's current rank card
  Widget _buildUserRankCard(AsyncValue<int?> userRank) {
    return userRank.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rank) {
        if (rank == null) {
          return Container(
            margin: AppSpacing.allPaddingMd,
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Text(
                  'You are not on the leaderboard yet.',
                  style: AppTypography.bodyMedium,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Complete more conversations to appear!',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: AppSpacing.allPaddingMd,
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentOrange.withOpacity(0.8), AppColors.accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Your Rank',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '#$rank',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Keep practicing to climb higher! 📈',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build leaderboard list
  Widget _buildLeaderboardList(List<Map<String, dynamic>> entries) {
    return Container(
      margin: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          final rank = index + 1;
          final medal = _getMedalEmoji(rank);

          return Column(
            children: [
              _buildLeaderboardEntry(
                rank: rank,
                medal: medal,
                displayName: entry['displayName'] ?? 'Unknown',
                totalXp: entry['totalXp'] ?? 0,
                totalConversations: entry['totalConversations'] ?? 0,
                currentStreak: entry['currentStreak'] ?? 0,
              ),
              if (index < entries.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.textMuted.withOpacity(0.2),
                ),
            ],
          );
        }),
      ),
    );
  }

  /// Build individual leaderboard entry
  Widget _buildLeaderboardEntry({
    required int rank,
    required String medal,
    required String displayName,
    required int totalXp,
    required int totalConversations,
    required int currentStreak,
  }) {
    return Padding(
      padding: AppSpacing.allPaddingMd,
      child: Row(
        children: [
          // Rank with medal
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  medal,
                  style: const TextStyle(fontSize: 28),
                ),
                Text(
                  '#$rank',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _buildStat('⚡', '$totalXp XP'),
                    SizedBox(width: AppSpacing.md),
                    _buildStat('💬', '$totalConversations'),
                    SizedBox(width: AppSpacing.md),
                    _buildStat('🔥', '$currentStreak'),
                  ],
                ),
              ],
            ),
          ),

          // Total XP display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalXp.toString(),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.accentOrange,
                ),
              ),
              Text(
                'XP',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat display
  Widget _buildStat(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  /// Get medal emoji based on rank
  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '⭐';
    }
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚠️',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load leaderboard',
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Please check your connection',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
            ),
            child: Text(
              'Back',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build offline widget
  Widget _buildOfflineWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📡',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Cloud sync is offline',
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Leaderboard requires internet connection',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
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
          const Text(
            '🏆',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Leaderboard is empty',
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Be the first to join!',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
