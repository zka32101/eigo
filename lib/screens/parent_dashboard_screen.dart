import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_provider.dart';
import '../providers/speaking_history_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/skill_progress_bar.dart';
import '../widgets/speaking_score_ring.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final history = ref.watch(speakingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍👩‍👧 親向けダッシュボード'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'アップグレード',
            onPressed: () => Navigator.of(context).pushNamed('/upgrade'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OverviewCard(progress: progress, history: history),
            const SizedBox(height: 16),
            _SpeakingRingsRow(history: history),
            const SizedBox(height: 16),
            _SpeakingDetailCard(progress: progress, history: history),
            const SizedBox(height: 16),
            _WeeklyProgressCard(history: history),
            const SizedBox(height: 16),
            _AIAdviceCard(progress: progress, history: history),
            const SizedBox(height: 16),
            _ParentActionCard(progress: progress),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Overview ──────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final ProgressState progress;
  final SpeakingHistoryState history;
  const _OverviewCard({required this.progress, required this.history});

  @override
  Widget build(BuildContext context) {
    final weekAvg = history.weeklyAvgScore;
    final improvement = history.scoreImprovement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 今週の学習サマリー',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _OverviewStat('📚', 'レッスン', '${progress.totalLessons}回', kPrimaryColor)),
                Expanded(child: _OverviewStat('🔥', '連続日数', '${progress.streakDays}日', kAccentOrange)),
                Expanded(child: _OverviewStat('🎤', '週平均', '${weekAvg.round()}点', kSpeakingColor)),
              ],
            ),
            if (improvement != 0) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    improvement > 0 ? Icons.trending_up : Icons.trending_down,
                    color: improvement > 0 ? kAccentGreen : kAccentRed,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '先週比: ${improvement > 0 ? '+' : ''}${improvement.round()}点',
                    style: TextStyle(
                      color: improvement > 0 ? kAccentGreen : kAccentRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    improvement > 0 ? '調子がいいです！🌟' : 'もう少し頑張ろう💪',
                    style: TextStyle(
                      color: improvement > 0 ? kAccentGreen : kAccentOrange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _OverviewStat(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
      ],
    );
  }
}

// ─── Score Rings ────────────────────────────────────────────────────────────

class _SpeakingRingsRow extends StatelessWidget {
  final SpeakingHistoryState history;
  const _SpeakingRingsRow({required this.history});

