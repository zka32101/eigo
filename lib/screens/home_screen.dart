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
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';
import '../widgets/streak_badge.dart';
import '../widgets/streak_card.dart';
import '../widgets/study_time_card.dart';
import '../widgets/weekly_ranking_card.dart';
import '../widgets/xp_bar.dart';
import '../widgets/home_screen_cards.dart';
import '../providers/user_profile_provider.dart';

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
            backgroundColor: kPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
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
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('プロフィール一覧', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      ...profiles.map((p) => ListTile(
                                        leading: Text(p.avatar, style: const TextStyle(fontSize: 24)),
                                        title: Text(p.name),
                                        subtitle: Text('${p.grade}年生'),
                                        trailing: currentUser?.id == p.id ? const Icon(Icons.check) : null,
                                        onTap: () async {
                                          await ref.read(userProfilesProvider.notifier).updateLastAccessed(p.id);
                                          if (context.mounted) {
                                            await ref.read(currentUserIdProvider.notifier).setCurrentUserId(p.id);
                                            Navigator.pop(ctx);
                                          }
                                        },
                                      )),
                                      const SizedBox(height: 8),
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
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '英語コレ！',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    StreakBadge(days: progress.streakDays),
                                    const SizedBox(width: 6),
                                    Text(
                                      'コイン: ${coins.totalCoins}🪙',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                              onPressed: () => Navigator.of(ctx).pushNamed('/calendar'),
                              tooltip: 'カレンダー',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              _QuickBtn('⚡ デイリー\nチャレンジ', kAccentOrange, '/daily-challenge'),
              const SizedBox(width: 8),
              _QuickBtn('🎤 発音\nバトル', kSpeakingColor, '/pronunciation-battle'),
              const SizedBox(width: 8),
              _QuickBtn('💬 会話\nシミュ', kPrimaryColor, '/conversation'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _QuickBtn('👨‍👩‍👧 親子\nチャレンジ', const Color(0xFFE91E63), '/parent-child'),
              const SizedBox(width: 8),
              _QuickBtn('👫 友達\n招待', kAccentGreen, '/invite'),
              const SizedBox(width: 8),
              _QuickBtn('🎯 テスト\n対策', kAccentRed, '/test-prep'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _QuickBtn('🤖 AI\nフリートーク', const Color(0xFF7C3AED), '/ai-freetalk'),
              const SizedBox(width: 8),
              _QuickBtn('📖 単語\nカード', const Color(0xFF059669), '/vocabulary'),
              const SizedBox(width: 8),
              _QuickBtn('📅 カレンダー', kListeningColor, '/calendar'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _QuickBtn('🐾 ペット\n育成', const Color(0xFFFF7043), '/pet'),
              const SizedBox(width: 8),
              _QuickBtn('🧑‍🏫 先生\nごっこ', const Color(0xFF26A69A), '/teacher-mode'),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox.shrink()),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
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
            skillColor: kListeningColor,
            questions: 12,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Speaking',
            progress: 0.40,
            skillColor: kSpeakingColor,
            questions: 14,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Reading',
            progress: 0.15,
            skillColor: kReadingColor,
            questions: 5,
          ),
          AppSpacing.verticalSpacerMd,
          ImprovedSkillProgressCard(
            skillName: 'Writing',
            progress: 0.10,
            skillColor: kWritingColor,
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
                    Text('全体進捗', style: AppTypography.labelLarge.copyWith(color: kTextDark)),
                    Text('$cleared / $total ステージ', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  ],
                ),
                AppSpacing.verticalSpacerSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
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
                  const Text('バッジ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    Text(b.badge.emoji, style: const TextStyle(fontSize: 32)),
                    Text(b.badge.title, style: const TextStyle(fontSize: 10, color: kTextMuted)),
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
