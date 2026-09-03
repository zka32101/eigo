import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../models/english_town_social_model.dart';
import '../providers/english_town_social_provider.dart';

/// Friends leaderboard screen with social features
class SocialFriendsLeaderboardScreen extends ConsumerWidget {
  const SocialFriendsLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardWithFriendsProvider);
    final friendsList = ref.watch(friendsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👥 フレンドランキング'),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              Tab(text: 'グローバル'),
              Tab(text: 'フレンド'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Global leaderboard
            leaderboard.when(
              data: (data) => _GlobalLeaderboard(leaderboard: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラー: $error'),
              ),
            ),
            // Friends leaderboard
            friendsList.when(
              data: (friends) => _FriendsLeaderboard(friends: friends),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラー: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalLeaderboard extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const _GlobalLeaderboard({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: AppColors.textMuted,
            ),
            AppSpacing.verticalSpacerMd,
            const Text('ランキングデータがありません'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: leaderboard.length + 1,
      itemBuilder: (context, index) {
        if (index == leaderboard.length) {
          return SizedBox(height: AppSpacing.xxl);
        }

        final entry = leaderboard[index];
        final rank = index + 1;
        final isFriend = entry['isFriend'] ?? false;

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _LeaderboardCard(
            rank: rank,
            displayName: entry['displayName'] ?? 'Unknown',
            totalXp: entry['totalXp'] ?? 0,
            level: entry['level'] ?? 1,
            conversations: entry['totalConversations'] ?? 0,
            isFriend: isFriend,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/social/profile',
                arguments: entry['userId'],
              );
            },
          ),
        );
      },
    );
  }
}

class _FriendsLeaderboard extends StatelessWidget {
  final List<SocialProfile> friends;

  const _FriendsLeaderboard({required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            AppSpacing.verticalSpacerMd,
            const Text('フレンドがいません'),
            AppSpacing.verticalSpacerLg,
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add friends
              },
              icon: const Icon(Icons.person_add),
              label: const Text('フレンドを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    // Sort friends by XP (descending)
    final sortedFriends = List<SocialProfile>.from(friends)
      ..sort((a, b) => b.totalXp.compareTo(a.totalXp));

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: sortedFriends.length + 1,
      itemBuilder: (context, index) {
        if (index == sortedFriends.length) {
          return SizedBox(height: AppSpacing.xxl);
        }

        final friend = sortedFriends[index];
        final rank = index + 1;

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _FriendLeaderboardCard(
            rank: rank,
            friend: friend,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/social/profile',
                arguments: friend.userId,
              );
            },
          ),
        );
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final String displayName;
  final int totalXp;
  final int level;
  final int conversations;
  final bool isFriend;
  final VoidCallback onTap;

  const _LeaderboardCard({
    required this.rank,
    required this.displayName,
    required this.totalXp,
    required this.level,
    required this.conversations,
    required this.isFriend,
    required this.onTap,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return AppColors.accentOrange;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return AppColors.primary;
    }
  }

  String _getRankEmoji() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: rank <= 3 ? _getRankColor().withAlpha(10) : AppColors.textWhite,
          border: Border.all(
            color: rank <= 3 ? _getRankColor().withAlpha(50) : AppColors.bgLight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getRankColor().withAlpha(30),
              ),
              child: Center(
                child: Text(
                  _getRankEmoji(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            AppSpacing.horizontalSpacerMd,

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: AppTypography.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isFriend)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withAlpha(20),
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            '👫',
                            style: AppTypography.labelSmall,
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.verticalSpacerXs,
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        'Lv.$level',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      AppSpacing.horizontalSpacerMd,
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        '$conversations会話',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // XP display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalXp',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
      ),
    );
  }
}

class _FriendLeaderboardCard extends StatelessWidget {
  final int rank;
  final SocialProfile friend;
  final VoidCallback onTap;

  const _FriendLeaderboardCard({
    required this.rank,
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          border: Border.all(color: AppColors.bgLight),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(30),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            AppSpacing.horizontalSpacerMd,

            // Avatar and info
            if (friend.avatarUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  friend.avatarUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(50),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 24),
                ),
              ),
            AppSpacing.horizontalSpacerMd,

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.displayName,
                    style: AppTypography.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerXs,
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        'Lv.${friend.level}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      AppSpacing.horizontalSpacerMd,
                      Icon(
                        Icons.show_chart,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        '🔥 ${friend.currentStreak}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // XP display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${friend.totalXp}',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
