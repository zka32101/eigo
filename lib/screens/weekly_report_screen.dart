import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/speaking_history_provider.dart';
import '../providers/weakness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/xp_bar.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final history = ref.watch(speakingHistoryProvider);
    final weakness = ref.watch(weaknessProvider);
    final level = ref.watch(levelProvider);
    final week = history.thisWeek;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 週次レポート'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.of(context).pushNamed('/calendar'),
            tooltip: 'カレンダー',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LevelSection(level: level),
          const SizedBox(height: 16),
          _WeekSummaryCard(progress: progress, history: history, week: week),
          const SizedBox(height: 16),
          _SkillBreakdownCard(weakness: weakness),
          const SizedBox(height: 16),
          _DailyScoreChart(week: week),
          const SizedBox(height: 16),
          _ImprovementCard(history: history),
          const SizedBox(height: 16),
          _GoalCard(progress: progress, history: history),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Level Section ─────────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  final LevelState level;
  const _LevelSection({required this.level});

  @override
  Widget build(BuildContext context) {
    return XpBar(level: level, compact: false);
  }
}

// ─── Week Summary ───────────────────────────────────────────────

class _WeekSummaryCard extends StatelessWidget {
  final ProgressState progress;
  final SpeakingHistoryState history;
  final List<DailySpeakingRecord> week;
  const _WeekSummaryCard({required this.progress, required this.history, required this.week});

  @override
  Widget build(BuildContext context) {
    final studyDays = week.length;
    final totalPractice = history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount;
    final avgScore = history.weeklyAvgScore;
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
                const Text('📈 今週のサマリー',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
                if (improvement != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: improvement > 0 ? kAccentGreen.withAlpha(26) : kAccentRed.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '先週比 ${improvement > 0 ? '+' : ''}${improvement.round()}点',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: improvement > 0 ? kAccentGreen : kAccentRed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _SummaryCell('📅', '学習日数', '$studyDays / 7日', kPrimaryColor, studyDays / 7),
                _SummaryCell('🎤', 'スピーキング', '$totalPractice回', kSpeakingColor, totalPractice / 50),
                _SummaryCell('📊', '平均スコア', '${avgScore.round()}点', kAccentGreen, avgScore / 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final double progress;
  const _SummaryCell(this.icon, this.label, this.value, this.color, this.progress);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skill Breakdown ────────────────────────────────────────────

class _SkillBreakdownCard extends StatelessWidget {
  final WeaknessState weakness;
  const _SkillBreakdownCard({required this.weakness});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 スキル別パフォーマンス',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 14),
            _SkillRow('👂 リスニング', weakness.listeningAccuracy, kListeningColor),
            const SizedBox(height: 10),
            _SkillRow('🎤 スピーキング', weakness.speakingAvgScore / 100, kSpeakingColor),
            const SizedBox(height: 10),
            _SkillRow('📖 リーディング', 1 - weakness.skillWeaknessRate(QuestionType.reading), kReadingColor),
            const SizedBox(height: 10),
            _SkillRow('✏️ ライティング', 1 - weakness.skillWeaknessRate(QuestionType.writing), kWritingColor),
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SkillRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0.0, 100.0);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 13, color: kTextDark)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${pct.round()}%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ─── Daily Score Chart ──────────────────────────────────────────

class _DailyScoreChart extends StatelessWidget {
  final List<DailySpeakingRecord> week;
  const _DailyScoreChart({required this.week});

  @override
  Widget build(BuildContext context) {
    if (week.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final spots = <FlSpot>[];
    final barData = <BarChartGroupData>[];

    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final record = week.where((r) =>
          r.date.year == date.year && r.date.month == date.month && r.date.day == date.day
      ).toList();
      final score = record.isNotEmpty ? record.first.avgScore : 0.0;
      spots.add(FlSpot(i.toDouble(), score));
      barData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: score,
            color: score >= 80 ? kAccentGreen : score >= 60 ? kPrimaryColor : kSpeakingColor,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📅 日別スピーキングスコア',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  barGroups: barData,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) => Text(
                          '${v.round()}',
                          style: const TextStyle(fontSize: 10, color: kTextMuted),
                        ),
                        interval: 25,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const days = ['月', '火', '水', '木', '金', '土', '日'];
                          final date = now.subtract(Duration(days: 6 - v.round()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[(date.weekday - 1) % 7],
                                style: const TextStyle(fontSize: 11, color: kTextMuted)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  maxY: 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            '${rod.toY.round()}点',
                            const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Improvement Card ───────────────────────────────────────────

class _ImprovementCard extends StatelessWidget {
  final SpeakingHistoryState history;
  const _ImprovementCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final improvement = history.scoreImprovement;
    final avg = history.weeklyAvgScore;

    String message;
    Color color;
    String icon;

    if (avg == 0) {
      message = 'まだデータがありません。レッスンを開始しよう！';
      color = kTextMuted;
      icon = '💡';
    } else if (improvement > 10) {
      message = '大幅改善！先週より${improvement.round()}点上がりました。この調子で頑張ろう！';
      color = kAccentGreen;
      icon = '🚀';
    } else if (improvement > 0) {
      message = '着実に成長しています。先週より${improvement.round()}点アップ！';
      color = kAccentGreen;
      icon = '📈';
    } else if (improvement < -5) {
      message = '先週より${(-improvement).round()}点下がりました。毎日少しずつ練習しよう。';
      color = kAccentOrange;
      icon = '💪';
    } else {
      message = '安定したスコアを維持しています。次のステージに挑戦してみよう！';
      color = kPrimaryColor;
      icon = '⭐';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('今週の振り返り',
                      style: TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(fontSize: 14, color: color, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Goal Card ──────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final ProgressState progress;
  final SpeakingHistoryState history;
  const _GoalCard({required this.progress, required this.history});

  @override
  Widget build(BuildContext context) {
    final goals = [
      _GoalItem('今週7日間学習', history.thisWeek.length / 7, '${history.thisWeek.length}/7日'),
      _GoalItem('スピーキング50回練習',
        (history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount) / 50,
        '${history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount}/50回'),
      _GoalItem('平均スコア80点以上', history.weeklyAvgScore / 80, '${history.weeklyAvgScore.round()}/80点'),
      _GoalItem('5ステージクリア', progress.clearedStages.length / 5, '${progress.clearedStages.length}/5ステージ'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 今週の目標',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 12),
            ...goals.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(g.label, style: const TextStyle(fontSize: 13, color: kTextDark)),
                      Text(g.progress >= 1 ? '✅ 達成！' : g.valueLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: g.progress >= 1 ? kAccentGreen : kTextMuted,
                            fontWeight: g.progress >= 1 ? FontWeight.bold : FontWeight.normal,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: g.progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      color: g.progress >= 1 ? kAccentGreen : kPrimaryColor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _GoalItem {
  final String label;
  final double progress;
  final String valueLabel;
  const _GoalItem(this.label, this.progress, this.valueLabel);
}

