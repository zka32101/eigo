import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int days;
  const StreakCard({super.key, required this.days});

  String _getMotivation() {
    if (days == 0) return '連続記録をスタートしよう！';
    if (days < 3) return 'あと少しで1週間！';
    if (days < 7) return 'もうすぐ1週間達成！🎯';
    if (days < 30) return '1ヶ月が目標！💪';
    if (days < 100) return '100日目指そう！🔥';
    return '素晴らしい継続力！👑';
  }

  Color _getColor() {
    if (days == 0) return Colors.grey;
    if (days >= 100) return const Color(0xFFFF6B6B);
    if (days >= 30) return const Color(0xFFF59E0B);
    if (days >= 7) return kAccentOrange;
    return kPrimaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final motivation = _getMotivation();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days == 0 ? '❄️' : '🔥',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '日連続',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              motivation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: days == 0 ? 0 : (days >= 30 ? 1.0 : days / 30),
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days >= 30 ? '🎉 目標達成！' : '目標: 30日',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
