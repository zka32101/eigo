import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../providers/user_profile_provider.dart';

class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen> {
  @override
  void initState() {
    super.initState();
    _initializePetIfNeeded();
  }

  Future<void> _initializePetIfNeeded() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final pet = ref.read(petProvider(userId)).value;
    if (pet == null) {
      // ペット未作成：選択画面へ
      if (mounted) {
        _showPetSelectionDialog();
      }
    }
  }

  void _showPetSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PetSelectionDialog(onSelected: _createPet),
    );
  }

  Future<void> _createPet(PetSpecies species) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    await ref.read(petNotifierProvider(userId).notifier).initializePet(species);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final petAsync = ref.watch(petProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 ペット育成'),
        elevation: 0,
      ),
      body: petAsync.when(
        data: (pet) {
          if (pet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ペットをまだ作成していません'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showPetSelectionDialog,
                    child: const Text('ペットを作成する'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ペット表示エリア
              _PetDisplayCard(pet: pet, userId: userId),
              const SizedBox(height: 24),

              // ステータスバー
              _PetStatusBar(pet: pet),
              const SizedBox(height: 24),

              // エサやりエリア
              _FeedingCard(pet: pet, userId: userId),
              const SizedBox(height: 24),

              // 進化情報
              _EvolutionInfoCard(pet: pet),
              const SizedBox(height: 24),

              // 装飾品エリア
              _DecorationsCard(pet: pet, userId: userId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

/// ペット表示カード
class _PetDisplayCard extends ConsumerWidget {
  final PetModel pet;
  final String userId;

  const _PetDisplayCard({
    required this.pet,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ペットイラスト表示エリア
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                pet.imageAsset,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  pet.species.displayName,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ペット情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('名前', style: TextStyle(color: Colors.grey)),
                  Text(
                    pet.species.displayName.split(' ').last,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('段階', style: TextStyle(color: Colors.grey)),
                  Text(
                    pet.currentStage.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('気分', style: TextStyle(color: Colors.grey)),
                  Text(
                    pet.currentMood.displayName.split(' ').last,
                    style: const TextStyle(
                      fontSize: 18,
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

/// ステータスバー
class _PetStatusBar extends StatelessWidget {
  final PetModel pet;

  const _PetStatusBar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // レベル・経験値
        _StatusItem(
          label: 'レベル',
          value: 'Lv ${pet.level}',
          progress: pet.exp / 100,
          color: Colors.purple,
          subLabel: '${pet.exp}/100 XP',
        ),
        const SizedBox(height: 12),

        // 満腹度
        _StatusItem(
          label: '満腹度',
          value: '${pet.hunger}%',
          progress: 1 - (pet.hunger / 100),
          color: Colors.orange,
          subLabel: pet.hunger > 80 ? '🍽️ ご飯が必要！' : '元気です',
        ),
        const SizedBox(height: 12),

        // 幸福度
        _StatusItem(
          label: '幸福度',
          value: '${pet.happiness}%',
          progress: pet.happiness / 100,
          color: Colors.pink,
          subLabel: pet.happiness > 80 ? '😊 とても嬉しい！' : '普通',
        ),
      ],
    );
  }
}

/// ステータス表示アイテム
class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;
  final String? subLabel;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            subLabel!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

/// エサやりカード
class _FeedingCard extends ConsumerWidget {
  final PetModel pet;
  final String userId;

  const _FeedingCard({
    required this.pet,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍽️ エサやり',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            pet.isFedToday
                ? '✅ 今日はもうエサをやりました！\n明日また会いましょう。'
                : '📍 発音問題に正解してペットにエサをやろう！\n発音スコア 60点以上でエサやりできます。',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          if (!pet.isFedToday)
            ElevatedButton(
              onPressed: () {
                // lesson_screen へ遷移
                Navigator.pushNamed(context, '/stage-intro', arguments: {'stageId': 1});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('練習に戻る'),
            ),
          if (pet.isFedToday)
            Text(
              '連続 ${pet.consecutiveFeedDays} 日達成！🎉',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

/// 進化情報カード
class _EvolutionInfoCard extends StatelessWidget {
  final PetModel pet;

  const _EvolutionInfoCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final nextEvolution = pet.levelToNextEvolution;

    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ 進化',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (nextEvolution != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あと $nextEvolution レベルで進化します！',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (pet.level / (pet.currentStage.requiredLevel + 10))
                              .clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const Text(
              '🎉 マスター！最高段階に到達しました！',
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
          const SizedBox(height: 12),
          Text(
            '進化日時: ${pet.evolveDates.length}回',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// 装飾品カード
class _DecorationsCard extends ConsumerWidget {
  final PetModel pet;
  final String userId;

  const _DecorationsCard({
    required this.pet,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎀 装飾品',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (pet.decorationIds.isEmpty)
            Text(
              'まだ装飾品を装備していません。\nコインで買ってみよう！',
              style: TextStyle(color: Colors.grey[700]),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pet.decorationIds.map((id) {
                final decoration = PetDecorationPresets.fromId(id);
                if (decoration == null) return const SizedBox();
                return Chip(
                  label: Text(decoration.emoji + ' ' + decoration.name),
                  onDeleted: () async {
                    await ref
                        .read(petNotifierProvider(userId).notifier)
                        .unequipDecoration(id);
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // ショップ画面へ（要実装）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ショップは準備中です')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('装飾品を探す'),
          ),
        ],
      ),
    );
  }
}

/// ペット選択ダイアログ
class _PetSelectionDialog extends StatelessWidget {
  final Function(PetSpecies) onSelected;

  const _PetSelectionDialog({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🐾 ペットを選ぼう'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PetSpecies.values
              .map(
                (species) => ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(
                      species.previewImageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        species.displayName.split(' ').first,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  title: Text(species.displayName.split(' ').last),
                  onTap: () {
                    onSelected(species);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
