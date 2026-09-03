import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../models/english_town_social_model.dart';
import '../providers/english_town_social_provider.dart';

/// Friend profile screen with stats comparison and actions
class SocialFriendProfileScreen extends ConsumerWidget {
  final String friendId;

  const SocialFriendProfileScreen({
    super.key,
    required this.friendId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendProfile = ref.watch(userProfileProvider(friendId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('フレンドプロフィール'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: friendProfile.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: AppColors.textMuted),
                  AppSpacing.verticalSpacerMd,
                  const Text('ユーザーが見つかりません'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _ProfileHeader(profile: profile),
                AppSpacing.verticalSpacerLg,

                // Stats comparison
                _StatsComparison(friendId: friendId),
                AppSpacing.verticalSpacerLg,

                // Badges section
                if (profile.badges.isNotEmpty) ...[
                  _BadgesSection(badges: profile.badges),
                  AppSpacing.verticalSpacerLg,
                ],

                // Bio
                if (profile.bio != null && profile.bio!.isNotEmpty)
                  _BioSection(bio: profile.bio!),

                AppSpacing.verticalSpacerXxl,
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      bottomNavigationBar: friendProfile.when(
        data: (profile) => profile != null
            ? _ActionButtons(friendId: friendId)
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final SocialProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withAlpha(200),
            AppColors.primary.withAlpha(100),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textWhite,
                width: 3,
              ),
              image: profile.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profile.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.avatarUrl == null
                ? const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  )
                : null,
          ),
          AppSpacing.verticalSpacerMd,

          // Display name
          Text(
            profile.displayName,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpacerSm,

          // Level and XP
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withAlpha(30),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⭐ Lv.${profile.level}',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                Text(
                  '${profile.totalXp} XP',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerMd,

          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat(
                value: '${profile.totalConversations}',
                label: '会話',
              ),
              _QuickStat(
                value: '${profile.currentStreak}',
                label: '連勝中',
              ),
              _QuickStat(
                value: '${profile.friendsCount}',
                label: 'フレンド',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;

  const _QuickStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSpacerXs,
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textWhite.withAlpha(200),
          ),
        ),
      ],
    );
  }
}

class _StatsComparison extends ConsumerWidget {
  final String friendId;

  const _StatsComparison({required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(friendComparisonProvider(friendId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: comparison.when(
        data: (data) {
          if (data == null) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 統計比較',
                style: AppTypography.headlineSmall,
              ),
              AppSpacing.verticalSpacerMd,
              _ComparisonRow(
                stat: '総XP',
                yourValue: data['user']['totalXp'].toString(),
                friendValue: data['friend']['totalXp'].toString(),
                difference: data['comparison']['xpDifference'] ?? 0,
              ),
              AppSpacing.verticalSpacerMd,
              _ComparisonRow(
                stat: '会話数',
                yourValue: data['user']['totalConversations'].toString(),
                friendValue: data['friend']['totalConversations'].toString(),
                difference: data['comparison']['conversationDifference'] ?? 0,
              ),
              AppSpacing.verticalSpacerMd,
              _ComparisonRow(
                stat: 'レベル',
                yourValue: data['user']['level'].toString(),
                friendValue: data['friend']['level'].toString(),
                difference: data['comparison']['levelDifference'] ?? 0,
              ),
              AppSpacing.verticalSpacerMd,
              _ComparisonRow(
                stat: '連続日数',
                yourValue: data['user']['currentStreak'].toString(),
                friendValue: data['friend']['currentStreak'].toString(),
                difference: data['comparison']['streakDifference'] ?? 0,
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String stat;
  final String yourValue;
  final String friendValue;
  final int difference;

  const _ComparisonRow({
    required this.stat,
    required this.yourValue,
    required this.friendValue,
    required this.difference,
  });

  @override
  Widget build(BuildContext context) {
    final isYourAdvantage = difference > 0;
    final indicator = difference == 0 ? '=' : (isYourAdvantage ? '↑' : '↓');
    final indicatorColor = difference == 0 ? AppColors.textMuted : (isYourAdvantage ? AppColors.accentGreen : AppColors.accentRed);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stat name
          Text(
            stat,
            style: AppTypography.labelLarge,
          ),

          // Values
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Your value
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  ),
                  child: Text(
                    'あなた: $yourValue',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSpacing.horizontalSpacerMd,

                // Indicator
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColor.withAlpha(30),
                  ),
                  child: Center(
                    child: Text(
                      indicator,
                      style: TextStyle(
                        fontSize: 16,
                        color: indicatorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AppSpacing.horizontalSpacerMd,

                // Friend's value
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  ),
                  child: Text(
                    'フレンド: $friendValue',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  final List<String> badges;

  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 バッジ',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: badges.map((badge) {
              return Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withAlpha(20),
                  border: Border.all(
                    color: AppColors.accentOrange.withAlpha(50),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Text(
                  badge,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  final String bio;

  const _BioSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💬 自己紹介',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerMd,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Text(
              bio,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final String friendId;

  const _ActionButtons({required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.bgLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Compare stats
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('統計比較機能')),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('比較'),
            ),
          ),
          AppSpacing.horizontalSpacerMd,
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Invite to challenge
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('チャレンジ招待機能')),
                );
              },
              icon: const Icon(Icons.sports_esports),
              label: const Text('招待'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
