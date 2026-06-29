import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(badgeProvider);
    final earnedIds = badgeState.earnedIds;
    final earned = earnedIds.length;
    final total = eigoBadges.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('🏆 バッジ ($earned / $total)'),
        backgroundColor: kPrimaryColor,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: eigoBadges.length,
        itemBuilder: (context, index) {
          final badge = eigoBadges[index];
          return _BadgeCard(badge: badge, isEarned: earnedIds.contains(badge.id));
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  const _BadgeCard({required this.badge, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isEarned ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEarned
                ? Text(badge.emoji, style: const TextStyle(fontSize: 36))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.4, 0,
                    ]),
                    child: Text(badge.emoji, style: const TextStyle(fontSize: 36)),
                  ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isEarned ? kTextDark : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              badge.description,
              style: const TextStyle(fontSize: 11, color: kTextMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isEarned) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kAccentGreen.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('獲得済み！', style: TextStyle(fontSize: 10, color: kAccentGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
