import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../providers/english_town_provider.dart';
import '../providers/english_town_rewards_provider.dart';
import '../design_system/design_system.dart';

/// English-Only Town Reward Screen
///
/// Displays rewards earned from a conversation:
/// - XP earned
/// - Coins earned
/// - Achievements unlocked
/// - Milestones reached
/// - Next unlock information
class EnglishTownRewardScreen extends ConsumerWidget {
  final int xpEarned;
  final int coinsEarned;
  final List<String> achievementsUnlocked;
  final List<String> milestonesUnlocked;
  final String? npcMessage;
  final VoidCallback? onContinue;

  const EnglishTownRewardScreen({
    Key? key,
    required this.xpEarned,
    required this.coinsEarned,
    this.achievementsUnlocked = const [],
    this.milestonesUnlocked = const [],
    this.npcMessage,
    this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.lg),

              // Reward header with animation
              _buildRewardHeader(),

              SizedBox(height: AppSpacing.lg),

              // XP and Coin rewards
              _buildRewardCards(),

              SizedBox(height: AppSpacing.lg),

              // Achievements unlocked
              if (achievementsUnlocked.isNotEmpty)
                _buildAchievementsSection(),

              // Milestones reached
              if (milestonesUnlocked.isNotEmpty)
                _buildMilestonesSection(),

              // NPC message
              if (npcMessage != null)
                _buildNPCMessage(),

              // Next unlock info
              _buildNextUnlockInfo(ref),

              SizedBox(height: AppSpacing.lg),

              // Continue button
              ElevatedButton(
                onPressed: onContinue ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg * 2,
                    vertical: AppSpacing.md,
                  ),
                  backgroundColor: AppColors.accentGreen,
                ),
                child: Text(
                  'Continue',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Build reward header
  Widget _buildRewardHeader() {
    return Column(
      children: [
        // Celebration emoji
        const Text(
          '🎉',
          style: TextStyle(fontSize: 64),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Conversation Complete!',
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'You earned rewards for your efforts!',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build XP and coin reward cards
  Widget _buildRewardCards() {
    return Row(
      children: [
        Expanded(
          child: _buildRewardCard(
            emoji: '⚡',
            label: 'XP Earned',
            value: xpEarned.toString(),
            color: AppColors.accentOrange,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildRewardCard(
            emoji: '💰',
            label: 'Coins Earned',
            value: coinsEarned.toString(),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  /// Build individual reward card
  Widget _buildRewardCard({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build achievements section
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Achievements Unlocked!',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            border: Border.all(color: Colors.amber, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: achievementsUnlocked
                .map(
                  (id) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            id,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// Build milestones section
  Widget _buildMilestonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Milestones Reached!',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            border: Border.all(color: AppColors.accentGreen, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: milestonesUnlocked
                .map(
                  (id) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 20)),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            id,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// Build NPC message
  Widget _buildNPCMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💬 NPC Message',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border.all(color: AppColors.primary, width: 1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Text(
            npcMessage ?? '',
            style: AppTypography.bodySmall,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// Build next unlock information
  Widget _buildNextUnlockInfo(WidgetRef ref) {
    final nextUnlock = ref.watch(nextLocationUnlockProvider);

    if (nextUnlock == null) {
      return Column(
        children: [
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              border: Border.all(color: AppColors.accentGreen, width: 1),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 36)),
                SizedBox(height: AppSpacing.md),
                Text(
                  'All Locations Unlocked!',
                  style: AppTypography.titleSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'You have access to all 8 locations in English-Only Town.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            '🔓 Next Location Unlock',
            style: AppTypography.titleSmall,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextUnlock.locationName,
                    style: AppTypography.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '${nextUnlock.conversationsNeeded} more conversations needed',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '↗️',
                style: AppTypography.headlineSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple reward popup dialog
class RewardPopupDialog extends StatelessWidget {
  final int xpEarned;
  final int coinsEarned;

  const RewardPopupDialog({
    Key? key,
    required this.xpEarned,
    required this.coinsEarned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: AppSpacing.md),
            Text(
              'Rewards Earned!',
              style: AppTypography.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 32)),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '+$xpEarned XP',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 32)),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '+$coinsEarned',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
              ),
              child: Text(
                'Continue',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
