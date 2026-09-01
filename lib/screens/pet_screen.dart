import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

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
                  AppSpacing.verticalSpacerMd,
                  ElevatedButton(
                    onPressed: _showPetSelectionDialog,
                    child: const Text('ペットを作成する'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: AppSpacing.allPaddingMd,
            children: [
              // ペット表示エリア
              _PetDisplayCard(pet: pet, userId: userId),
              AppSpacing.verticalSpacerLg,

              // ステータスバー
              _PetStatusBar(pet: pet),
              AppSpacing.verticalSpacerLg,

              // エサやりエリア
              _FeedingCard(pet: pet, userId: userId),
              AppSpacing.verticalSpacerLg,

              // 進化情報
              _EvolutionInfoCard(pet: pet),
              AppSpacing.verticalSpacerLg,

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
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // ペットイラスト表示エリア
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Center(
              child: Image.asset(
                pet.imageAsset,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  pet.species.displayName,
                  style: AppTypography.headlineLarge,
                ),
              ),
            ),
          ),
          AppSpacing.verticalSpacerMd,

          // ペット情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('名前', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  Text(
                    pet.species.displayName.split(' ').last,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('段階', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  Text(
                    pet.currentStage.displayName,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('気分', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  Text(
                    pet.currentMood.displayName.split(' ').last,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
        AppSpacing.verticalSpacerSm,

        // 満腹度
        _StatusItem(
          label: '満腹度',
          value: '${pet.hunger}%',
          progress: 1 - (pet.hunger / 100),
          color: Colors.orange,
          subLabel: pet.hunger > 80 ? '🍽️ ご飯が必要！' : '元気です',
        ),
        AppSpacing.verticalSpacerSm,

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
              style: AppTypography.labelLarge,
            ),
            Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
          ],
        ),
        AppSpacing.verticalSpacerXs,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (subLabel != null) ...[
          AppSpacing.verticalSpacerXs,
          Text(
            subLabel!,
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
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
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍽️ エサやり',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            pet.isFedToday
                ? '✅ 今日はもうエサをやりました！\n明日また会いましょう。'
                : '📍 発音問題に正解してペットにエサをやろう！\n発音スコア 60点以上でエサやりできます。',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
          ),
          AppSpacing.verticalSpacerSm,
          if (!pet.isFedToday)
            ElevatedButton(
              onPressed: () {
                // lesson_screen へ遷移
                Navigator.pushNamed(context, '/stage-intro', arguments: {'stageId': 1});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
              ),
              child: const Text('練習に戻る'),
            ),
          if (pet.isFedToday)
            Text(
              '連続 ${pet.consecutiveFeedDays} 日達成！🎉',
              style: AppTypography.labelLarge.copyWith(color: kAccentOrange),
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
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ 進化',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerSm,
          if (nextEvolution != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あと $nextEvolution レベルで進化します！',
                  style: AppTypography.bodySmall,
                ),
                AppSpacing.verticalSpacerXs,
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
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
            Text(
              '🎉 マスター！最高段階に到達しました！',
              style: AppTypography.bodySmall.copyWith(color: kAccentGreen),
            ),
          AppSpacing.verticalSpacerSm,
          Text(
            '進化日時: ${pet.evolveDates.length}回',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
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
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.purple.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎀 装飾品',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerSm,
          if (pet.decorationIds.isEmpty)
            Text(
              'まだ装飾品を装備していません。\nコインで買ってみよう！',
              style: AppTypography.bodySmall.copyWith(color: kTextMuted),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
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
          AppSpacing.verticalSpacerSm,
          ElevatedButton(
            onPressed: () {
              // ショップ画面へ（要実装）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ショップは準備中です')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
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
