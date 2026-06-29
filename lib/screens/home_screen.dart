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
import '../widgets/streak_badge.dart';
import '../widgets/streak_card.dart';
import '../widgets/study_time_card.dart';
import '../widgets/weekly_ranking_card.dart';
import '../widgets/xp_bar.dart';
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
          SliverToBoxAdapter(child: _DailyMissionCard(progress: progress)),
          SliverToBoxAdapter(child: StreakCard(days: progress.streakDays)),
          SliverToBoxAdapter(child: StudyTimeCard(studyTime: studyTime)),
          SliverToBoxAdapter(child: _StatsRow(progress: progress, badgeCount: badges.earnedBadges.length)),
          SliverToBoxAdapter(child: _QuickActions()),
          SliverToBoxAdapter(child: _WeeklyRanking()),
          if (weakness.weakQuestions.isNotEmpty)
            SliverToBoxAdapter(child: _WeaknessCard(weakness: weakness)),
          SliverToBoxAdapter(child: _SkillBreakdown(progress: progress)),
          if (badges.earnedBadges.isNotEmpty)
            SliverToBoxAdapter(child: _RecentBadges(badges: badges)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DailyMissionCard extends StatelessWidget {
  final ProgressState progress;
  const _DailyMissionCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    // 次のクリアしていないステージを探す
    Stage? nextStage;
    for (final s in allStages) {
      if (!progress.isCleared(s.id)) { nextStage = s; break; }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimaryColor, kPrimaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withAlpha(76), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日のレッスン',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextStage != null
                        ? '${nextStage.emoji} ${nextStage.titleJa}（${nextStage.title}）'
                        : '🎉 全ステージクリア！',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (nextStage != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pushNamed('/stage-intro', arguments: nextStage),
                      child: const Text('スタート！', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            if (nextStage != null)
              Text(nextStage.emoji, style: const TextStyle(fontSize: 56)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProgressState progress;
  final int badgeCount;
  const _StatsRow({required this.progress, required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(label: 'レッスン', value: '${progress.totalLessons}回', emoji: '📚', color: kPrimaryColor),
          const SizedBox(width: 8),
          _StatCard(label: 'スピーキング', value: '${progress.totalSpeakingPractice}個', emoji: '🎤', color: kSpeakingColor),
          const SizedBox(width: 8),
          _StatCard(label: 'バッジ', value: '$badgeCount個', emoji: '🏆', color: kAccentOrange),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ],
        ),
      ),
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

// ─── Weakness Card ─────────────────────────────────────────────

class _WeaknessCard extends StatelessWidget {
  final WeaknessState weakness;
  const _WeaknessCard({required this.weakness});

  @override
  Widget build(BuildContext context) {
    final weak = weakness.weakQuestions.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: const Color(0xFFFFF3E0),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⚠️ 弱点問題', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kAccentOrange)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/test-prep'),
                    child: const Text('対策する →', style: TextStyle(color: kAccentOrange, fontSize: 12)),
                  ),
                ],
              ),
              ...weak.map((r) {
                final pct = (r.accuracy * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text('❌', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.questionId.split('_').last, style: const TextStyle(fontSize: 13, color: kTextDark))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAccentRed.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('正解率 $pct%', style: const TextStyle(fontSize: 11, color: kAccentRed, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillBreakdown extends StatelessWidget {
  final ProgressState progress;
  const _SkillBreakdown({required this.progress});

  @override
  Widget build(BuildContext context) {
    final total = allStages.length;
    final cleared = progress.clearedStages.length;
    final rate = total > 0 ? cleared / total : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('学習スキル', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
              const SizedBox(height: 12),
              _SkillBar(label: 'Listening', icon: '👂', color: kListeningColor, ratio: 0.35),
              const SizedBox(height: 8),
              _SkillBar(label: 'Speaking', icon: '🎤', color: kSpeakingColor, ratio: 0.40),
              const SizedBox(height: 8),
              _SkillBar(label: 'Reading', icon: '📖', color: kReadingColor, ratio: 0.15),
              const SizedBox(height: 8),
              _SkillBar(label: 'Writing', icon: '✏️', color: kWritingColor, ratio: 0.10),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('全体進捗', style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark)),
                  Text('$cleared / $total ステージ', style: const TextStyle(color: kTextMuted)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: rate,
                  backgroundColor: Colors.grey.shade200,
                  color: kPrimaryColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final double ratio;
  const _SkillBar({required this.label, required this.icon, required this.color, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 13, color: kTextDark))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(ratio * 100).round()}%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
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

    return WeeklyRankingCard(weeklyScores: weeklyScores);
  }
}
