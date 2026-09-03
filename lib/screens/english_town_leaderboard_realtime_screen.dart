import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_firebase_provider.dart';
import '../providers/english_town_notification_provider.dart';
import '../design_system/design_system.dart';

/// Real-time leaderboard with live rank updates
class EnglishTownLeaderboardRealtimeScreen extends ConsumerStatefulWidget {
  const EnglishTownLeaderboardRealtimeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnglishTownLeaderboardRealtimeScreen> createState() =>
      _EnglishTownLeaderboardRealtimeScreenState();
}

class _EnglishTownLeaderboardRealtimeScreenState
    extends ConsumerState<EnglishTownLeaderboardRealtimeScreen> {
  late List<Map<String, dynamic>> _previousLeaderboard;
  late Map<int, bool> _rankChangeIndicators; // true if improved

  @override
  void initState() {
    super.initState();
    _previousLeaderboard = [];
    _rankChangeIndicators = {};
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(globalLeaderboardProvider);
    final userRank = ref.watch(userLeaderboardRankProvider);
    final cloudSyncAvailable = ref.watch(cloudSyncAvailableProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          '🏆 Live Leaderboard',
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

          // Detect rank changes
          _detectRankChanges(entries);

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.lg),

                // User's rank card with animation
                _buildUserRankCard(userRank),

                SizedBox(height: AppSpacing.lg),

                // Live leaderboard list
                _buildLiveLeaderboardList(entries),

                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Detect rank changes from previous leaderboard
  void _detectRankChanges(List<Map<String, dynamic>> currentLeaderboard) {
    if (_previousLeaderboard.isEmpty) {
      _previousLeaderboard = currentLeaderboard;
      return;
    }

    // Clear previous indicators
    _rankChangeIndicators.clear();

    // Check each user for rank changes
    for (int i = 0; i < currentLeaderboard.length; i++) {
      final current = currentLeaderboard[i];
      final currentUserId = current['userId'] ?? '';

      // Find user in previous leaderboard
      int? previousRank;
      for (int j = 0; j < _previousLeaderboard.length; j++) {
        if ((_previousLeaderboard[j]['userId'] ?? '') == currentUserId) {
          previousRank = j + 1;
          break;
        }
      }

      if (previousRank != null) {
        final currentRank = i + 1;
        if (currentRank < previousRank) {
          _rankChangeIndicators[currentRank] = true; // Improved
        } else if (currentRank > previousRank) {
          _rankChangeIndicators[currentRank] = false; // Declined
        }
      }
    }

    _previousLeaderboard = currentLeaderboard;
  }

  /// Build user's rank card with animation
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

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: AppSpacing.allPaddingMd,
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentOrange.withOpacity(0.8),
                AppColors.accentOrange,
              ],
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
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: rank <= 10 ? 48 : 40,
                ),
                child: Text('#$rank'),
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_rankChangeIndicators[rank] == true)
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.lightGreen,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Climbing! 🚀',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.lightGreen,
                          ),
                        ),
                      ],
                    )
                  else if (_rankChangeIndicators[rank] == false)
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Keep pushing!',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Keep practicing! 📈',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build live leaderboard list with rank change animations
  Widget _buildLiveLeaderboardList(List<Map<String, dynamic>> entries) {
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
          final hasChanged = _rankChangeIndicators.containsKey(rank);
          final improved = _rankChangeIndicators[rank] ?? false;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: hasChanged
                  ? (improved
                      ? Colors.lightGreen.withOpacity(0.05)
                      : Colors.orange.withOpacity(0.05))
                  : Colors.transparent,
              border: hasChanged
                  ? Border(
                      left: BorderSide(
                        color:
                            improved ? Colors.lightGreen : Colors.orange,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Column(
              children: [
                _buildLiveLeaderboardEntry(
                  rank: rank,
                  medal: medal,
                  displayName: entry['displayName'] ?? 'Unknown',
                  totalXp: entry['totalXp'] ?? 0,
                  totalConversations: entry['totalConversations'] ?? 0,
                  currentStreak: entry['currentStreak'] ?? 0,
                  changed: hasChanged,
                  improved: improved,
                ),
                if (index < entries.length - 1)
                  Divider(
                    height: 1,
                    color: AppColors.textMuted.withOpacity(0.2),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Build individual leaderboard entry with rank change indicator
  Widget _buildLiveLeaderboardEntry({
    required int rank,
    required String medal,
    required String displayName,
    required int totalXp,
    required int totalConversations,
    required int currentStreak,
    required bool changed,
    required bool improved,
  }) {
    return Padding(
      padding: AppSpacing.allPaddingMd,
      child: Row(
        children: [
          // Rank with medal and change indicator
          Stack(
            alignment: Alignment.center,
            children: [
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
              if (changed)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: improved ? Colors.lightGreen : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      improved ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
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
            'Real-time leaderboard requires internet connection',
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
