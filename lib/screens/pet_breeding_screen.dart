import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../design_system/design_system.dart';

class PetBreedingScreen extends ConsumerStatefulWidget {
  const PetBreedingScreen({super.key});

  @override
  ConsumerState<PetBreedingScreen> createState() => _PetBreedingScreenState();
}

class _PetBreedingScreenState extends ConsumerState<PetBreedingScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _nicknameController;
  late AnimationController _petAnimationController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _petAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _petAnimationController.dispose();
    super.dispose();
  }

  void _showPetCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => _PetCreationDialog(
        onPetCreated: (species, nickname) async {
          await ref.read(currentPetProvider.notifier).createPet(species, nickname);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _feedPet() {
    showDialog(
      context: context,
      builder: (context) => _FoodShopDialog(
        onFoodSelected: (food) async {
          await ref.read(currentPetProvider.notifier).feedPet(food.satietyRestore);
          if (mounted) Navigator.pop(context);
          _showMessage('${food.name}をあげた! ペットが喜んだ！');
        },
      ),
    );
  }

  Future<void> _playWithPet() async {
    await ref.read(currentPetProvider.notifier).playWithPet();
    _showMessage('ペットと遊んだ！ しあわせだ～');
  }

  Future<void> _petPet() async {
    await ref.read(currentPetProvider.notifier).petPet();
    _showMessage('ペットをなでた。嬉しそう');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(currentPetProvider);
    final stats = ref.watch(petStatsProvider);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🐢 ペット育成'),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 64, color: AppColors.textMuted),
              AppSpacing.verticalSpacerMd,
              const Text('まだペットがいません'),
              AppSpacing.verticalSpacerMd,
              ElevatedButton.icon(
                onPressed: _showPetCreationDialog,
                icon: const Icon(Icons.add),
                label: const Text('ペットを作成'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐢 ペット育成'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          children: [
            // ペットディスプレイ
            _buildPetDisplay(pet),
            AppSpacing.verticalSpacerLg,

            // ステータス表示
            _buildPetStats(pet),
            AppSpacing.verticalSpacerLg,

            // 相互作用ボタン
            _buildInteractionButtons(pet),
            AppSpacing.verticalSpacerLg,

            // 進化情報
            _buildEvolutionInfo(pet),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDisplay(Pet pet) {
    return Container(
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        children: [
          // ペットアニメーション表示
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(_petAnimationController),
            child: Text(
              pet.emoji,
              style: const TextStyle(fontSize: 96),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            pet.nickname,
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            '${pet.evolutionStageName} • Lv.${pet.level}',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPetStats(Pet pet) {
    return Column(
      children: [
        // 満腹度
        _buildStatBar(
          icon: '🍖',
          label: 'お腹',
          status: pet.satietyStatus,
          value: pet.satiety,
          color: AppColors.accentOrange,
        ),
        AppSpacing.verticalSpacerMd,

        // 幸福度
        _buildStatBar(
          icon: '💖',
          label: 'きもち',
          status: pet.happinessStatus,
          value: pet.happiness,
          color: AppColors.accentPink,
        ),
        AppSpacing.verticalSpacerMd,

        // 経験値
        _buildStatBar(
          icon: '⭐',
          label: '経験値',
          status: '${pet.experienceToNextLevel}まで',
          value: pet.experience,
          color: AppColors.accentOrange,
        ),
      ],
    );
  }

  Widget _buildStatBar({
    required String icon,
    required String label,
    required String status,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(color: AppColors.bgLight),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$icon $label', style: AppTypography.labelLarge),
              Text(status, style: AppTypography.bodySmall.copyWith(color: color)),
            ],
          ),
          AppSpacing.verticalSpacerSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            '$value / 100',
            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ペットと遊ぶ', style: AppTypography.labelLarge),
        AppSpacing.verticalSpacerMd,
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _feedPet,
                icon: const Icon(Icons.restaurant),
                label: const Text('エサをあげる'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            AppSpacing.horizontalSpacerMd,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _playWithPet,
                icon: const Icon(Icons.sports_soccer),
                label: const Text('遊ぶ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            AppSpacing.horizontalSpacerMd,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _petPet,
                icon: const Icon(Icons.favorite),
                label: const Text('なでる'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPink,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvolutionInfo(Pet pet) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(10),
        border: Border.all(color: AppColors.accentGreen.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('進化情報', style: AppTypography.labelLarge),
          AppSpacing.verticalSpacerMd,
          _buildEvolutionStage(EvolutionStage.egg, 'たまご', 0, pet),
          _buildEvolutionStage(EvolutionStage.baby, 'ベビー', 10, pet),
          _buildEvolutionStage(EvolutionStage.kids, 'キッズ', 25, pet),
          _buildEvolutionStage(EvolutionStage.adult, 'アダルト', 40, pet),
        ],
      ),
    );
  }

  Widget _buildEvolutionStage(
    EvolutionStage stage,
    String name,
    int requiredLevel,
    Pet pet,
  ) {
    final isReached = pet.level >= requiredLevel;
    final isCurrent = pet.evolutionStage == stage;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            isCurrent ? '✓' : isReached ? '◆' : '○',
            style: TextStyle(
              fontSize: 16,
              color: isCurrent ? AppColors.accentGreen : isReached ? AppColors.accentOrange : AppColors.textMuted,
            ),
          ),
          AppSpacing.horizontalSpacerMd,
          Expanded(
            child: Text(
              '$name (Lv.$requiredLevel以上)',
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent ? AppColors.accentGreen : isReached ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCreationDialog extends StatefulWidget {
  final Function(PetSpecies, String) onPetCreated;

  const _PetCreationDialog({required this.onPetCreated});

  @override
  State<_PetCreationDialog> createState() => _PetCreationDialogState();
}

class _PetCreationDialogState extends State<_PetCreationDialog> {
  late TextEditingController _nicknameController;
  PetSpecies _selectedSpecies = PetSpecies.turtle;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = [
      (PetSpecies.turtle, '🐢', 'タートル'),
      (PetSpecies.parrot, '🦜', 'インコ'),
      (PetSpecies.fish, '🐠', 'さかな'),
      (PetSpecies.lion, '🦁', 'ライオン'),
      (PetSpecies.fox, '🦊', 'キツネ'),
    ];

    return AlertDialog(
      title: const Text('🐢 ペットを作成'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの種類を選ぶ'),
            AppSpacing.verticalSpacerMd,
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: species.map((s) {
                final (spec, emoji, name) = s;
                final isSelected = _selectedSpecies == spec;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSpecies = spec),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.bgLight,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      color: isSelected ? AppColors.primary.withAlpha(20) : AppColors.textWhite,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 32)),
                        Text(name, style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSpacing.verticalSpacerMd,
            const Text('ペットの名前を決める'),
            AppSpacing.verticalSpacerSm,
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '名前を入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
              ),
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
            if (_nicknameController.text.isNotEmpty) {
              widget.onPetCreated(_selectedSpecies, _nicknameController.text);
            }
          },
          child: const Text('作成'),
        ),
      ],
    );
  }
}

class _FoodShopDialog extends ConsumerWidget {
  final Function(PetFood) onFoodSelected;

  const _FoodShopDialog({required this.onFoodSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodShop = ref.watch(petFoodShopProvider);

    return AlertDialog(
      title: const Text('🍖 ペット専門店'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: foodShop.length,
          itemBuilder: (context, index) {
            final food = foodShop[index];
            return ListTile(
              title: Text('${food.icon} ${food.name}'),
              subtitle: Text('${food.description} (${food.satietyRestore}回復)'),
              trailing: Text('${food.cost}💰'),
              onTap: () {
                onFoodSelected(food);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
