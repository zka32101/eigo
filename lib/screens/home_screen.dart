import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/stage.dart';
import '../providers/badge_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/study_time_provider.dart';
import '../providers/weakness_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/streak_badge.dart';
import '../widgets/streak_card.dart';
import '../widgets/study_time_card.dart';
import '../widgets/weekly_ranking_card.dart';
import '../widgets/xp_bar.dart';
import '../widgets/home_screen_cards.dart';
import '../providers/user_profile_provider.dart';
import 'profile_edit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final badges = ref.watch(badgeProvider);
    final coins = ref.watch(coinProvider);
    final weakness = ref.watch(weaknessProvider);
    final level = ref.watch(levelProvider);
    final studyTime = ref.watch(studyTimeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profiles = ref.watch(userProfilesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, 40, AppSpacing.md, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) => Container(
                                  padding: AppSpacing.allPaddingMd,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('プロフィール一覧', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                      AppSpacing.verticalSpacerXs,
                                      ...profiles.map((p) => Container(
                                        margin: EdgeInsets.only(bottom: AppSpacing.xs),
                                        child: ListTile(
                                          leading: Text(p.avatar, style: TextStyle(fontSize: AppTypography.displaySmall.fontSize)),
                                          title: Text(p.name),
                                          subtitle: Text('${p.grade}年生'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (currentUser?.id == p.id)
                                                Padding(
                                                  padding: EdgeInsets.only(right: AppSpacing.xs),
                                                  child: const Icon(Icons.check, color: AppColors.accentGreen, size: 20),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ProfileEditScreen(profile: p),
                                                    ),
                                                  );
                                                },
                                                tooltip: 'プロフィール編集',
                                              ),
                                            ],
                                          ),
                                          onTap: () async {
                                            await ref.read(userProfilesProvider.notifier).updateLastAccessed(p.id);
                                            if (context.mounted) {
                                              await ref.read(currentUserIdProvider.notifier).setCurrentUserId(p.id);
                                              Navigator.pop(ctx);
                                            }
                                          },
                                        ),
                                      )),
                                      AppSpacing.verticalSpacerXs,
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('新しいプロフィール'),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.pushNamed(ctx, '/profile-select');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text('${currentUser?.avatar ?? '👧'} ${currentUser?.name ?? 'プロフィール'}',
                              style: AppTypography.labelLarge.copyWith(color:AppColors.textWhite, fontWeight: FontWeight.bold)),
                          ),
                          AppSpacing.horizontalSpacerXs,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '英語コレ！',
                                  style: AppTypography.labelLarge.copyWith(color:AppColors.textWhite, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    StreakBadge(days: progress.streakDays),
                                    AppSpacing.horizontalSpacerXs,
                                    Text(
                                      'コイン: ${coins.totalCoins}🪙',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: Icon(Icons.calendar_today, color: AppColors.textWhite.withOpacity(0.7), size: 20),
                              onPressed: () => Navigator.of(ctx).pushNamed('/calendar'),
                              tooltip: 'カレンダー',
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpacerXs,
                      XpBar(level: level, compact: true),
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: _ImprovedDailyMissionCardWrapper(progress: progress),
          ),
          SliverToBoxAdapter(child: StreakCard(days: progress.streakDays)),
          SliverToBoxAdapter(child: StudyTimeCard(studyTime: studyTime)),
          SliverToBoxAdapter(
            child: ImprovedStatsRow(
              lessonsCount: progress.totalLessons,
              speakingCount: progress.totalSpeakingPractice,
              badgeCount: badges.earnedBadges.length,
            ),
          ),
          SliverToBoxAdapter(child: _QuickActions()),
          SliverToBoxAdapter(child: _WeeklyRanking()),
          if (weakness.weakQuestions.isNotEmpty)
            SliverToBoxAdapter(
              child: ImprovedWeaknessCard(
                title: weakness.weakQuestions.isNotEmpty ? weakness.weakQuestions.first.questionId : '弱点問題',
                count: weakness.weakQuestions.length,
                onTap: () => Navigator.of(context).pushNamed('/test-prep'),
              ),
            ),
          SliverToBoxAdapter(child: _ImprovedSkillBreakdown(progress: progress)),
          if (badges.earnedBadges.isNotEmpty)
            SliverToBoxAdapter(child: _RecentBadges(badges: badges)),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// Wrapper class for ImprovedDailyMissionCard
class _ImprovedDailyMissionCardWrapper extends StatelessWidget {
  final ProgressState progress;
  const _ImprovedDailyMissionCardWrapper({required this.progress});

  @override
  Widget build(BuildContext context) {
    // 次のクリアしていないステージを探す
    Stage? nextStage;
    for (final s in allStages) {
      if (!progress.isCleared(s.id)) { nextStage = s; break; }
    }

    return ImprovedDailyMissionCard(
      nextStage: nextStage,
      onStart: nextStage != null
          ? () => Navigator.of(context).pushNamed('/stage-intro', arguments: nextStage)
          : null,
    );
  }
}

// ─── Quick Actions ─────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              _QuickBtn('⚡ デイリー\nチャレンジ', AppColors.accentOrange, '/daily-challenge'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('🎤 発音\nバトル', AppColors.speakingColor, '/pronunciation-battle'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('💬 会話\nシミュ', AppColors.primary, '/conversation'),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _QuickBtn('👨‍👩‍👧 親子\nチャレンジ', AppColors.accentPink, '/parent-child'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('👫 友達\n招待', AppColors.accentGreen, '/invite'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('🎯 テスト\n対策', AppColors.accentRed, '/test-prep'),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _QuickBtn('🤖 AI\nフリートーク', AppColors.accentPurple, '/ai-freetalk'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('📖 単語\nカード', AppColors.accentGreen, '/vocabulary'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('📅 カレンダー', AppColors.listeningColor, '/calendar'),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _QuickBtn('🐾 ペット\n育成', AppColors.accentOrange, '/pet'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('🧑‍🏫 先生\nごっこ', AppColors.readingColor, '/teacher-mode'),
              AppSpacing.horizontalSpacerXs,
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _QuickBtn('🏆 チャレンジ', AppColors.accentPurple, '/challenges'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('📹 ビデオ\nギャラリー', AppColors.accentRed, '/video-gallery'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('👥 フレンド\nチャレンジ', AppColors.accentGreen, '/friend-challenges'),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _QuickBtn('🔔 通知', AppColors.accentPurple, '/notifications-center'),
              AppSpacing.horizontalSpacerXs,
              _QuickBtn('⚙️ 通知設定', AppColors.textMuted, '/notification-settings'),
              AppSpacing.horizontalSpacerXs,
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              _SocialQuickBtn('👤 プロフィール', AppColors.primary),
              AppSpacing.horizontalSpacerXs,
              _SocialQuickBtn('👥 フレンド', AppColors.accentGreen),
              AppSpacing.horizontalSpacerXs,
              _SocialQuickBtn('📊 アクティビティ', AppColors.accentPurple),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final Color color;
  final String route;
  const _QuickBtn(this.label, this.color, this.route);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialQuickBtn extends ConsumerWidget {
  final String label;
  final Color color;

  const _SocialQuickBtn(this.label, this.color);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Expanded(
      child: Material(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ログインしてください')),
              );
              return;
            }

            if (label.contains('プロフィール')) {
              Navigator.of(context).pushNamed('/user-profile', arguments: currentUser.id);
            } else if (label.contains('フレンド')) {
              Navigator.of(context).pushNamed('/friends');
            } else if (label.contains('アクティビティ')) {
              Navigator.of(context).pushNamed('/activity-feed');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// _WeaknessCard replaced with ImprovedWeaknessCard

class _ImprovedSkillBreakdown extends StatelessWidget {
  final ProgressState progress;
  const _ImprovedSkillBreakdown({required this.progress});

  @override
  Widget build(BuildContext context) {
    final total = allStages.length;
    final cleared = progress.clearedStages.length;
    final rate = total > 0 ? cleared / total : 0.0;

    return Padding(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImprovedSectionTitle(title: '学習スキル', emoji: '📊'),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Listening',
            progress: 0.35,
            skillColor: AppColors.listeningColor,
            questions: 12,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Speaking',
            progress: 0.40,
            skillColor: AppColors.speakingColor,
            questions: 14,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Reading',
            progress: 0.15,
            skillColor: AppColors.readingColor,
            questions: 5,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Writing',
            progress: 0.10,
            skillColor: AppColors.writingColor,
            questions: 3,
          ),
          AppSpacing.verticalSpacerLg,
          Padding(
            padding: AppSpacing.horizontalPaddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('全体進捗', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                    Text('$cleared / $total ステージ', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                AppSpacing.verticalSpacerSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: AppColors.bgLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentBadges extends StatelessWidget {
  final BadgeState badges;
  const _RecentBadges({required this.badges});

  @override
  Widget build(BuildContext context) {
    final recent = badges.earnedBadges.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('バッジ', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/badges'),
                    child: const Text('すべて見る'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: recent.map((b) => Column(
                  children: [
                    Text(b.badge.emoji, style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
                    Text(b.badge.title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
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

class _WeeklyRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weeklyScores = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DailyScore(
        date: '',
        score: (50 + (i * 10) % 50),
        fullDate: date,
      );
    });

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/ranking'),
      child: WeeklyRankingCard(weeklyScores: weeklyScores),
    );
  }
}
