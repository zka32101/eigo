import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../design_system/design_system.dart';
import '../providers/pet_provider.dart';
import '../providers/user_profile_provider.dart';
import 'pet_interaction_screen.dart';

/// ペットステータス画面
class PetStatusScreen extends ConsumerWidget {
  const PetStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final currentPet = ref.watch(currentPetProvider);

    if (currentPet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🐾 ペットステータス'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ペットを作成してください',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalSpacerMd,
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final userRankAsync = ref.watch(userPetRankProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text('🐾 ${currentPet.nickname}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPetStats(context, ref, userId, currentPet),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            children: [
              // メインペット表示
              _PetMainCard(pet: currentPet),
              AppSpacing.verticalSpacerLg,

              // ステータスバー
              _DetailedStatusBars(pet: currentPet),
              AppSpacing.verticalSpacerLg,

              // 進化情報
              _EvolutionProgressCard(pet: currentPet),
              AppSpacing.verticalSpacerLg,

              // リーダーボード情報
              userRankAsync.when(
                data: (rank) {
                  if (rank != null) {
                    return _LeaderboardCard(rank: rank, petLevel: currentPet.level);
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalSpacerLg,

              // 学習統計
              _LearningStatsCard(pet: currentPet),
              AppSpacing.verticalSpacerLg,

              // アクションボタン
              _ActionButtons(pet: currentPet),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }

  void _showPetStats(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Pet pet,
  ) {
    final statsAsync = ref.watch(petStatsCloudProvider(userId));

    showModalBottomSheet(
      context: context,
      builder: (context) => statsAsync.when(
        data: (stats) => Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ペット統計',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,
              _StatItem('総ペット数', '${stats['totalPets']}'),
              _StatItem('最大レベル', '${stats['maxLevel']}'),
              _StatItem('給食回数', '${stats['totalFeeds']}'),
              _StatItem('遊んだ回数', '${stats['totalPlays']}'),
              _StatItem('学んだ単語', '${stats['learnedWords']}'),
              _StatItem('平均幸福度', '${stats['happiness']}'),
              _StatItem('平均満腹度', '${stats['satiety']}'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('エラーが発生しました'),
      ),
    );
  }
}

/// メインペット表示カード
class _PetMainCard extends StatelessWidget {
  final Pet pet;

  const _PetMainCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: AppSpacing.allPaddingLg,
          child: Column(
            children: [
              // ペット絵文字
              Text(
                pet.emoji,
                style: const TextStyle(fontSize: 100),
              ),
              AppSpacing.verticalSpacerMd,

              // 名前と情報
              Text(
                pet.nickname,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerSm,

              // 種族と進化段階
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text(pet.species.name),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Chip(
                    label: Text(pet.evolutionStageName),
                    backgroundColor: Colors.purple.withOpacity(0.2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 詳細ステータスバー
class _DetailedStatusBars extends StatelessWidget {
  final Pet pet;

  const _DetailedStatusBars({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // レベルと経験値
        Text(
          '⭐ レベル ${pet.level}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalSpacerSm,
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pet.experience / 100,
            minHeight: 12,
            backgroundColor: Colors.purple.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
        AppSpacing.verticalSpacerSm,
        Text(
          '経験値: ${pet.experience}/100 (次のレベルまで ${pet.experienceToNextLevel})',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppSpacing.verticalSpacerMd,

        // 満腹度
        _StatusBar(
          label: '🍖 満腹度',
          value: pet.satiety,
          max: 100,
          color: pet.satiety < 30 ? Colors.red : Colors.orange,
          status: pet.satietyStatus,
        ),
        AppSpacing.verticalSpacerMd,

        // 幸福度
        _StatusBar(
          label: '💕 幸福度',
          value: pet.happiness,
          max: 100,
          color: Colors.pink,
          status: pet.happinessStatus,
        ),
      ],
    );
  }
}

/// ステータスバー
class _StatusBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final String status;

  const _StatusBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value/$max - $status'),
          ],
        ),
        AppSpacing.verticalSpacerSm,
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / max,
            minHeight: 10,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// 進化プログレスカード
class _EvolutionProgressCard extends StatelessWidget {
  final Pet pet;

  const _EvolutionProgressCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final nextStage = _getNextEvolutionStage(pet.evolutionStage);
    final nextLevel = _getNextEvolutionLevel(pet.evolutionStage);

    return Card(
      color: Colors.amber.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌟 進化情報',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('現在の段階'),
                    Text(
                      pet.evolutionStageName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                    ),
                  ],
                ),
                if (nextStage != null && nextLevel != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('次の段階'),
                      Text(
                        nextStage,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('状態'),
                      Text(
                        '最高レベル',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
            if (nextStage != null && nextLevel != null) ...[
              AppSpacing.verticalSpacerMd,
              Text(
                'レベル$nextLevelに達すると進化します',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              AppSpacing.verticalSpacerSm,
              LinearProgressIndicator(
                value: pet.level / nextLevel,
                minHeight: 8,
                backgroundColor: Colors.amber.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                'あと${nextLevel - pet.level}レベル',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getNextEvolutionStage(EvolutionStage current) {
    switch (current) {
      case EvolutionStage.egg:
        return 'ベビー';
      case EvolutionStage.baby:
        return 'キッズ';
      case EvolutionStage.kids:
        return 'アダルト';
      case EvolutionStage.adult:
        return null;
    }
  }

  int? _getNextEvolutionLevel(EvolutionStage current) {
    switch (current) {
      case EvolutionStage.egg:
        return 10;
      case EvolutionStage.baby:
        return 25;
      case EvolutionStage.kids:
        return 40;
      case EvolutionStage.adult:
        return null;
    }
  }
}

/// リーダーボードカード
class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final int petLevel;

  const _LeaderboardCard({
    required this.rank,
    required this.petLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏆 リーダーボード',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('あなたの順位'),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      '$rank位',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('ペットレベル'),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      'Lv. $petLevel',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 学習統計カード
class _LearningStatsCard extends StatelessWidget {
  final Pet pet;

  const _LearningStatsCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📚 学習統計',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            _StatItem('学んだ単語', '${pet.learnedWords.length}個'),
            _StatItem('給食回数', '${pet.totalFeedsCount}回'),
            _StatItem('遊んだ回数', '${pet.totalPlayCount}回'),
            if (pet.learnedWords.isNotEmpty) ...[
              AppSpacing.verticalSpacerMd,
              Text(
                '最近学んだ単語:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              AppSpacing.verticalSpacerSm,
              Wrap(
                spacing: 8,
                children: pet.learnedWords.take(5).map((word) {
                  return Chip(
                    label: Text(word),
                    compact: true,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// アクションボタン
class _ActionButtons extends StatelessWidget {
  final Pet pet;

  const _ActionButtons({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetInteractionScreen(pet: pet),
                ),
              );
            },
            icon: const Icon(Icons.touch_app),
            label: const Text('お世話する'),
          ),
        ),
        AppSpacing.horizontalSpacerMd,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('手放す'),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ペットを手放しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete pet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('手放す'),
          ),
        ],
      ),
    );
  }
}

/// 統計アイテム
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
