import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider) ?? '';
    final achievementsAsync = ref.watch(achievementsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider(userId));
    final statsAsync = ref.watch(achievementStatsProvider(userId));
    final typeFilter = ref.watch(achievementTypeFilterProvider);
    final tierFilter = ref.watch(achievementTierFilterProvider);
    final showOnlyUnlocked = ref.watch(showOnlyUnlockedProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 アチーブメント'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('全て'),
                    statsAsync.whenData((stats) {
                      if (stats == null) return SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${stats.unlockedCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).value ?? SizedBox.shrink(),
                  ],
                ),
              ),
              const Tab(text: '未獲得'),
              const Tab(text: '統計'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All achievements tab
            _AllAchievementsTab(
              achievementsAsync: achievementsAsync,
              userAchievementsAsync: userAchievementsAsync,
              typeFilter: typeFilter,
              tierFilter: tierFilter,
            ),
            // Locked achievements tab
            _LockedAchievementsTab(
              achievementsAsync: achievementsAsync,
              userAchievementsAsync: userAchievementsAsync,
            ),
            // Stats tab
            _AchievementStatsTab(statsAsync: statsAsync),
          ],
        ),
      ),
    );
  }
}

class _AllAchievementsTab extends ConsumerWidget {
  final AsyncValue<List<Achievement>> achievementsAsync;
  final AsyncValue<List<UserAchievement>> userAchievementsAsync;
  final AchievementType? typeFilter;
  final AchievementTier? tierFilter;

  const _AllAchievementsTab({
    required this.achievementsAsync,
    required this.userAchievementsAsync,
    this.typeFilter,
    this.tierFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return achievementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
      data: (achievements) {
        return userAchievementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('エラー: $error')),
          data: (userAchievements) {
            // Filter achievements
            var filtered = achievements;
            if (typeFilter != null) {
              filtered = filtered.where((a) => a.type == typeFilter).toList();
            }
            if (tierFilter != null) {
              filtered = filtered.where((a) => a.tier == tierFilter).toList();
            }

            final unlockedIds = userAchievements.map((ua) => ua.achievementId).toSet();
            final unlockedAchievements =
                filtered.where((a) => unlockedIds.contains(a.id)).toList();
            final lockedAchievements =
                filtered.where((a) => !unlockedIds.contains(a.id)).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  _FilterChips(ref: ref),
                  const SizedBox(height: 16),
                  // Unlocked section
                  if (unlockedAchievements.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '獲得済み (${unlockedAchievements.length})',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '✓',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: unlockedAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = unlockedAchievements[index];
                        final userAch = userAchievements.firstWhere(
                          (ua) => ua.achievementId == achievement.id,
                        );
                        return AchievementCard(
                          achievement: achievement,
                          userAchievement: userAch,
                          isUnlocked: true,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Locked section
                  if (lockedAchievements.isNotEmpty) ...[
                    Text(
                      '未獲得 (${lockedAchievements.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: lockedAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = lockedAchievements[index];
                        return AchievementCard(
                          achievement: achievement,
                          isUnlocked: false,
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LockedAchievementsTab extends ConsumerWidget {
  final AsyncValue<List<Achievement>> achievementsAsync;
  final AsyncValue<List<UserAchievement>> userAchievementsAsync;

  const _LockedAchievementsTab({
    required this.achievementsAsync,
    required this.userAchievementsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return achievementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
      data: (achievements) {
        return userAchievementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('エラー: $error')),
          data: (userAchievements) {
            final unlockedIds = userAchievements.map((ua) => ua.achievementId).toSet();
            final lockedAchievements = achievements
                .where((a) => !unlockedIds.contains(a.id))
                .toList();

            if (lockedAchievements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, size: 64, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'すべてのアチーブメント獲得済み！',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: lockedAchievements.length,
                itemBuilder: (context, index) {
                  return AchievementCard(
                    achievement: lockedAchievements[index],
                    isUnlocked: false,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _AchievementStatsTab extends ConsumerWidget {
  final AsyncValue<AchievementStats?> statsAsync;

  const _AchievementStatsTab({required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
      data: (stats) {
        if (stats == null) {
          return const Center(child: Text('統計情報がありません'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall completion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '全体進捗',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: stats.completionPercent / 100,
                        minHeight: 12,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.completionDisplay} (${stats.completionPercent.toStringAsFixed(1)}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _StatCard(
                    icon: '🏆',
                    label: '獲得アチーブメント',
                    value: stats.unlockedCount.toString(),
                    color: AppColors.accentOrange,
                  ),
                  _StatCard(
                    icon: '💎',
                    label: '報酬受取済み',
                    value: stats.claimedCount.toString(),
                    color: AppColors.accentGreen,
                  ),
                  _StatCard(
                    icon: '⭐',
                    label: '合計XP',
                    value: stats.totalXpEarned.toString(),
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    icon: '💰',
                    label: '合計コイン',
                    value: stats.totalCoinsEarned.toString(),
                    color: AppColors.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent achievements
              Text(
                'その他の情報',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      label: '最終獲得',
                      value: _formatDate(stats.lastAchievementAt),
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      label: '連続日数',
                      value: '${stats.currentStreak}日',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return '今日';
    if (difference.inDays == 1) return '昨日';
    if (difference.inDays < 7) return '${difference.inDays}日前';
    return '${date.month}月${date.day}日';
  }
}

class _FilterChips extends ConsumerWidget {
  final WidgetRef ref;

  const _FilterChips({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeFilter = ref.watch(achievementTypeFilterProvider);
    final tierFilter = ref.watch(achievementTierFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タイプ別',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AchievementType.values
                .map((type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type.toString().split('.').last),
                selected: typeFilter == type,
                onSelected: (selected) {
                  ref.read(achievementTypeFilterProvider.notifier).state =
                      selected ? type : null;
                },
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '難易度',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AchievementTier.values
                .map((tier) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tier.toString().split('.').last),
                selected: tierFilter == tier,
                onSelected: (selected) {
                  ref.read(achievementTierFilterProvider.notifier).state =
                      selected ? tier : null;
                },
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
