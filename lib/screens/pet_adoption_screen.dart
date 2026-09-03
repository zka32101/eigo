import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../design_system/design_system.dart';
import '../providers/user_profile_provider.dart';
import '../providers/pet_provider.dart';

/// ペット選択・採用画面
class PetAdoptionScreen extends ConsumerWidget {
  const PetAdoptionScreen({Key? key}) : super(key: key);

  static const Map<PetSpecies, String> _speciesEmojis = {
    PetSpecies.turtle: '🐢',
    PetSpecies.parrot: '🦜',
    PetSpecies.fish: '🐠',
    PetSpecies.lion: '🦁',
    PetSpecies.fox: '🦊',
  };

  static const Map<PetSpecies, String> _speciesNames = {
    PetSpecies.turtle: 'かめさん',
    PetSpecies.parrot: 'おうむさん',
    PetSpecies.fish: 'さかなさん',
    PetSpecies.lion: 'ライオンさん',
    PetSpecies.fox: 'きつねさん',
  };

  static const Map<PetSpecies, String> _speciesDescriptions = {
    PetSpecies.turtle: 'ゆっくり、けれど確実に成長します。\n忍耐力が必要です。',
    PetSpecies.parrot: 'とても頭がいいペットです。\n言葉をたくさん学びます。',
    PetSpecies.fish: 'さっぱりとした性格です。\n水のようなさっぱりした育成が特徴。',
    PetSpecies.lion: '王様のようなペットです。\n大きく育ちます。',
    PetSpecies.fox: 'ずるがしこいペットです。\n変化に富んだ育成が特徴。',
  };

  static const Map<PetSpecies, List<String>> _speciesTraits = {
    PetSpecies.turtle: ['忍耐力', '防御力', '成長が遅い'],
    PetSpecies.parrot: ['言語習得', 'コミュニケーション', 'すばやい'],
    PetSpecies.fish: ['上品', '落ち着き', '癒し効果'],
    PetSpecies.lion: ['力強い', 'リーダーシップ', '成長が早い'],
    PetSpecies.fox: ['器用さ', '機敏性', '多才'],
  };

  static const Map<PetSpecies, int> _adoptionCosts = {
    PetSpecies.turtle: 100,
    PetSpecies.parrot: 150,
    PetSpecies.fish: 80,
    PetSpecies.lion: 200,
    PetSpecies.fox: 180,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final currentPet = ref.watch(currentPetProvider);

    // ペットがすでに存在する場合
    if (currentPet != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🐾 ペット採用'),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ペットはすでに存在します',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  '${currentPet.nickname}（${_speciesNames[currentPet.species] ?? '不明'}）',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpacerLg,
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('戻る'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 ペット採用'),
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingMd,
        children: [
          // タイトル
          Text(
            'あなたのペットを選びましょう',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            'あなたの好みのペットを選んで、育成を始めましょう。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerLg,

          // ペットの選択肢
          ...PetSpecies.values.map((species) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PetAdoptionCard(
                species: species,
                emoji: _speciesEmojis[species] ?? '?',
                name: _speciesNames[species] ?? species.name,
                description: _speciesDescriptions[species] ?? '',
                traits: _speciesTraits[species] ?? [],
                adoptionCost: _adoptionCosts[species] ?? 0,
                onAdopt: () => _adoptPet(context, ref, userId, species),
              ),
            );
          }).toList(),

          AppSpacing.verticalSpacerLg,
        ],
      ),
    );
  }

  Future<void> _adoptPet(
    BuildContext context,
    WidgetRef ref,
    String userId,
    PetSpecies species,
  ) async {
    // ニックネーム入力ダイアログ
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => _NicknameDialog(
        species: species,
        emoji: _speciesEmojis[species] ?? '?',
      ),
    );

    if (nickname != null && nickname.isNotEmpty && context.mounted) {
      // ペットを作成
      await ref.read(currentPetProvider.notifier).createPet(species, nickname);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nicknameが加わりました！ 🎉'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

/// ペット採用カード
class _PetAdoptionCard extends StatelessWidget {
  final PetSpecies species;
  final String emoji;
  final String name;
  final String description;
  final List<String> traits;
  final int adoptionCost;
  final VoidCallback onAdopt;

  const _PetAdoptionCard({
    required this.species,
    required this.emoji,
    required this.name,
    required this.description,
    required this.traits,
    required this.adoptionCost,
    required this.onAdopt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ペット情報ヘッダー
            Row(
              children: [
                // 絵文字
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                AppSpacing.horizontalSpacerMd,
                // 名前と説明
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSpacerSm,
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // 特性
            Text(
              '特性',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            AppSpacing.verticalSpacerSm,
            Wrap(
              spacing: 8,
              children: traits
                  .map((trait) => Chip(
                        label: Text(trait),
                        compact: true,
                      ))
                  .toList(),
            ),
            AppSpacing.verticalSpacerMd,

            // 採用コスト
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'コスト: $adoptionCost 💰',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ElevatedButton(
                  onPressed: onAdopt,
                  child: const Text('採用する'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ニックネーム入力ダイアログ
class _NicknameDialog extends StatefulWidget {
  final PetSpecies species;
  final String emoji;

  const _NicknameDialog({
    required this.species,
    required this.emoji,
  });

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ニックネームを決めましょう'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          AppSpacing.verticalSpacerMd,
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'ペットの名前を入力',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLength: 20,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _controller.text.isNotEmpty
              ? () => Navigator.pop(context, _controller.text)
              : null,
          child: const Text('決定'),
        ),
      ],
    );
  }
}
