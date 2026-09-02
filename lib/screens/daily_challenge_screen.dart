import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_challenge_model.dart';
import '../providers/daily_challenge_provider.dart';
import '../design_system/design_system.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysChallengeAsync = ref.watch(todaysChallengeProvider);
    final userAttempt = ref.watch(userTodaysAttemptProvider);
    final userStats = ref.watch(userChallengeStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 1日1フレーズチャレンジ'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: todaysChallengeAsync.when(
        data: (challenge) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge header with date and streak info
              _ChallengeHeader(challenge: challenge, userStats: userStats),
              
              // Today's phrase card
              _TodaysPhraseCard(challenge: challenge),
              
              // User's attempt section (if not completed)
              if (userAttempt == null)
                _AttemptSection(challenge: challenge)
              else
                _CompletedSection(attempt: userAttempt, challenge: challenge),
              
              AppSpacing.verticalSpacerLg,
              
              // Leaderboard section
              _LeaderboardSection(),
              
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

class _ChallengeHeader extends StatelessWidget {
  final DailyChallenge challenge;
  final ChallengeStat userStats;

  const _ChallengeHeader({
    required this.challenge,
    required this.userStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.releaseTime.month}月${challenge.releaseTime.day}日のチャレンジ',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textWhite.withOpacity(0.7),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '${userStats.consecutiveDays}日連続 🔥',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '統計',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textWhite.withOpacity(0.7),
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${userStats.totalAttempts}回参加',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ベストスコア',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textWhite.withOpacity(0.7),
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${userStats.bestScore}点',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodaysPhraseCard extends StatelessWidget {
  final DailyChallenge challenge;

  const _TodaysPhraseCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(color: AppColors.primary.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'フレーズ',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.verticalSpacerMd,
          
          // English phrase (large, prominent)
          Container(
            width: double.infinity,
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Text(
              challenge.phrase,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          
          // Pronunciation guide
          Row(
            children: [
              const Icon(Icons.volume_up, size: 20, color: AppColors.accentOrange),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Text(
                  challenge.phrasePronunciation,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          
          // Japanese meaning
          Row(
            children: [
              const Icon(Icons.translate, size: 20, color: AppColors.accentGreen),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Text(
                  challenge.phraseMeaning,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttemptSection extends ConsumerStatefulWidget {
  final DailyChallenge challenge;

  const _AttemptSection({required this.challenge});

  @override
  ConsumerState<_AttemptSection> createState() => _AttemptSectionState();
}

class _AttemptSectionState extends ConsumerState<_AttemptSection> {
  late TextEditingController _responseController;
  int _simulatedScore = 0;

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _submitAttempt() {
    // Simulate speech recognition score (in production, use speech_to_text)
    final userResponse = _responseController.text;
    if (userResponse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音声を入力してください')),
      );
      return;
    }

    // Simulate accuracy calculation
    final simulatedScore = (60 + (userResponse.length % 40)).clamp(0, 100).toInt();

    // Submit attempt
    ref.read(userTodaysAttemptProvider.notifier).submitAttempt(
      widget.challenge.challengeId,
      userResponse,
      simulatedScore,
      (simulatedScore / 100).toDouble(),
    );

    // Update user statistics
    ref.read(userChallengeStatsProvider.notifier).recordAttempt(simulatedScore);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$simulatedScore点を獲得しました！'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(10),
        border: Border.all(color: AppColors.accentGreen.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'あなたの発音を入力',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          AppSpacing.verticalSpacerMd,
          
          // Text input for speech recognition result
          TextField(
            controller: _responseController,
            decoration: InputDecoration(
              hintText: 'フレーズを入力してください',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              prefixIcon: const Icon(Icons.mic, color: AppColors.accentOrange),
              fillColor: AppColors.textWhite,
              filled: true,
            ),
          ),
          AppSpacing.verticalSpacerMd,
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitAttempt,
              icon: const Icon(Icons.check_circle),
              label: const Text('提出する'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.textWhite,
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedSection extends StatelessWidget {
  final ChallengeAttempt attempt;
  final DailyChallenge challenge;

  const _CompletedSection({
    required this.attempt,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(10),
        border: Border.all(color: AppColors.accentGreen),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '✅ 本日のチャレンジ完了！',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.accentGreen,
            ),
          ),
          AppSpacing.verticalSpacerLg,
          
          // Score display
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentGreen, AppColors.accentGreen.withAlpha(150)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Text(
                  '${attempt.scorePoints}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '点',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,
          
          // Reward info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('🪙', style: const TextStyle(fontSize: 32)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${attempt.scorePoints ~/ 10}',
                    style: AppTypography.labelLarge,
                  ),
                  Text('コイン', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
              Column(
                children: [
                  Text('⭐', style: const TextStyle(fontSize: 32)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${attempt.scorePoints ~/ 20}',
                    style: AppTypography.labelLarge,
                  ),
                  Text('XP', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
              Column(
                children: [
                  Text('🎁', style: const TextStyle(fontSize: 32)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '+1',
                    style: AppTypography.labelLarge,
                  ),
                  Text('ストリーク', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          
          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('スコアをシェアしました！')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('スコアをシェア'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(todaysChallengeLeaderboardProvider);

    return Container(
      margin: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 全国ランキング',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerMd,
          
          leaderboardAsync.when(
            data: (leaderboard) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return _LeaderboardCard(entry: entry);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('エラー: $err')),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final ChallengeLeaderboardEntry entry;

  const _LeaderboardCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(
          color: entry.rank <= 3 ? AppColors.accentOrange.withAlpha(50) : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Row(
        children: [
          // Rank with medal
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.rank <= 3 ? AppColors.accentOrange.withAlpha(30) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.rank <= 3 ? entry.medalEmoji : '${entry.rank}',
                style: TextStyle(
                  fontSize: entry.rank <= 3 ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalSpacerMd,
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '${entry.userRegion} • ${entry.userLevel}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Score
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
              '${entry.score}点',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
