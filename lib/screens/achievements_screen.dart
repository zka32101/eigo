import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../models/badge_model.dart';
import '../providers/badge_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(badgeProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 アチーブメント'),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              Tab(
                child: Stack(
                  children: [
                    const Text('獲得バッジ'),
                    if (badgeState.newlyEarned.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${badgeState.newlyEarned.length}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Tab(text: '進捗'),
              const Tab(text: '全バッジ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 獲得バッジタブ
            _UnlockedBadgesTab(earnedBadges: badgeState.earnedBadges),
            // 進捗タブ
            _ProgressTab(),
            // 全バッジタブ
            _AllBadgesTab(earnedIds: badgeState.earnedIds),
          ],
        ),
      ),
    );
  }
}

class _UnlockedBadgesTab extends StatelessWidget {
  final List<EarnedBadge> earnedBadges;

  const _UnlockedBadgesTab({required this.earnedBadges});

  @override
  Widget build(BuildContext context) {
    if (earnedBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard_outlined, size: 64, color: AppColors.textMuted),
            AppSpacing.verticalSpacerMd,
            const Text('獲得したバッジはまだありません'),
            AppSpacing.verticalSpacerSm,
            Text(
              'レッスンを完了してバッジを獲得しましょう！',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.accentGreen.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('獲得バッジ', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    AppSpacing.verticalSpacerXs,
                    Text('${earnedBadges.length}個', style: AppTypography.headlineMedium),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '✓',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // バッジグリッド
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: earnedBadges.length,
            itemBuilder: (context, index) {
              final badge = earnedBadges[index];
              return _BadgeCard(
                icon: badge.badge.emoji,
                title: badge.badge.title,
                onTap: () => _showBadgeDetails(context, badge),
              );
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, EarnedBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(badge.badge.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(badge.badge.emoji, style: TextStyle(fontSize: AppTypography.displayLarge.fontSize! * 2)),
            ),
            AppSpacing.verticalSpacerMd,
            Text(badge.badge.description),
            AppSpacing.verticalSpacerMd,
            Text(
              '獲得日: ${badge.earnedAt.year}年${badge.earnedAt.month}月${badge.earnedAt.day}日',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class _ProgressTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList = ref.watch(badgeProgressProvider);

    if (progressList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final unlockedCount = progressList.where((b) => b.isUnlocked).length;
    final overallProgress = progressList.isEmpty
        ? 0.0
        : progressList.fold<double>(0, (sum, b) => sum + b.progress) / progressList.length;

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 全体進捗
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('全体進捗', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text('${(overallProgress * 100).toStringAsFixed(0)}%', style: AppTypography.labelLarge),
                  ],
                ),
                AppSpacing.verticalSpacerMd,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 12,
                    backgroundColor: AppColors.bgLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  '$unlockedCount/${progressList.length} バッジ獲得済み',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // バッジ進捗一覧
          Text('進捗状況', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          ...progressList.map((badge) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _BadgeProgressCard(badge: badge),
            );
          }).toList(),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _AllBadgesTab extends StatelessWidget {
  final Set<String> earnedIds;

  const _AllBadgesTab({required this.earnedIds});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('全バッジ一覧', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12, // 全バッジ数
            itemBuilder: (context, index) {
              final isEarned = index < earnedIds.length;
              return _AllBadgeCard(
                icon: ['🌱', '📚', '🎓', '🏃', '🪙', '🔥', '👑', '🎯', '🦋', '📈', '⭐', '🌟'][index],
                title: ['はじめ', '勉強仲', '献身的', 'マラソ', 'コイン', '熱い', '伝説', '精密', 'ソーシ', 'テン', 'ステ1', 'ステ5'][index],
                isEarned: isEarned,
              );
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:AppColors.textWhite,
          border: Border.all(color: AppColors.bgLight),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
            AppSpacing.verticalSpacerXs,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeProgressCard extends StatelessWidget {
  final BadgeProgress badge;

  const _BadgeProgressCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final progressColor = badge.isUnlocked ? AppColors.accentGreen : AppColors.accentOrange;

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: badge.isUnlocked ? AppColors.accentGreen.withAlpha(10) : AppColors.bgLight.withOpacity(0.5),
        border: Border.all(
          color: badge.isUnlocked ? AppColors.accentGreen.withAlpha(50) :AppColors.bgLight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(badge.icon, style: TextStyle(fontSize: AppTypography.headlineLarge.fontSize)),
                  AppSpacing.horizontalSpacerMd,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(badge.title, style: AppTypography.labelLarge),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        badge.isUnlocked ? '✓ 獲得済み' : '${badge.currentValue}/${badge.targetValue}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              if (badge.isUnlocked)
                const Icon(Icons.check_circle, color: AppColors.accentGreen)
              else
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: progressColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${(badge.progress * 100).toStringAsFixed(0)}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (!badge.isUnlocked) ...[
            AppSpacing.verticalSpacerMd,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 8,
                backgroundColor: AppColors.bgLight,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllBadgeCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isEarned;

  const _AllBadgeCard({
    required this.icon,
    required this.title,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isEarned ? AppColors.textWhite : AppColors.bgLight,
        border: Border.all(
          color: isEarned ? Colors.grey[300]! :AppColors.bgLight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: AppTypography.headlineLarge.fontSize,
              opacity: isEarned ? 1.0 : 0.3,
            ),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: isEarned ? Colors.black : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isEarned)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: const Icon(Icons.lock, size: AppSizes.iconSizeSmall, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
