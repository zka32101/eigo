import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../design_system/design_system.dart';

/// ペット進化画面
class PetEvolutionScreen extends ConsumerStatefulWidget {
  final Pet currentPet;
  final Pet evolvedPet;

  const PetEvolutionScreen({
    Key? key,
    required this.currentPet,
    required this.evolvedPet,
  }) : super(key: key);

  @override
  ConsumerState<PetEvolutionScreen> createState() => _PetEvolutionScreenState();
}

class _PetEvolutionScreenState extends ConsumerState<PetEvolutionScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _opacityController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showEvolved = false;

  @override
  void initState() {
    super.initState();

    // スケールアニメーション
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 不透明度アニメーション
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeIn),
    );

    // 進化アニメーション開始
    _playEvolutionAnimation();
  }

  void _playEvolutionAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _showEvolved = true);
      _scaleController.forward();
      _opacityController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              children: [
                // タイトル
                Text(
                  '🎉 進化しました！',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpacerLg,

                // ビフォーアフター
                _EvolutionComparison(
                  currentPet: widget.currentPet,
                  evolvedPet: widget.evolvedPet,
                  showEvolved: _showEvolved,
                  scaleAnimation: _scaleAnimation,
                  opacityAnimation: _opacityAnimation,
                ),
                AppSpacing.verticalSpacerXl,

                // 統計情報の変更
                _EvolutionStats(
                  currentPet: widget.currentPet,
                  evolvedPet: widget.evolvedPet,
                  visible: _showEvolved,
                ),
                AppSpacing.verticalSpacerXl,

                // アビリティ情報
                _EvolutionAbilities(
                  evolvedPet: widget.evolvedPet,
                  visible: _showEvolved,
                ),
                AppSpacing.verticalSpacerXl,

                // 閉じるボタン
                if (_showEvolved)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('完了'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 進化の比較表示
class _EvolutionComparison extends StatelessWidget {
  final Pet currentPet;
  final Pet evolvedPet;
  final bool showEvolved;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const _EvolutionComparison({
    required this.currentPet,
    required this.evolvedPet,
    required this.showEvolved,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ビフォー
        Column(
          children: [
            Text(
              '進化前',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              currentPet.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              currentPet.evolutionStageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        AppSpacing.verticalSpacerLg,

        // 矢印
        const Icon(Icons.arrow_downward, size: 32, color: Colors.amber),
        AppSpacing.verticalSpacerLg,

        // アフター（アニメーション付き）
        if (showEvolved)
          ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: Column(
                children: [
                  Text(
                    '進化後',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    evolvedPet.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    evolvedPet.evolutionStageName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Opacity(
            opacity: 0.3,
            child: Column(
              children: [
                Text(
                  '進化後',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                AppSpacing.verticalSpacerSm,
                const Text(
                  '?',
                  style: TextStyle(fontSize: 80),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 進化による統計情報の変更
class _EvolutionStats extends StatelessWidget {
  final Pet currentPet;
  final Pet evolvedPet;
  final bool visible;

  const _EvolutionStats({
    required this.currentPet,
    required this.evolvedPet,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ステータスの変化',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,

            // レベル
            _StatRow(
              label: 'レベル',
              before: currentPet.level,
              after: evolvedPet.level,
            ),
            AppSpacing.verticalSpacerSm,

            // 幸福度
            _StatRow(
              label: '幸福度',
              before: currentPet.happiness,
              after: evolvedPet.happiness,
            ),
            AppSpacing.verticalSpacerSm,

            // 満腹度
            _StatRow(
              label: '満腹度',
              before: currentPet.satiety,
              after: evolvedPet.satiety,
            ),
          ],
        ),
      ),
    );
  }
}

/// ステータス行
class _StatRow extends StatelessWidget {
  final String label;
  final int before;
  final int after;

  const _StatRow({
    required this.label,
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    final difference = after - before;
    final differenceText = difference > 0
        ? '+$difference'
        : difference == 0
            ? '-'
            : '$difference';
    final differenceColor =
        difference > 0 ? Colors.green : difference < 0 ? Colors.red : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text('$before → $after'),
            AppSpacing.horizontalSpacerSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: differenceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                differenceText,
                style: TextStyle(
                  color: differenceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 進化時に得られるアビリティ
class _EvolutionAbilities extends StatelessWidget {
  final Pet evolvedPet;
  final bool visible;

  const _EvolutionAbilities({
    required this.evolvedPet,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final newAbilities = _getNewAbilitiesForStage(evolvedPet.evolutionStage);

    if (newAbilities.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ 新しいアビリティ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            Column(
              children: newAbilities
                  .asMap()
                  .entries
                  .map((entry) {
                    final ability = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Text('✅', style: TextStyle(fontSize: 20)),
                          AppSpacing.horizontalSpacerMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ability['name'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ability['description'] as String,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getNewAbilitiesForStage(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        return [];
      case EvolutionStage.baby:
        return [
          {
            'name': '学習開始',
            'description': 'レッスンから得られる経験値が10%増加します。',
          },
        ];
      case EvolutionStage.kids:
        return [
          {
            'name': '単語マスター',
            'description': '新しい単語を学ぶとボーナス経験値を得ます。',
          },
          {
            'name': 'クイック進化',
            'description': 'レベルアップまでの経験値が10%減少します。',
          },
        ];
      case EvolutionStage.adult:
        return [
          {
            'name': '完全習得',
            'description': 'すべての学習ボーナスが30%増加します。',
          },
          {
            'name': 'マスターレベル',
            'description': 'レベルキャップが50に設定されます。',
          },
          {
            'name': 'ペット博士',
            'description': 'ゲーム内で特別なバッジが表示されます。',
          },
        ];
    }
  }
}
