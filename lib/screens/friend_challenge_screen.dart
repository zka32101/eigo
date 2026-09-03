import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

/// フレンドチャレンジ画面
class FriendChallengeScreen extends ConsumerWidget {
  const FriendChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final friendChallengesAsync = ref.watch(userFriendChallengesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 フレンドチャレンジ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 新規チャレンジ作成ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCreateChallengeDialog(context, ref, userId);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('友達にチャレンジを仕掛ける'),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // フレンドチャレンジリスト
              Text(
                'アクティブなフレンドチャレンジ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              friendChallengesAsync.when(
                data: (challenges) {
                  final activeChallenges = challenges.where((c) => !c.isCompleted).toList();

                  if (activeChallenges.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Center(
                          child: Text(
                            'アクティブなフレンドチャレンジはありません',
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
                    itemCount: activeChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = activeChallenges[index];
                      final isInitiator = challenge.initiatorId == userId;

                      return _FriendChallengeCard(
                        challenge: challenge,
                        userId: userId,
                        isInitiator: isInitiator,
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

              // 完了したチャレンジ
              Text(
                '完了したフレンドチャレンジ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              friendChallengesAsync.when(
                data: (challenges) {
                  final completedChallenges = challenges.where((c) => c.isCompleted).toList();

                  if (completedChallenges.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Center(
                          child: Text(
                            'まだ完了したフレンドチャレンジはありません',
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
                    itemCount: completedChallenges.take(5).length,
                    itemBuilder: (context, index) {
                      final challenge = completedChallenges[index];
                      return _CompletedFriendChallengeCard(
                        challenge: challenge,
                        userId: userId,
                      );
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

  void _showCreateChallengeDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    String friendId = '';
    String description = '';
    int targetValue = 10;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいフレンドチャレンジ'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'フレンドID',
                      hintText: 'friend_user_id',
                    ),
                    onChanged: (value) => friendId = value,
                  ),
                  AppSpacing.verticalSpacerMd,
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'チャレンジの説明',
                      hintText: 'このチャレンジの内容を入力',
                    ),
                    onChanged: (value) => description = value,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '目標値',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            targetValue = int.tryParse(value) ?? 10;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (friendId.isNotEmpty && description.isNotEmpty) {
                  ref.read(createFriendChallengeActionProvider(
                    CreateFriendChallengeParams(
                      userId: userId,
                      friendId: friendId,
                      description: description,
                      targetValue: targetValue,
                    ),
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('チャレンジを作成しました！'),
                    ),
                  );
                }
              },
              child: const Text('作成'),
            ),
          ],
        );
      },
    );
  }
}

/// フレンドチャレンジカード
class _FriendChallengeCard extends ConsumerWidget {
  final FriendChallenge challenge;
  final String userId;
  final bool isInitiator;

  const _FriendChallengeCard({
    required this.challenge,
    required this.userId,
    required this.isInitiator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLeader = challenge.currentLeader;
    final isCurrentUserLeading = currentLeader == userId;
    final leadAmount = challenge.leadAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCurrentUserLeading ? Colors.blue.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,

            // プレイヤー比較
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _PlayerProgress(
                    name: isInitiator ? 'あなた' : '相手',
                    progress: challenge.initiatorProgress,
                    targetValue: challenge.targetValue,
                    isLeading: challenge.currentLeader == challenge.initiatorId,
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                Center(
                  child: Column(
                    children: [
                      Text(
                        'VS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (leadAmount > 0)
                        Text(
                          '+$leadAmount',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                              ),
                        ),
                    ],
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: _PlayerProgress(
                    name: isInitiator ? '相手' : 'あなた',
                    progress: challenge.opponentProgress,
                    targetValue: challenge.targetValue,
                    isLeading: challenge.currentLeader == challenge.opponentId,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // 進捗バー
            _ComparisonProgressBar(
              initiatorProgress: challenge.initiatorProgress,
              opponentProgress: challenge.opponentProgress,
              targetValue: challenge.targetValue,
            ),
            AppSpacing.verticalSpacerMd,

            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目標: ${challenge.targetValue}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(updateFriendChallengeProgressActionProvider(
                      UpdateFriendChallengeProgressParams(
                        challengeId: challenge.id,
                        userId: userId,
                        progress: (isInitiator ? challenge.initiatorProgress : challenge.opponentProgress) + 1,
                      ),
                    ));
                  },
                  child: const Text('進捗を更新'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 完了したフレンドチャレンジカード
class _CompletedFriendChallengeCard extends StatelessWidget {
  final FriendChallenge challenge;
  final String userId;

  const _CompletedFriendChallengeCard({
    required this.challenge,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = challenge.winnerId == userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isWinner ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.description,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSpacerSm,
                      Text(
                        '${challenge.initiatorProgress} vs ${challenge.opponentProgress}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                if (isWinner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🏆 勝利',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚔️ 敗北',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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

/// プレイヤープログレス
class _PlayerProgress extends StatelessWidget {
  final String name;
  final int progress;
  final int targetValue;
  final bool isLeading;

  const _PlayerProgress({
    required this.name,
    required this.progress,
    required this.targetValue,
    required this.isLeading,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress / targetValue * 100).clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLeading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '🎖️ リード',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        AppSpacing.verticalSpacerSm,
        Text(
          name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalSpacerSm,
        Text(
          '$progress/$targetValue',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalSpacerSm,
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.blue,
              ),
        ),
      ],
    );
  }
}

/// 比較プログレスバー
class _ComparisonProgressBar extends StatelessWidget {
  final int initiatorProgress;
  final int opponentProgress;
  final int targetValue;

  const _ComparisonProgressBar({
    required this.initiatorProgress,
    required this.opponentProgress,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    final initiatorPercent = (initiatorProgress / targetValue * 100).clamp(0.0, 100.0);
    final opponentPercent = (opponentProgress / targetValue * 100).clamp(0.0, 100.0);

    return Column(
      children: [
        // Initiator bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: initiatorPercent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        AppSpacing.verticalSpacerSm,

        // Opponent bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: opponentPercent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ],
    );
  }
}
