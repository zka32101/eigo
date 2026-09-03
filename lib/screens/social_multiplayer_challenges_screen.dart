import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../models/english_town_social_model.dart';
import '../providers/english_town_social_provider.dart';

/// Multiplayer challenges screen
class SocialMultiplayerChallengesScreen extends ConsumerWidget {
  const SocialMultiplayerChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChallenges = ref.watch(activeChallengesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 チャレンジ'),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              const Tab(text: '進行中'),
              const Tab(text: '完了'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active challenges
            activeChallenges.when(
              data: (challenges) => challenges.isEmpty
                  ? _EmptyState()
                  : _ActiveChallengesList(challenges: challenges),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラー: $error'),
              ),
            ),
            // Completed challenges
            const _CompletedChallengesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showCreateChallengeDialog(context, ref);
          },
          icon: const Icon(Icons.add),
          label: const Text('新規作成'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _CreateChallengeDialog(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports,
            size: 64,
            color: AppColors.textMuted,
          ),
          AppSpacing.verticalSpacerMd,
          const Text('進行中のチャレンジはありません'),
          AppSpacing.verticalSpacerLg,
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create challenge
            },
            icon: const Icon(Icons.add),
            label: const Text('新規作成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChallengesList extends StatelessWidget {
  final List<MultiplayerChallenge> challenges;

  const _ActiveChallengesList({required this.challenges});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: challenges.length + 1,
      itemBuilder: (context, index) {
        if (index == challenges.length) {
          return SizedBox(height: AppSpacing.xxl);
        }
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: _ChallengeCard(challenge: challenges[index]),
        );
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final MultiplayerChallenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final timeRemaining = challenge.timeRemaining;
    final daysRemaining = timeRemaining.inDays;
    final hoursRemaining = timeRemaining.inHours % 24;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _ChallengeDetailScreen(
              challenge: challenge,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          border: Border.all(color: AppColors.bgLight),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: AppTypography.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalSpacerSm,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadiusSmall,
                          ),
                        ),
                        child: Text(
                          _objectiveLabel(challenge.objective),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Time remaining badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusSmall,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '⏱️',
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        '${daysRemaining}d ${hoursRemaining}h',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // Progress bar
            _ProgressBar(challenge: challenge),
            AppSpacing.verticalSpacerMd,

            // Participants info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    AppSpacing.horizontalSpacerSm,
                    Text(
                      '参加者: ${challenge.participantIds.length}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '目標: ${challenge.targetValue}',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _objectiveLabel(ChallengeObjective objective) {
    switch (objective) {
      case ChallengeObjective.totalConversations:
        return '💬 会話';
      case ChallengeObjective.totalXp:
        return '⭐ XP';
      case ChallengeObjective.totalCoins:
        return '💰 コイン';
      case ChallengeObjective.consecutiveDays:
        return '🔥 連続日数';
      case ChallengeObjective.uniqueNpcs:
        return '👥 NPC数';
      case ChallengeObjective.uniqueLocations:
        return '🗺️ 場所数';
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final MultiplayerChallenge challenge;

  const _ProgressBar({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final userProgress = challenge.participantProgress.values.fold<int>(
      0,
      (prev, current) => prev + current,
    );
    final totalNeeded = challenge.targetValue * challenge.participantIds.length;
    final percentage = (userProgress / totalNeeded).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '全体進捗',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpacerSm,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.bgLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.7 ? AppColors.accentGreen : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedChallengesTab extends ConsumerWidget {
  const _CompletedChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: AppColors.accentGreen,
          ),
          AppSpacing.verticalSpacerMd,
          const Text('完了したチャレンジはまだありません'),
        ],
      ),
    );
  }
}

class _ChallengeDetailScreen extends ConsumerWidget {
  final MultiplayerChallenge challenge;

  const _ChallengeDetailScreen({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.description,
                    style: AppTypography.bodyMedium,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '目標',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            challenge.targetValue.toString(),
                            style: AppTypography.headlineMedium,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '参加者',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${challenge.participantIds.length}人',
                            style: AppTypography.headlineMedium,
                          ),
                        ],
                      ),
                      if (challenge.prizePool != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'プール',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              challenge.prizePool!,
                              style: AppTypography.headlineMedium,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpacerLg,

            // Leaderboard
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏅 ランキング',
                    style: AppTypography.headlineSmall,
                  ),
                  AppSpacing.verticalSpacerMd,
                  ..._buildLeaderboard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeaderboard() {
    // Sort by progress
    final sorted = challenge.participantIds.toList()
      ..sort((a, b) {
        final progressA = challenge.participantProgress[a] ?? 0;
        final progressB = challenge.participantProgress[b] ?? 0;
        return progressB.compareTo(progressA);
      });

    return sorted.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final userId = entry.value;
      final progress = challenge.participantProgress[userId] ?? 0;

      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: rank == 1
                ? AppColors.accentOrange.withAlpha(20)
                : AppColors.bgLight,
            border: Border.all(
              color: rank == 1
                  ? AppColors.accentOrange.withAlpha(50)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rank == 1
                      ? AppColors.accentOrange
                      : AppColors.primary.withAlpha(50),
                ),
                child: Center(
                  child: Text(
                    rank == 1 ? '👑' : '$rank',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: rank == 1 ? AppColors.textWhite : AppColors.primary,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userId,
                      style: AppTypography.labelLarge,
                    ),
                    AppSpacing.verticalSpacerXs,
                    LinearProgressIndicator(
                      value: (progress / challenge.targetValue).clamp(0.0, 1.0),
                      backgroundColor: AppColors.bgLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= challenge.targetValue
                            ? AppColors.accentGreen
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              Text(
                '$progress/${challenge.targetValue}',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      );
    }).toList();
  }
}

class _CreateChallengeDialog extends StatefulWidget {
  const _CreateChallengeDialog();

  @override
  State<_CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends State<_CreateChallengeDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetController;
  ChallengeObjective _selectedObjective = ChallengeObjective.totalConversations;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新規チャレンジ作成'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: 'チャレンジの名前',
              ),
            ),
            AppSpacing.verticalSpacerMd,
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: 'チャレンジの説明',
              ),
              maxLines: 3,
            ),
            AppSpacing.verticalSpacerMd,
            DropdownButtonFormField<ChallengeObjective>(
              value: _selectedObjective,
              decoration: const InputDecoration(labelText: '目標タイプ'),
              items: ChallengeObjective.values.map((objective) {
                return DropdownMenuItem(
                  value: objective,
                  child: Text(_objectiveLabel(objective)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedObjective = value);
                }
              },
            ),
            AppSpacing.verticalSpacerMd,
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: '目標値',
                hintText: '例: 10',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            // Create challenge
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('チャレンジが作成されました')),
            );
          },
          child: const Text('作成'),
        ),
      ],
    );
  }

  String _objectiveLabel(ChallengeObjective objective) {
    switch (objective) {
      case ChallengeObjective.totalConversations:
        return '💬 会話';
      case ChallengeObjective.totalXp:
        return '⭐ XP';
      case ChallengeObjective.totalCoins:
        return '💰 コイン';
      case ChallengeObjective.consecutiveDays:
        return '🔥 連続日数';
      case ChallengeObjective.uniqueNpcs:
        return '👥 NPC数';
      case ChallengeObjective.uniqueLocations:
        return '🗺️ 場所数';
    }
  }
}
