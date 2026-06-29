import 'package:flutter/material.dart';
import '../providers/level_provider.dart';
import '../theme/app_theme.dart';

/// XP バーウィジェット（compact/full 両対応）
class XpBar extends StatelessWidget {
  final LevelState level;
  final bool compact;

  const XpBar({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) return _CompactXpBar(level: level);
    return _FullXpBar(level: level);
  }
}

class _CompactXpBar extends StatelessWidget {
  final LevelState level;
  const _CompactXpBar({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${level.rankEmoji} Lv.${level.level}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level.progressToNext,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${level.xpToNextLevel}XP',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class _FullXpBar extends StatelessWidget {
  final LevelState level;
  const _FullXpBar({required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(level.rankEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lv.${level.level}  ${level.rank}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark),
                        ),
                        Text(
                          '累計 ${level.totalXp} XP',
                          style: const TextStyle(fontSize: 11, color: kTextMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lv.${level.level + 1} まで',
                      style: const TextStyle(fontSize: 11, color: kTextMuted),
                    ),
                    Text(
                      '${level.xpToNextLevel} XP',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: level.progressToNext,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${level.currentLevelXp} / ${level.xpNeededForNext} XP',
              style: const TextStyle(fontSize: 11, color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// レベルアップ演出オーバーレイ
class LevelUpOverlay extends StatelessWidget {
  final int newLevel;
  final String rankEmoji;
  final String rank;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.rankEmoji,
    required this.rank,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rankEmoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  const Text(
                    'レベルアップ！',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lv.$newLevel  $rank',
                    style: const TextStyle(fontSize: 18, color: kTextDark),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onDismiss,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                    child: const Text('やった！', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
