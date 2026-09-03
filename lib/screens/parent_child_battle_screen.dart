import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parent_child_battle_model.dart';
import '../providers/parent_child_battle_provider.dart';
import '../design_system/design_system.dart';

class ParentChildBattleScreen extends ConsumerWidget {
  const ParentChildBattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBattle = ref.watch(currentParentChildBattleProvider);
    final leaderboard = ref.watch(weeklyFamilyLeagueProvider);
    final pass = ref.watch(parentBattlePassProvider);
    final achievements = ref.watch(familyBattleAchievementsProvider);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👨‍👩‍👧‍👦 親子発音バトル'),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            isScrollable: true,
            tabs: const [
              Tab(text: 'バトル'),
              Tab(text: 'ランキング'),
              Tab(text: 'パス'),
              Tab(text: '戦績'),
              Tab(text: '🏆 称号'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Battle tab
            _BattleTab(),
            // Leaderboard tab
            _LeaderboardTab(leaderboard: leaderboard),
            // Pass tab
            _PassTab(pass: pass),
            // History tab
            _HistoryTab(),
            // Achievements tab
            _AchievementsTab(achievements: achievements),
          ],
        ),
      ),
    );
  }
}

/// === Battle Tab ===
class _BattleTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BattleTab> createState() => _BattleTabState();
}

class _BattleTabState extends ConsumerState<_BattleTab> {
  @override
  void initState() {
    super.initState();
    _initializeBattle();
  }

