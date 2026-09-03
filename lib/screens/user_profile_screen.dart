import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_model.dart';
import '../providers/social_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/activity_card.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    final activitiesAsync = ref.watch(userActivitiesProvider(userId));
    final statsAsync = ref.watch(socialStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラーが発生しました', style: AppTypography.labelLarge),
              AppSpacing.verticalSpacerMd,
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider(userId)),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (profile) => CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: _ProfileHeader(
                profile: profile,
                isCurrentUser: isCurrentUser,
                userId: userId,
              ),
            ),
            // Stats Section
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _StatsSection(stats: stats),
                loading: () => const SizedBox(height: 100),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            // Skill Breakdown
            SliverToBoxAdapter(
              child: _SkillBreakdown(skillScores: profile.skillScores),
            ),
            // Recent Activities
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                child: Text(
                  '最近のアクティビティ',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Column(
                          children: [
                            Text('📭', style: TextStyle(fontSize: 48)),
                            AppSpacing.verticalSpacerMd,
                            Text('アクティビティはまだありません', style: AppTypography.labelMedium),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ActivityCard(
                        activity: activities[index],
                        showUserAvatar: false,
                      );
                    },
                    childCount: activities.take(5).length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            // Badges Section
            if (profile.badges.isNotEmpty)
              SliverToBoxAdapter(
                child: _BadgesSection(badges: profile.badges),
              ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final UserProfile profile;
  final bool isCurrentUser;
  final String userId;

  const _ProfileHeader({
    required this.profile,
    required this.isCurrentUser,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGreen, width: 4),
              ),
              child: Center(
                child: Text(
                  profile.avatar,
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            // Name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.name,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.horizontalSpacerSm,
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: profile.isOnline ? AppColors.accentGreen : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerXs,
            if (profile.bio != null)
              Text(
                profile.bio!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
            AppSpacing.verticalSpacerXs,
            Text(
              profile.joinedDaysAgo,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
            ),
            AppSpacing.verticalSpacerMd,
            // Level and XP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lv${profile.level}',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
                ),
                AppSpacing.horizontalSpacerMd,
                Text(
                  '⭐ ${profile.totalXp} XP',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickStat('🪙', '${profile.totalCoins}', 'コイン'),
                _QuickStat('🔥', '${profile.streakDays}', 'ストリーク'),
                _QuickStat('👥', '${profile.friendCount}', 'フレンド'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _QuickStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        AppSpacing.verticalSpacerXs,
        Text(value, style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7))),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final SocialStats stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('統計情報', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpacerMd,
              _StatRow('総レッスン数', '${stats.totalActivities}'),
              _StatRow('このヶ月', '${stats.activitiesThisMonth}'),
              _StatRow('このアクティビティ週', '${stats.activitiesThisWeek}'),
              _StatRow('いいね数', '${stats.likes}'),
              _StatRow('コメント数', '${stats.comments}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SkillBreakdown extends StatelessWidget {
  final Map<String, int> skillScores;

  const _SkillBreakdown({required this.skillScores});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('スキル進捗', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpacerMd,
              ...skillScores.entries.map((e) => _SkillBar(
                skill: e.key,
                score: e.value,
                maxScore: 100,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String skill;
  final int score;
  final int maxScore;

  const _SkillBar({
    required this.skill,
    required this.score,
    required this.maxScore,
  });

  Color get _skillColor {
    switch (skill.toLowerCase()) {
      case 'listening':
        return AppColors.listeningColor;
      case 'speaking':
        return AppColors.speakingColor;
      case 'reading':
        return AppColors.readingColor;
      case 'writing':
        return AppColors.writingColor;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = score / maxScore;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              Text('$score/$maxScore', style: AppTypography.bodySmall),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(_skillColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  final List<String> badges;

  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('バッジ (${badges.length})', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpacerMd,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: badges.map((badge) => Column(
                  children: [
                    Text(badge, style: TextStyle(fontSize: 32)),
                  ],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
