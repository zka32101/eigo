import '../design_system/design_system.dart';
import 'package:flutter/material.dart';

class DailyScore {
  final String date; // "Mon" など
  final int score;
  final DateTime fullDate;

  DailyScore({required this.date, required this.score, required this.fullDate});
}

class WeeklyRankingCard extends StatelessWidget {
  final List<DailyScore> weeklyScores;

  const WeeklyRankingCard({super.key, required this.weeklyScores});

  String _getDayLabel(DateTime date) {
    final days = ['日', '月', '火', '水', '木', '金', '土'];
    return '${date.month}/${date.day}(${days[date.weekday % 7]})';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<DailyScore>.from(weeklyScores)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:AppColors.textWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMuted.withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 今週のランキング',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(
                sorted.length,
                (i) {
                  final score = sorted[i];
                  final medal = i == 0
                      ? '🥇'
                      : i == 1
                          ? '🥈'
                          : i == 2
                              ? '🥉'
                              : '${i + 1}.';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(medal, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getDayLabel(score.fullDate),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getColorForRank(i),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${score.score}コイン',
                            style: const TextStyle(
                              color:AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForRank(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFB74D);
      case 1:
        return const Color(0xFFA1887F);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textMuted;
    }
  }
}
