import 'package:flutter/material.dart';

class DailyMissionProgress extends StatelessWidget {
  final int completed;
  final int total;

  const DailyMissionProgress({
    super.key,
    required this.completed,
    required this.total,
  });

  int get percentage => total == 0 ? 0 : ((completed / total) * 100).toInt();
  bool get isComplete => completed >= total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFB74D),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isComplete ? '✅ 本日のミッション完了！' : '📋 本日のミッション',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isComplete ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$completed/$total 完了',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFB74D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
