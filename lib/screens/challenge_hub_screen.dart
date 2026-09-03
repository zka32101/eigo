import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import 'challenge_detail_screen.dart';

/// チャレンジハブ画面
class ChallengeHubScreen extends ConsumerWidget {
  const ChallengeHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final activeChallengesAsync = ref.watch(activeChallengesProvider);
    final userActiveChallengesAsync = ref.watch(userActiveChallengesProvider(userId));
    final userCompletedChallengesAsync = ref.watch(userCompletedChallengesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 チャレンジ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザー統計
              userActiveChallengesAsync.when(
                data: (userActive) {
                  return userCompletedChallengesAsync.when(
                    data: (userCompleted) {
                      return _StatisticsCard(
                        activeChallenges: userActive.length,
                        completedChallenges: userCompleted.length,
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerLg,

              // アクティブなチャレンジセクション
              Text(
                'アクティブなチャレンジ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              activeChallengesAsync.when(
                data: (challenges) {
                  if (challenges.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Center(
                          child: Text(
                            'アクティブなチャレンジはありません',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      return _ChallengeCard(
                        challenge: challenge,
                        userId: userId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallengeDetailScreen(
                                challenge: challenge,
                                userId: userId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('エラー: $error'),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // 完了したチャレンジセクション
              Text(
                '完了したチャレンジ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              userCompletedChallengesAsync.when(
                data: (completed) {
                  if (completed.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Center(
                          child: Text(
                            'まだチャレンジを完了していません',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completed.take(5).length,
                    itemBuilder: (context, index) {
                      final progress = completed[index];
                      return _CompletedChallengeCard(progress: progress);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }
}

/// チャレンジカード
class _ChallengeCard extends ConsumerWidget {
  final SocialChallenge challenge;
  final String userId;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.challenge,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgressAsync = ref.watch(
      userChallengeProgressProvider('$userId:${challenge.id}'),
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.verticalSpacerSm,
                        Text(
                          challenge.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Chip(
                        label: Text(challenge.typeLabel),
                        avatar: Text(challenge.difficultyEmoji),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                      AppSpacing.verticalSpacerSm,
                      Text(
                        challenge.formattedTimeRemaining,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,

              // プログレスバーセクション
              userProgressAsync.when(
                data: (userProgress) {
                  final progress = userProgress?.progress ?? 0;
                  final percentage = (progress / challenge.targetValue * 100)
                      .clamp(0.0, 100.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '進捗: $progress/${challenge.targetValue}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpacerSm,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage >= 100 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                      AppSpacing.verticalSpacerMd,

                      // 参加者情報
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '👥 ${challenge.participantCount}名が参加中',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          if (userProgress == null)
                            ElevatedButton(
                              onPressed: () {
                                ref.read(joinChallengeActionProvider(
                                  JoinChallengeParams(
                                    userId: userId,
                                    challengeId: challenge.id,
                                  ),
                                ));
                              },
                              child: const Text('参加する'),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => onTap(),
                              child: const Text('詳細を見る'),
                            ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 完了したチャレンジカード
class _CompletedChallengeCard extends StatelessWidget {
  final UserChallengeProgress progress;

  const _CompletedChallengeCard({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green.withOpacity(0.05),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'チャレンジID: ${progress.challengeId}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    '✅ 完了',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                ],
              ),
            ),
            if (progress.completedAt != null)
              Text(
                '${progress.completedAt!.year}年${progress.completedAt!.month}月${progress.completedAt!.day}日',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 統計カード
class _StatisticsCard extends StatelessWidget {
  final int activeChallenges;
  final int completedChallenges;

  const _StatisticsCard({
    required this.activeChallenges,
    required this.completedChallenges,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'アクティブ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '$activeChallenges',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '完了',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '$completedChallenges',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '総計',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '${activeChallenges + completedChallenges}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
