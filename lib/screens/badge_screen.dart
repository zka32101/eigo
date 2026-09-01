import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

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
        padding: AppSpacing.allPaddingLg,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
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
        padding: AppSpacing.allPaddingMd,
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
            AppSpacing.verticalSpacerXs,
            Text(
              badge.title,
              style: AppTypography.labelLarge.copyWith(
                color: isEarned ? kTextDark : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpacerXs,
            Text(
              badge.description,
              style: AppTypography.bodySmall.copyWith(color: kTextMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isEarned) ...[
              AppSpacing.verticalSpacerXs,
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: kAccentGreen.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Text('獲得済み！', style: AppTypography.bodySmall.copyWith(fontSize: 10, color: kAccentGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
