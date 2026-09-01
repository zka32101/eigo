import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';
import '../widgets/educational_illustrations.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(badgeProvider);
    final earnedIds = badgeState.earnedIds;
    final earned = earnedIds.length;
    final total = eigoBadges.length;
    final progressPercent = total > 0 ? earned / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('🏆 バッジ ($earned / $total)'),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          // Progress section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'バッジ取得状況',
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerMd,
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressPercent >= 1.0 ? kAccentGreen : kAccentOrange,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpacerMd,
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(0)}%',
                      style: AppTypography.labelLarge.copyWith(
                        color: kAccentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '$earned / $total 個のバッジを獲得しました！',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                ),
              ],
            ),
          ),
          // Badge grid
          Expanded(
            child: GridView.builder(
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
          ),
        ],
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: isEarned
              ? Border.all(color: kAccentGreen.withAlpha(100), width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge visual frame
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned
                      ? kAccentGreen.withAlpha(26)
                      : Colors.grey.shade300,
                  border: Border.all(
                    color: isEarned ? kAccentGreen.withAlpha(100) : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isEarned
                      ? Text(badge.emoji, style: const TextStyle(fontSize: 36))
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.4, 0,
                          ]),
                          child: Text(badge.emoji, style: const TextStyle(fontSize: 32)),
                        ),
                ),
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                badge.title,
                style: AppTypography.labelLarge.copyWith(
                  color: isEarned ? kTextDark : Colors.grey,
                  fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                badge.description,
                style: AppTypography.bodySmall.copyWith(
                  color: isEarned ? kTextMuted : Colors.grey.shade400,
                  fontSize: 11,
                ),
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
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                    border: Border.all(color: kAccentGreen.withAlpha(100), width: 1),
                  ),
                  child: Text(
                    '✓ 獲得済み',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: kAccentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
