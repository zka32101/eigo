import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/leaderboard_entry_card.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get current user ID from provider
    const currentUserId = 'current-user-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.6),
          tabs: const [
            Tab(text: 'グローバル'),
            Tab(text: 'ウィークリー'),
            Tab(text: 'マンスリー'),
            Tab(text: 'フレンド'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardTab(
            leaderboardProvider: globalLeaderboardProvider,
            userId: currentUserId,
          ),
          _LeaderboardTab(
            leaderboardProvider: weeklyLeaderboardProvider,
            userId: currentUserId,
          ),
          _LeaderboardTab(
            leaderboardProvider: monthlyLeaderboardProvider,
            userId: currentUserId,
          ),
          _FriendLeaderboardTab(userId: currentUserId),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final FutureProvider<Leaderboard> leaderboardProvider;
  final String userId;

  const _LeaderboardTab({
    required this.leaderboardProvider,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final playerStatsAsync = ref.watch(playerRankStatsProvider(userId));

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: () => ref.refresh(leaderboardProvider),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (leaderboard) {
        if (leaderboard.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏆', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('ランキングデータはまだありません', style: AppTypography.labelLarge),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(leaderboardProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              // Player's current rank (if available)
              playerStatsAsync.when(
                data: (stats) {
                  if (stats.globalRank == 999999) return SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: _PlayerRankCard(stats: stats),
                  );
                },
                loading: () => SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              // Leaderboard entries
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return LeaderboardEntryCard(
                      entry: leaderboard.entries[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/user-profile',
                          arguments: leaderboard.entries[index].userId,
                        );
                      },
                    );
                  },
                  childCount: leaderboard.entries.length,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        );
      },
    );
  }
}

class _FriendLeaderboardTab extends ConsumerWidget {
  final String userId;

  const _FriendLeaderboardTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(friendsLeaderboardProvider(userId));

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: () => ref.refresh(friendsLeaderboardProvider(userId)),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (leaderboard) {
        if (leaderboard.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('👥', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('フレンドがいません', style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerMd,
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friends');
                  },
                  child: const Text('フレンドを追加'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(friendsLeaderboardProvider(userId).future);
          },
          child: ListView.builder(
            itemCount: leaderboard.entries.length,
            itemBuilder: (context, index) {
              return LeaderboardEntryCard(
                entry: leaderboard.entries[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/user-profile',
                    arguments: leaderboard.entries[index].userId,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _PlayerRankCard extends StatelessWidget {
  final PlayerRankStats stats;

  const _PlayerRankCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              'あなたのランキング',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
            ),
            AppSpacing.verticalSpacerMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RankInfo('グローバル', stats.globalRankDisplay, AppColors.textWhite),
                _RankInfo('ウィークリー', '#${stats.weeklyRank}', AppColors.textWhite.withOpacity(0.8)),
                _RankInfo('マンスリー', '#${stats.monthlyRank}', AppColors.textWhite.withOpacity(0.8)),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              stats.rankingTrend,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textWhite.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankInfo extends StatelessWidget {
  final String label;
  final String rank;
  final Color color;

  const _RankInfo(this.label, this.rank, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rank,
          style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        AppSpacing.verticalSpacerXs,
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }
}
