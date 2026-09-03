import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../design_system/design_system.dart';
import 'challenge_completion_screen.dart';

/// チャレンジ詳細画面
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final SocialChallenge challenge;
  final String userId;

  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProgressAsync = ref.watch(
      userChallengeProgressProvider('${widget.userId}:${widget.challenge.id}'),
    );
    final leaderboardAsync = ref.watch(
      challengeLeaderboardProvider(widget.challenge.id),
    );
    final userRankAsync = ref.watch(
      userChallengeRankProvider('${widget.userId}:${widget.challenge.id}'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャレンジ詳細'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // チャレンジヘッダー
              Card(
                color: Colors.blue.withOpacity(0.1),
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
                                  widget.challenge.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                AppSpacing.verticalSpacerSm,
                                Text(
                                  widget.challenge.typeLabel,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Colors.blue,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.challenge.typeLabel.substring(0, 1),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpacerMd,
                      Text(
                        widget.challenge.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      AppSpacing.verticalSpacerMd,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '終了まで',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              Text(
                                widget.challenge.daysRemaining,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '参加者',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              Text(
                                '${widget.challenge.currentParticipants}名',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // ユーザーの進捗セクション
              userProgressAsync.when(
                data: (userProgress) {
                  if (userProgress == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '未参加',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.verticalSpacerMd,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(joinChallengeActionProvider(
                                JoinChallengeParams(
                                  userId: widget.userId,
                                  challengeId: widget.challenge.id,
                                ),
                              ));
                            },
                            child: const Text('このチャレンジに参加する'),
                          ),
                        ),
                        AppSpacing.verticalSpacerLg,
                      ],
                    );
                  }

                  final percentage = (userProgress.progress / widget.challenge.goalValue * 100)
                      .clamp(0.0, 100.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'あなたの進捗',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSpacerMd,
                      Card(
                        child: Padding(
                          padding: AppSpacing.allPaddingMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${userProgress.progress}/${widget.challenge.goalValue}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                  ),
                                ],
                              ),
                              AppSpacing.verticalSpacerMd,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    userProgress.isCompleted ? Colors.green : Colors.blue,
                                  ),
                                ),
                              ),
                              AppSpacing.verticalSpacerMd,
                              if (userProgress.isCompleted)
                                Container(
                                  width: double.infinity,
                                  padding: AppSpacing.allPaddingMd,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '✅ チャレンジ完了！報酬を受け取ります。',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Colors.green,
                                        ),
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '参加日時: ${userProgress.joinedAt.year}年${userProgress.joinedAt.month}月${userProgress.joinedAt.day}日',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(updateChallengeProgressActionProvider(
                                          UpdateChallengeProgressParams(
                                            userId: widget.userId,
                                            challengeId: widget.challenge.id,
                                            progress: userProgress.progress + 1,
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
                      ),
                      AppSpacing.verticalSpacerLg,
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 報酬セクション
              Text(
                '報酬',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              Column(
                children: [
                  if (widget.challenge.firstPlacePrize != null)
                    _PrizeCard(
                      rank: '1位',
                      prize: widget.challenge.firstPlacePrize!,
                      icon: '🥇',
                    ),
                  if (widget.challenge.secondPlacePrize != null) ...[
                    AppSpacing.verticalSpacerSm,
                    _PrizeCard(
                      rank: '2位',
                      prize: widget.challenge.secondPlacePrize!,
                      icon: '🥈',
                    ),
                  ],
                  if (widget.challenge.thirdPlacePrize != null) ...[
                    AppSpacing.verticalSpacerSm,
                    _PrizeCard(
                      rank: '3位',
                      prize: widget.challenge.thirdPlacePrize!,
                      icon: '🥉',
                    ),
                  ],
                ],
              ),
              AppSpacing.verticalSpacerLg,

              // ランキングセクション
              Text(
                'ランキング',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              userRankAsync.when(
                data: (userRank) {
                  if (userRank != null) {
                    return Card(
                      color: Colors.amber.withOpacity(0.1),
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'あなたの順位',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  '$userRank位',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                ),
                              ],
                            ),
                            if (userRank == 1)
                              Text('🥇', style: Theme.of(context).textTheme.headlineLarge)
                            else if (userRank == 2)
                              Text('🥈', style: Theme.of(context).textTheme.headlineLarge)
                            else if (userRank == 3)
                              Text('🥉', style: Theme.of(context).textTheme.headlineLarge)
                            else
                              Text('🎖️', style: Theme.of(context).textTheme.headlineLarge),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerMd,
              leaderboardAsync.when(
                data: (leaderboard) {
                  if (leaderboard.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Center(
                          child: Text(
                            'ランキングデータはまだありません',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'トップ10',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSpacerMd,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaderboard.take(10).length,
                        itemBuilder: (context, index) {
                          final entry = leaderboard[index];
                          final rank = index + 1;
                          final isCurrentUser = entry['userId'] == widget.userId;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: AppSpacing.allPaddingMd,
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentUser
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$rank',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: rank == 1
                                            ? Colors.amber
                                            : rank == 2
                                                ? Colors.grey[400]
                                                : rank == 3
                                                    ? Colors.orange[300]
                                                    : Colors.grey,
                                      ),
                                ),
                                AppSpacing.horizontalSpacerMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isCurrentUser ? 'あなた' : 'ユーザー $rank',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      AppSpacing.verticalSpacerSm,
                                      Text(
                                        '進捗: ${entry['progress']}/${widget.challenge.goalValue}',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.grey,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(entry['progress'] / widget.challenge.goalValue * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
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

/// 順位別報酬カード
class _PrizeCard extends StatelessWidget {
  final String rank;
  final int prize;
  final String icon;

  const _PrizeCard({
    required this.rank,
    required this.prize,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            AppSpacing.horizontalSpacerMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '報酬: $prize XP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
