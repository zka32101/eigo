import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/level_provider.dart';
import '../providers/speaking_history_provider.dart';
import '../widgets/xp_bar.dart';

class StudyCalendarScreen extends ConsumerWidget {
  const StudyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(speakingHistoryProvider);
    final level = ref.watch(levelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 学習カレンダー'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '週次レポート',
            onPressed: () => Navigator.of(context).pushNamed('/weekly-report'),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.allPaddingMd,
        children: [
          XpBar(level: level),
          AppSpacing.verticalSpacerXs,
          _MonthCalendar(history: history),
          AppSpacing.verticalSpacerSm,
          _HeatmapLegend(),
          AppSpacing.verticalSpacerSm,
          _WeeklyStats(history: history),
          AppSpacing.verticalSpacerSm,
          _RecentActivityList(history: history),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

// ─── 月カレンダー ────────────────────────────────────────────────

class _MonthCalendar extends StatefulWidget {
  final SpeakingHistoryState history;
  const _MonthCalendar({required this.history});

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() => setState(() {
    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
  });

  void _nextMonth() {
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (!next.isAfter(DateTime.now())) {
      setState(() => _displayMonth = next);
    }
  }

  Map<int, DailySpeakingRecord> _buildDayMap() {
    final map = <int, DailySpeakingRecord>{};
    for (final r in widget.history.records) {
      if (r.date.year == _displayMonth.year && r.date.month == _displayMonth.month) {
        map[r.date.day] = r;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final dayMap = _buildDayMap();
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=日, 1=月, ...

    final now = DateTime.now();
    final isCurrentMonth = _displayMonth.year == now.year && _displayMonth.month == now.month;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ナビゲーション
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_displayMonth.year}年${_displayMonth.month}月',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: isCurrentMonth ? AppColors.bgLight : AppColors.textPrimary),
                  onPressed: isCurrentMonth ? null : _nextMonth,
                ),
              ],
            ),
            AppSpacing.verticalSpacerXs,
            // 曜日ヘッダー
            Row(
              children: ['日', '月', '火', '水', '木', '金', '土'].map((d) => Expanded(
                child: Center(
                  child: Text(d, style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: d == '日' ? AppColors.error : d == '土' ? AppColors.primary : AppColors.textMuted,
                  )),
                ),
              )).toList(),
            ),
            AppSpacing.verticalSpacerXs,
            // カレンダーグリッド
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < startWeekday) return const SizedBox.shrink();
                final day = i - startWeekday + 1;
                final record = dayMap[day];
                final isToday = isCurrentMonth && day == now.day;
                final isFuture = isCurrentMonth && day > now.day;

                return _DayCell(
                  day: day,
                  record: record,
                  isToday: isToday,
                  isFuture: isFuture,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final DailySpeakingRecord? record;
  final bool isToday;
  final bool isFuture;

  const _DayCell({required this.day, this.record, required this.isToday, required this.isFuture});

  Color _bgColor() {
    if (isFuture) return Colors.transparent;
    if (record == null) return Colors.transparent;
    final score = record!.avgScore;
    if (score >= 85) return AppColors.accentGreen.withAlpha(200);
    if (score >= 70) return AppColors.primary.withAlpha(160);
    if (score >= 55) return AppColors.accentOrange.withAlpha(140);
    return kSpeakingColor.withAlpha(120);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor();
    final hasRecord = record != null && !isFuture;

    return Container(
      decoration: BoxDecoration(
        color: hasRecord ? bg : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: hasRecord
                ? AppColors.textWhite
                : isFuture
                    ? AppColors.bgLight
                    : isToday
                        ? AppColors.primary
                        : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── ヒートマップ凡例 ────────────────────────────────────────────

class _HeatmapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('スコア低 ', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
          ...[kSpeakingColor, AppColors.accentOrange, AppColors.primary, AppColors.accentGreen].map((c) =>
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(color: c.withAlpha(180), borderRadius: BorderRadius.circular(3)),
            ),
          ),
          Text(' 高', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── 週次サマリー ────────────────────────────────────────────────

class _WeeklyStats extends StatelessWidget {
  final SpeakingHistoryState history;
  const _WeeklyStats({required this.history});

  @override
  Widget build(BuildContext context) {
    final week = history.thisWeek;
    final studyDays = week.length;
    final totalPractice = history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount;
    final avgScore = history.weeklyAvgScore;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 今週のサマリー',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.verticalSpacerXs,
            Row(
              children: [
                Expanded(child: _WeekStat('📅', '学習日数', '$studyDays日', AppColors.primary)),
                Expanded(child: _WeekStat('🎤', '練習回数', '$totalPractice回', kSpeakingColor)),
                Expanded(child: _WeekStat('📈', '平均スコア', '${avgScore.round()}点', AppColors.accentGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _WeekStat(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
    ],
  );
}

// ─── 最近のアクティビティ ────────────────────────────────────────

class _RecentActivityList extends StatelessWidget {
  final SpeakingHistoryState history;
  const _RecentActivityList({required this.history});

  @override
  Widget build(BuildContext context) {
    final recent = history.records.reversed.take(14).toList();
    if (recent.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: Text('まだ学習記録がありません', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted))),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 最近の学習履歴',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.verticalSpacerXs,
            ...recent.map((r) {
              final dateStr = '${r.date.month}/${r.date.day}（${_weekdayLabel(r.date.weekday)}）';
              final scoreColor = r.avgScore >= 85
                  ? AppColors.accentGreen
                  : r.avgScore >= 70
                      ? AppColors.primary
                      : AppColors.accentOrange;
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      margin: EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(color: scoreColor, shape: BoxShape.circle),
                    ),
                    Text(dateStr, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                    AppSpacing.horizontalSpacerXs,
                    Expanded(
                      child: Text(
                        '単語${r.wordCount}・フレーズ${r.phraseCount}・会話${r.conversationCount}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${r.avgScore.round()}点',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: scoreColor),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[(weekday - 1) % 7];
  }
}