  @override
  Widget build(BuildContext context) {
    final week = history.thisWeek;
    final avgScore = history.weeklyAvgScore.round();
    final todayScore = week.isNotEmpty ? week.last.avgScore.round() : 0;
    final weekTotal = history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SpeakingScoreRing(score: todayScore, size: 72),
                  const SizedBox(height: 4),
                  const Text('今日のスコア', style: TextStyle(fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SpeakingScoreRing(score: avgScore, size: 72),
                  const SizedBox(height: 4),
                  const Text('今週の平均', style: TextStyle(fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$weekTotal',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kSpeakingColor),
                  ),
                  const Text('回', style: TextStyle(color: kTextMuted)),
                  const SizedBox(height: 4),
                  const Text('今週の練習', style: TextStyle(fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Speaking Detail ────────────────────────────────────────────────────────

class _SpeakingDetailCard extends StatelessWidget {
  final ProgressState progress;
  final SpeakingHistoryState history;
  const _SpeakingDetailCard({required this.progress, required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎤 スピーキング詳細',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 16),
            SkillProgressBar(
              icon: '🗣️',
              label: '単語発音',
              value: history.weeklyWordCount / 30,
              color: kSpeakingColor,
              trailing: '${history.weeklyWordCount}/30個',
            ),
            const SizedBox(height: 10),
            SkillProgressBar(
              icon: '💬',
              label: 'フレーズ',
              value: history.weeklyPhraseCount / 40,
              color: kListeningColor,
              trailing: '${history.weeklyPhraseCount}/40個',
            ),
            const SizedBox(height: 10),
            SkillProgressBar(
              icon: '🗨️',
              label: '会話形式',
              value: history.weeklyConversationCount / 20,
              color: kAccentGreen,
              trailing: '${history.weeklyConversationCount}/20回',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('累計スピーキング練習', style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark)),
                Row(
                  children: [
                    Text(
                      '${progress.totalSpeakingPractice}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kSpeakingColor),
                    ),
                    const Text(' 個', style: TextStyle(color: kTextMuted)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly Chart ───────────────────────────────────────────────────────────

class _WeeklyProgressCard extends StatelessWidget {
  final SpeakingHistoryState history;
  const _WeeklyProgressCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final week = history.thisWeek;
    if (week.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final record = week.where((r) =>
        r.date.year == date.year && r.date.month == date.month && r.date.day == date.day
      ).toList();
      spots.add(FlSpot(i.toDouble(), record.isNotEmpty ? record.first.avgScore : 0));
    }

    final improvement = history.scoreImprovement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📈 スピーキングスコア推移（週）',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (improvement != 0)
                  Text(
                    '${improvement > 0 ? '+' : ''}${improvement.round()}点',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: improvement > 0 ? kAccentGreen : kAccentRed,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.round()}',
                          style: const TextStyle(fontSize: 10, color: kTextMuted),
                        ),
                        interval: 25,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const days = ['月', '火', '水', '木', '金', '土', '日'];
                          final dayOfWeek = now.subtract(Duration(days: 6 - val.round())).weekday - 1;
                          if (dayOfWeek < 0 || dayOfWeek >= days.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[dayOfWeek], style: const TextStyle(fontSize: 11, color: kTextMuted)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: 6, minY: 0, maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: kSpeakingColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        getDotPainter: (spot, x, bar, idx) => FlDotCirclePainter(
                          radius: 4,
                          color: spot.y >= 80 ? kAccentGreen : kSpeakingColor,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: kSpeakingColor.withAlpha(26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AI Advice ──────────────────────────────────────────────────────────────

class _AIAdviceCard extends StatelessWidget {
  final ProgressState progress;
  final SpeakingHistoryState history;
  const _AIAdviceCard({required this.progress, required this.history});

  @override
  Widget build(BuildContext context) {
    final lessons = progress.totalLessons;
    final speaking = progress.totalSpeakingPractice;
    final avgScore = history.weeklyAvgScore;
    final improvement = history.scoreImprovement;

    String growth;
    String challenge;
    String parentAction;

    if (lessons == 0) {
      growth = 'まだ学習が始まっていません。最初のレッスンに挑戦してみましょう！';
      challenge = '最初のレッスンを完了することが目標です。';
      parentAction = '「英語コレ！」を一緒に開いて、子どもに操作を教えてあげてください。';
    } else if (speaking < 10) {
      growth = 'はじめの一歩を踏み出しました！リスニングで英語の音に慣れてきています。';
      challenge = 'スピーキング練習がまだ少ないです。マイクを使った発音練習を増やしましょう。';
      parentAction = '子どもがマイクで発音するのを恥ずかしがっているかもしれません。「一緒にやってみよう」と声をかけてあげてください。';
    } else if (avgScore < 65) {
      growth = '毎日練習する習慣がついてきています！発音の基礎を着実に積み上げています。';
      challenge = '"th"や"r"の音が難しいようです。ゆっくり発音するモードで練習しましょう。';
      parentAction = '夕食後5分、「Thank you」「Good morning」などのあいさつを親子で一緒に声に出してみてください。';
    } else if (avgScore < 80) {
      growth = improvement > 0
          ? '発音スコアが先週より${improvement.round()}点上がりました！着実に成長しています。'
          : '安定したスピーキング力がついてきています。フレーズ発音に挑戦しましょう。';
      challenge = '会話形式の練習に挑戦しましょう。質問→回答のやり取りを練習することで、実践力が上がります。';
      parentAction = '週1回、親が "How are you?" と話しかけ、子どもが英語で答える練習をしてみてください。';
    } else {
      growth = 'すばらしい！スピーキング平均${avgScore.round()}点は上位レベルです！自信を持って話せるようになっています。';
      challenge = '次は「会話を続ける」練習です。同じ話題について2〜3文続けて話すことに挑戦しましょう。';
      parentAction = '週2回、英語での簡単な会話（5分間）に挑戦してみてください。子どもが先生になって、親に英語を教えてもらうのも効果的です。';
    }

    return Card(
      color: const Color(0xFFF0F7FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💬 AIからの親へのアドバイス',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
            const SizedBox(height: 12),
            _AdviceSection('✨ お子さんの成長', growth),
            const SizedBox(height: 10),
            _AdviceSection('🎯 今の課題', challenge),
            const SizedBox(height: 10),
            _AdviceSection('🏠 親ができる支援', parentAction),
          ],
        ),
      ),
    );
  }
}

class _AdviceSection extends StatelessWidget {
  final String title;
  final String body;
  const _AdviceSection(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextDark, fontSize: 14)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: kTextMuted, fontSize: 13, height: 1.5)),
      ],
    );
  }
}

// ─── Action Card ────────────────────────────────────────────────────────────

class _ParentActionCard extends StatelessWidget {
  final ProgressState progress;
  const _ParentActionCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 今週のアクションリスト',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAccentOrange)),
            const SizedBox(height: 12),
            _ActionItem('毎日5分のリスニング練習を続けよう', progress.streakDays >= 3),
            _ActionItem('スピーキング10問チャレンジ', progress.totalSpeakingPractice >= 10),
            _ActionItem('ステージ1をクリアする', progress.clearedStages.contains('stage_1')),
            _ActionItem('ステージ3をクリアする', progress.clearedStages.contains('stage_3')),
            _ActionItem('親子で英語のあいさつを練習', progress.streakDays >= 7),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String text;
  final bool done;
  const _ActionItem(this.text, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_box : Icons.check_box_outline_blank,
            color: done ? kAccentGreen : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: done ? kAccentGreen : kTextDark,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
