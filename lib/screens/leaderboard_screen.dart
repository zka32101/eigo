import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 ランキング'),
          backgroundColor: kPrimaryColor,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: [
              Tab(text: 'グローバル'),
              Tab(text: 'フレンド'),
              Tab(text: '週間'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // グローバルランキング
            _GlobalLeaderboardTab(),
            // フレンドランキング
            _FriendLeaderboardTab(),
            // 週間ランキング
            _WeeklyLeaderboardTab(),
          ],
        ),
      ),
    );
  }
}

class _GlobalLeaderboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);

    return leaderboardAsync.when(
      data: (leaderboard) {
        return SingleChildScrollView(
          padding: AppSpacing.allPaddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーの現在位置
              if (leaderboard.currentUserEntry != null)
                _CurrentUserCard(entry: leaderboard.currentUserEntry!),
              AppSpacing.verticalSpacerLg,

              // ランキング一覧
              Text('ランキング', style: AppTypography.headlineSmall),
              AppSpacing.verticalSpacerMd,
              ...leaderboard.entries.asMap().entries.map((entry) {
                final index = entry.key;
                final leaderboardEntry = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LeaderboardEntryCard(
                    entry: leaderboardEntry,
                    isHighlighted: leaderboardEntry.isCurrentUser,
                  ),
                );
              }).toList(),
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }
}

class _FriendLeaderboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(friendLeaderboardProvider);

    return leaderboardAsync.when(
      data: (leaderboard) {
        if (leaderboard.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: kTextMuted),
                AppSpacing.verticalSpacerMd,
                const Text('フレンドがいません'),
                AppSpacing.verticalSpacerSm,
                const Text(
                  'フレンドを追加してランキングを競いましょう',
                  style: TextStyle(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: AppSpacing.allPaddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーの現在位置
              if (leaderboard.currentUserEntry != null)
                _CurrentUserCard(entry: leaderboard.currentUserEntry!),
              AppSpacing.verticalSpacerLg,

              // ランキング一覧
              Text('フレンドランキング', style: AppTypography.headlineSmall),
              AppSpacing.verticalSpacerMd,
              ...leaderboard.entries.asMap().entries.map((entry) {
                final index = entry.key;
                final leaderboardEntry = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LeaderboardEntryCard(
                    entry: leaderboardEntry,
                    isHighlighted: leaderboardEntry.isCurrentUser,
                  ),
                );
              }).toList(),
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }
}

class _WeeklyLeaderboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(weeklyLeaderboardProvider);

    return leaderboardAsync.when(
      data: (leaderboard) {
        return SingleChildScrollView(
          padding: AppSpacing.allPaddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 週間情報
              Container(
                padding: AppSpacing.allPaddingMd,
                decoration: BoxDecoration(
                  color: kAccentOrange.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: kAccentOrange.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: kAccentOrange),
                    AppSpacing.horizontalSpacerMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('今週のランキング',
                              style: AppTypography.labelLarge),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            '毎週月曜日にリセット',
                            style: AppTypography.bodySmall
                                .copyWith(color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // ユーザーの現在位置
              if (leaderboard.currentUserEntry != null)
                _CurrentUserCard(entry: leaderboard.currentUserEntry!),
              AppSpacing.verticalSpacerLg,

              // ランキング一覧
              Text('ランキング', style: AppTypography.headlineSmall),
              AppSpacing.verticalSpacerMd,
              ...leaderboard.entries.asMap().entries.map((entry) {
                final index = entry.key;
                final leaderboardEntry = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LeaderboardEntryCard(
                    entry: leaderboardEntry,
                    isHighlighted: leaderboardEntry.isCurrentUser,
                  ),
                );
              }).toList(),
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }
}

class _CurrentUserCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _CurrentUserCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withAlpha(20), kPrimaryColor.withAlpha(5)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kPrimaryColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('あなたの順位', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
          AppSpacing.verticalSpacerMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(entry.avatar, style: const TextStyle(fontSize: 32)),
                  AppSpacing.horizontalSpacerMd,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name, style: AppTypography.labelLarge),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        'スコア: ${entry.score}',
                        style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '第${entry.rank}位',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isHighlighted;

  const _LeaderboardEntryCard({
    required this.entry,
    this.isHighlighted = false,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // ゴールド
      case 2:
        return const Color(0xFFC0C0C0); // シルバー
      case 3:
        return const Color(0xFFCD7F32); // ブロンズ
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(entry.rank);

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: isHighlighted ? kPrimaryColor.withAlpha(10) : Colors.white,
        border: Border.all(
          color: isHighlighted ? kPrimaryColor.withAlpha(50) : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          // ランク表示
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: rankColor,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalSpacerMd,

          // ユーザー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.avatar, style: const TextStyle(fontSize: 24)),
                    AppSpacing.horizontalSpacerSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name, style: AppTypography.labelLarge),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            'Lv.${entry.level} • ${entry.totalStudyMinutes}分学習',
                            style: AppTypography.bodySmall
                                .copyWith(color: kTextMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // スコア表示
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.score}', style: AppTypography.labelLarge),
              AppSpacing.verticalSpacerXs,
              Text(
                '🔥 ${entry.longestStreak}日',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
