import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

/// チャレンジ完了画面
class ChallengeCompletionScreen extends ConsumerStatefulWidget {
  final String challengeId;
  final String userId;
  final SocialChallenge challenge;

  const ChallengeCompletionScreen({
    Key? key,
    required this.challengeId,
    required this.userId,
    required this.challenge,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeCompletionScreen> createState() =>
      _ChallengeCompletionScreenState();
}

class _ChallengeCompletionScreenState extends ConsumerState<ChallengeCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProgressAsync = ref.watch(
      userChallengeProgressProvider('${widget.userId}:${widget.challengeId}'),
    );
    final userRankAsync = ref.watch(
      userChallengeRankProvider('${widget.userId}:${widget.challengeId}'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎉 チャレンジ完了'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.verticalSpacerLg,

              // アニメーション付きメダル
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withOpacity(0.2),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // 完了メッセージ
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'チャレンジ完了！',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpacerMd,
                    Text(
                      widget.challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpacerMd,
                    Text(
                      'おめでとうございます！\nあなたはこのチャレンジを完了しました。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // 報酬セクション
              userProgressAsync.when(
                data: (userProgress) {
                  if (userProgress == null) {
                    return const SizedBox.shrink();
                  }

                  final earnedRewards = widget.challenge.rewards
                      .where((r) => userProgress.earnedRewardIds.contains(r.id))
                      .toList();

                  return _RewardSummaryCard(
                    userId: widget.userId,
                    challengeId: widget.challengeId,
                    earnedRewards: earnedRewards,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerLg,

              // ランキングセクション
              userRankAsync.when(
                data: (userRank) {
                  if (userRank == null) {
                    return const SizedBox.shrink();
                  }

                  return _RankingCard(
                    rank: userRank,
                    totalParticipants: widget.challenge.participantCount,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerLg,

              // アクションボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('チャレンジハブに戻る'),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Share functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('友達と共有しました！'),
                          ),
                        );
                      },
                      child: const Text('友達と共有'),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }
}

/// 報酬サマリーカード
class _RewardSummaryCard extends ConsumerWidget {
  final String userId;
  final String challengeId;
  final List<ChallengeReward> earnedRewards;

  const _RewardSummaryCard({
    required this.userId,
    required this.challengeId,
    required this.earnedRewards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalCoins = 0;
    int totalXp = 0;

    for (final reward in earnedRewards) {
      totalCoins += reward.coinReward;
      totalXp += reward.xpReward;
    }

    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '獲得した報酬',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,

            // 報酬統計
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Rewardstat(
                  icon: '🪙',
                  label: 'コイン',
                  value: totalCoins,
                ),
                _Rewardstat(
                  icon: '⭐',
                  label: 'XP',
                  value: totalXp,
                ),
                _Rewardstat(
                  icon: '🏅',
                  label: '報酬',
                  value: earnedRewards.length,
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            if (earnedRewards.isNotEmpty) ...[
              AppSpacing.verticalSpacerMd,
              Text(
                '獲得したティア',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: earnedRewards.map((reward) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(reward.tier),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getTierEmoji(reward.tier)),
                        AppSpacing.horizontalSpacerSm,
                        Text(
                          reward.tierLabel,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            AppSpacing.verticalSpacerMd,

            // 報酬受け取りボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(claimRewardsActionProvider('$userId:$challengeId'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('報酬を受け取りました！'),
                    ),
                  );
                },
                child: const Text('報酬を受け取る'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return Colors.orange.withOpacity(0.2);
      case 2:
        return Colors.grey[400]!.withOpacity(0.2);
      case 3:
        return Colors.amber.withOpacity(0.2);
      case 4:
        return Colors.purple.withOpacity(0.2);
      case 5:
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.blue.withOpacity(0.2);
    }
  }

  String _getTierEmoji(int tier) {
    switch (tier) {
      case 1:
        return '🥉';
      case 2:
        return '🥈';
      case 3:
        return '🥇';
      case 4:
        return '💎';
      case 5:
        return '👑';
      default:
        return '🏅';
    }
  }
}

/// 報酬統計
class _Rewardstat extends StatelessWidget {
  final String icon;
  final String label;
  final int value;

  const _Rewardstat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        AppSpacing.verticalSpacerSm,
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        AppSpacing.verticalSpacerSm,
        Text(
          '+$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
      ],
    );
  }
}

/// ランキングカード
class _RankingCard extends StatelessWidget {
  final int rank;
  final int totalParticipants;

  const _RankingCard({
    required this.rank,
    required this.totalParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final percentile = ((totalParticipants - rank) / totalParticipants * 100)
        .toStringAsFixed(1);

    return Card(
      color: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'あなたの順位',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$rank',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                ),
                AppSpacing.horizontalSpacerMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '位',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '全$totalParticipants名中',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              'トップ $percentile%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            _getMedalWidget(rank),
          ],
        ),
      ),
    );
  }

  Widget _getMedalWidget(int rank) {
    if (rank == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '🥇 1位受賞！',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (rank == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '🥈 2位受賞！',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (rank == 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '🥉 3位受賞！',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