  Future<void> _initializeBattle() async {
    final battle = ref.read(currentParentChildBattleProvider);
    if (battle == null) {
      // Start new battle
      ref.read(currentParentChildBattleProvider.notifier).startBattle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final battle = ref.watch(currentParentChildBattleProvider);

    if (battle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          AppSpacing.verticalSpacerMd,

          // Family info header
          _BattleHeader(battle: battle),
          AppSpacing.verticalSpacerLg,

          // Duo mode battle interface
          if (battle.rounds.isEmpty)
            _BattleSetupSection(battle: battle)
          else
            _DuoBattleInterface(battle: battle),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _BattleHeader extends StatelessWidget {
  final ParentChildBattle battle;

  const _BattleHeader({required this.battle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本日の親子バトル',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          AppSpacing.verticalSpacerMd,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👨 ${battle.parentName}',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${battle.parentScore}点',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                  'VS',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '👧 ${battle.childName}',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${battle.childScore}点',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
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

class _BattleSetupSection extends ConsumerWidget {
  final ParentChildBattle battle;

  const _BattleSetupSection({required this.battle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(10),
        border: Border.all(color: AppColors.accentGreen.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'バトル開始準備',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerMd,

          // Phrase display
          Container(
            width: double.infinity,
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Column(
              children: [
                Text(
                  'チャレンジフレーズ',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  battle.phrase,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  battle.phraseMeaning,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // Instructions
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 バトルのルール',
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '1. 親が最初に発音します\n2. 子がその後に発音します\n3. 各自のスコアを比較します\n4. より高いスコアの方が勝利！',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(currentParentChildBattleProvider.notifier).completeRound(
                  parentResponse: 'ready',
                  parentScore: 0,
                  childResponse: 'ready',
                  childScore: 0,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('バトル開始！親から始まります')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('バトル開始'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.textWhite,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuoBattleInterface extends ConsumerStatefulWidget {
  final ParentChildBattle battle;

  const _DuoBattleInterface({required this.battle});

  @override
  ConsumerState<_DuoBattleInterface> createState() => _DuoBattleInterfaceState();
}

class _DuoBattleInterfaceState extends ConsumerState<_DuoBattleInterface> {
  int _currentTurn = 0; // 0 = parent, 1 = child
  int _parentScore = 0;
  int _childScore = 0;
  bool _battleComplete = false;

  void _simulateVoiceCapture() {
    // Simulate voice recognition
    final simulatedScore = (60 + (DateTime.now().millisecond % 40)).clamp(0, 100).toInt();

    setState(() {
      if (_currentTurn == 0) {
        _parentScore = simulatedScore;
        _currentTurn = 1;
      } else {
        _childScore = simulatedScore;
        _battleComplete = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('スコア: $simulatedScore点 🎤')),
    );
  }

  void _finalizeBattle() {
    final winner = _parentScore > _childScore
        ? 'parent'
        : _childScore > _parentScore
            ? 'child'
            : 'tie';

    ref.read(currentParentChildBattleProvider.notifier).completeBattle(
      winner: winner,
      parentScore: _parentScore,
      childScore: _childScore,
    );

    ref.read(familyBattleStatsProvider.notifier).recordBattle(
      ParentChildBattle(
        battleId: 'battle_${DateTime.now().millisecondsSinceEpoch}',
        parentId: 'parent_123',
        childId: 'child_123',
        parentName: widget.battle.parentName,
        childName: widget.battle.childName,
        phrase: widget.battle.phrase,
        phraseMeaning: widget.battle.phraseMeaning,
        parentScore: _parentScore,
        childScore: _childScore,
        rounds: [],
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        winner: winner,
        parentCoinsEarned: _parentScore ~/ 10,
        childCoinsEarned: _childScore ~/ 10,
      ),
    );
  }

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
        children: [
          // Current turn indicator
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: _currentTurn == 0 ? AppColors.readingColor.withAlpha(25) : AppColors.accentPink.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Center(
              child: Text(
                _currentTurn == 0
                    ? '👨 ${widget.battle.parentName}のターン'
                    : '👧 ${widget.battle.childName}のターン',
                style: AppTypography.headlineSmall.copyWith(
                  color: _currentTurn == 0 ? AppColors.readingColor : AppColors.accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // Phrase reminder
          Text(
            widget.battle.phrase,
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          AppSpacing.verticalSpacerMd,

          if (!_battleComplete) ...[
            // Microphone button
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _currentTurn == 0
                      ? [AppColors.readingColor.withAlpha(150), AppColors.readingColor]
                      : [AppColors.accentPink.withAlpha(150), AppColors.accentPink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_currentTurn == 0 ? AppColors.readingColor : AppColors.accentPink)
                        .withAlpha(100),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _simulateVoiceCapture,
                  borderRadius: BorderRadius.circular(60),
                  child: Center(
                    child: Icon(
                      Icons.mic,
                      size: 60,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              'タップして発音',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ] else ...[
            // Results
            _BattleResultDisplay(
              parentScore: _parentScore,
              parentName: widget.battle.parentName,
              childScore: _childScore,
              childName: widget.battle.childName,
            ),
            AppSpacing.verticalSpacerLg,

            // Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _finalizeBattle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('バトル完了！')),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('バトルを終了'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.textWhite,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BattleResultDisplay extends StatelessWidget {
  final int parentScore;
  final String parentName;
  final int childScore;
  final String childName;

  const _BattleResultDisplay({
    required this.parentScore,
    required this.parentName,
    required this.childScore,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    final parentWins = parentScore > childScore;
    final childWins = childScore > parentScore;
    final isTie = parentScore == childScore;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Parent score
            Container(
              padding: AppSpacing.allPaddingMd,
              decoration: BoxDecoration(
                color: parentWins ? AppColors.readingColor.withAlpha(25) : AppColors.bgLight.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Column(
                children: [
                  Text(
                    '👨',
                    style: TextStyle(fontSize: AppTypography.displayMedium.fontSize! * 1.43),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    parentName,
                    style: AppTypography.labelSmall,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    '$parentScore点',
                    style: AppTypography.headlineSmall.copyWith(
                      color: parentWins ? AppColors.readingColor : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (parentWins)
                    Chip(
                      label: const Text('勝利！'),
                      backgroundColor: AppColors.readingColor.withAlpha(50),
                    ),
                ],
              ),
            ),

            // Tie indicator
            if (isTie)
              Column(
                children: [
                  const Text('=', style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
                  AppSpacing.verticalSpacerMd,
                  const Chip(
                    label: Text('同点'),
                    backgroundColor: AppColors.accentOrange,
                  ),
                ],
              ),

            // Child score
            Container(
              padding: AppSpacing.allPaddingMd,
              decoration: BoxDecoration(
                color: childWins ? AppColors.accentPink.withAlpha(25) : AppColors.bgLight.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Column(
                children: [
                  Text(
                    '👧',
                    style: TextStyle(fontSize: AppTypography.displayMedium.fontSize! * 1.43),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    childName,
                    style: AppTypography.labelSmall,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    '$childScore点',
                    style: AppTypography.headlineSmall.copyWith(
                      color: childWins ? AppColors.accentPink : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (childWins)
                    Chip(
                      label: const Text('勝利！'),
                      backgroundColor: AppColors.accentPink.withAlpha(50),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// === Leaderboard Tab ===
class _LeaderboardTab extends ConsumerWidget {
  final AsyncValue<WeeklyFamilyLeague?> leaderboard;

  const _LeaderboardTab({required this.leaderboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return leaderboard.when(
      data: (league) => league == null
          ? Center(child: Text('リーグデータはまだ利用できません'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League header
                  Container(
                    margin: AppSpacing.allPaddingLg,
                    padding: AppSpacing.allPaddingLg,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentOrange, AppColors.accentOrange.withAlpha(150)],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📅 週間ファミリーリーグ',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                        AppSpacing.verticalSpacerMd,
                        Text(
                          'Week ${league.weekNumber} (${league.startDate.month}/${league.startDate.day} - ${league.endDate.month}/${league.endDate.day})',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textWhite.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Leaderboard entries
                  ...league.standings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final standing = entry.value;
                    return _FamilyLeagueCard(
                      rank: index + 1,
                      entry: standing,
                    );
                  }).toList(),

                  AppSpacing.verticalSpacerXxl,
                ],
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('エラー: $err')),
    );
  }
}

class _FamilyLeagueCard extends StatelessWidget {
  final int rank;
  final FamilyLeagueEntry entry;

  const _FamilyLeagueCard({
    required this.rank,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: isTopThree ? AppColors.accentOrange.withAlpha(25) : AppColors.textWhite,
        border: Border.all(
          color: isTopThree ? AppColors.accentOrange.withAlpha(50) : AppColors.bgLight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank and names
          Row(
            children: [
              // Medal/Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isTopThree ? AppColors.accentOrange.withAlpha(30) : AppColors.bgLight.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isTopThree ? medals[rank - 1] : '$rank',
                    style: TextStyle(
                      fontSize: isTopThree ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpacerMd,

              // Family info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👨‍👩‍👧‍👦 ${entry.parentName} 家',
                      style: AppTypography.labelLarge,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      '親: ${entry.parentName} • 子: ${entry.childName}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Points
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
                  '${entry.weeklyPoints}pt',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('🎮', style: TextStyle(fontSize: AppTypography.displaySmall.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${entry.weeklyBattles}',
                    style: AppTypography.labelMedium,
                  ),
                  Text('対戦', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
              Column(
                children: [
                  Text('🏆', style: TextStyle(fontSize: AppTypography.displaySmall.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${entry.weeklyWins}',
                    style: AppTypography.labelMedium,
                  ),
                  Text('勝利', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
              Column(
                children: [
                  Text('📊', style: TextStyle(fontSize: AppTypography.displaySmall.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${(entry.winRate * 100).toStringAsFixed(0)}%',
                    style: AppTypography.labelMedium,
                  ),
                  Text('勝率', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// === Pass Tab ===
class _PassTab extends ConsumerWidget {
  final AsyncValue<ParentBattlePass?> pass;

  const _PassTab({required this.pass});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpacerMd,

          // Current pass status
          pass.when(
            data: (currentPass) => currentPass != null
                ? _ActivePassCard(pass: currentPass)
                : const SizedBox(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => SizedBox(),
          ),

          AppSpacing.verticalSpacerLg,

          // Pass offers
          _PassOfferCard(
            title: '週間無制限バトル',
            description: '1週間、親子バトルが無制限に楽しめます',
            price: '200コイン',
            benefits: ['毎日親子バトルOK', 'スコア×2ボーナス', 'リプレイ無制限'],
            icon: '⭐',
            onTap: () {
              ref.read(parentBattlePassProvider.notifier).purchasePass(
                'weekly_unlimited',
                200,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('週間パスを購入しました！')),
              );
            },
          ),
          AppSpacing.verticalSpacerMd,

          _PassOfferCard(
            title: '月間無制限バトル',
            description: '1ヶ月間、親子バトルが無制限に楽しめます',
            price: '500コイン',
            benefits: ['毎日親子バトルOK', 'スコア×3ボーナス', 'リプレイ無制限', '専用ペット装飾品'],
            icon: '👑',
            onTap: () {
              ref.read(parentBattlePassProvider.notifier).purchasePass(
                'monthly_unlimited',
                500,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('月間パスを購入しました！')),
              );
            },
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _ActivePassCard extends StatelessWidget {
  final ParentBattlePass pass;

  const _ActivePassCard({required this.pass});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = pass.expiresAt.difference(DateTime.now()).inDays;

    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentGreen, AppColors.accentGreen.withAlpha(150)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ アクティブなパス',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
          ),
          AppSpacing.verticalSpacerMd,

          Text(
            pass.passType == 'weekly_unlimited' ? '📅 週間無制限' : '📆 月間無制限',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
          ),
          AppSpacing.verticalSpacerSm,

          Text(
            'あと $daysRemaining 日で期限切れ',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _PassOfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final List<String> benefits;
  final String icon;
  final VoidCallback onTap;

  const _PassOfferCard({
    required this.title,
    required this.description,
    required this.price,
    required this.benefits,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(color: AppColors.primary.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // Benefits
          ...benefits.map((benefit) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                const Text('✓ ', style: TextStyle(color: AppColors.accentGreen)),
                Text(
                  benefit,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          )).toList(),

          AppSpacing.verticalSpacerMd,

          // Price and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  price,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('購入'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// === History Tab ===
class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(parentChildBattleHistoryProvider);
    final stats = ref.watch(familyBattleStatsProvider);

    return history.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📋 まだバトル履歴がありません'),
                AppSpacing.verticalSpacerMd,
                const Text('親子でバトルを開始してみましょう！'),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats header
                _BattleStatsHeader(stats: stats),
                AppSpacing.verticalSpacerLg,

                // History list
                Container(
                  margin: AppSpacing.allPaddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 最近のバトル',
                        style: AppTypography.headlineSmall,
                      ),
                      AppSpacing.verticalSpacerMd,

                      ...history.take(10).map((battle) {
                        final parentWins = battle.parentScore > battle.childScore;
                        return _BattleHistoryCard(
                          battle: battle,
                          parentWins: parentWins,
                        );
                      }).toList(),
                    ],
                  ),
                ),

                AppSpacing.verticalSpacerXxl,
              ],
            ),
          );
  }
}

class _BattleStatsHeader extends StatelessWidget {
  final ParentChildBattleStats stats;

  const _BattleStatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(150)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 バトル統計',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
          ),
          AppSpacing.verticalSpacerMd,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('🎮', style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.totalBattles}',
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
                  ),
                  Text('総対戦', style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7))),
                ],
              ),
              Column(
                children: [
                  Text('👨', style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.parentWins}',
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
                  ),
                  Text('親の勝利', style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7))),
                ],
              ),
              Column(
                children: [
                  Text('👧', style: TextStyle(fontSize: AppTypography.displayMedium.fontSize)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.childWins}',
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.textWhite),
                  ),
                  Text('子の勝利', style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BattleHistoryCard extends StatelessWidget {
  final ParentChildBattle battle;
  final bool parentWins;

  const _BattleHistoryCard({
    required this.battle,
    required this.parentWins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(
          color: parentWins ? AppColors.readingColor.withAlpha(150) : AppColors.accentPink.withAlpha(150),
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Row(
        children: [
          // Winner indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: parentWins ? AppColors.readingColor.withAlpha(25) : AppColors.accentPink.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                parentWins ? '👨' : '👧',
                style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
              ),
            ),
          ),
          AppSpacing.horizontalSpacerMd,

          // Battle info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  battle.phrase,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '${battle.parentName} vs ${battle.childName}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
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
              '${battle.parentScore} - ${battle.childScore}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// === Achievements Tab ===
class _AchievementsTab extends ConsumerWidget {
  final AsyncValue<List<FamilyBattleAchievement>> achievements;

  const _AchievementsTab({required this.achievements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return achievements.when(
      data: (achievementList) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSpacerMd,

            ...achievementList.map((achievement) {
              return _AchievementCard(achievement: achievement);
            }).toList(),

            AppSpacing.verticalSpacerXxl,
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('エラー: $err')),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final FamilyBattleAchievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final progress = achievement.targetCount > 0
        ? (achievement.currentCount / achievement.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.accentOrange.withAlpha(25) : AppColors.bgLight.withAlpha(25),
        border: Border.all(
          color: isUnlocked ? AppColors.accentOrange : AppColors.bgLight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                achievement.icon,
                style: TextStyle(fontSize: AppTypography.displayMedium.fontSize! * 1.43),
              ),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      achievement.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: isUnlocked ? AppColors.textMuted : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (isUnlocked)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  ),
                  child: Text(
                    '${achievement.rewardCoins}🪙',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? AppColors.accentOrange : AppColors.primary,
              ),
            ),
          ),
          AppSpacing.verticalSpacerSm,

          Text(
            '${achievement.currentCount}/${achievement.targetCount}',
            style: AppTypography.bodySmall.copyWith(
              color: isUnlocked ? AppColors.accentGreen : AppColors.textMuted,
            ),
          ),

          if (isUnlocked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.verticalSpacerSm,
                Text(
                  '✅ 獲得済み',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
