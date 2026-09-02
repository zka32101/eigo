import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../providers/study_time_provider.dart';

class StudyTimeCard extends StatelessWidget {
  final StudyTimeState studyTime;

  const StudyTimeCard({super.key, required this.studyTime});

  @override
  Widget build(BuildContext context) {
    final minutes = studyTime.todaySeconds ~/ 60;
    final emoji = minutes == 0 ? '📚' : minutes < 10 ? '⏱️' : '🎉';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4CAF50), const Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '今日の学習時間',
                style: TextStyle(color: AppColors.textWhite, fontSize: 12),
              ),
              Text(
                studyTime.todayDisplay,
                style: const TextStyle(
                  color:AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (minutes >= 10)
            const Icon(Icons.check_circle, color: AppColors.textWhite, size: 24)
          else
            Text(
              '${10 - minutes}分',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
