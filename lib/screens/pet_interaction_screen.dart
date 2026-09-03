import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../design_system/design_system.dart';
import '../providers/pet_provider.dart';

/// ペットケア・インタラクション画面
class PetInteractionScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const PetInteractionScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  ConsumerState<PetInteractionScreen> createState() =>
      _PetInteractionScreenState();
}

class _PetInteractionScreenState extends ConsumerState<PetInteractionScreen>
    with TickerProviderStateMixin {
  late AnimationController _petAnimationController;
  late AnimationController _feedAnimationController;
  late AnimationController _playAnimationController;
  String? _lastAction;
  DateTime? _lastActionTime;

  @override
  void initState() {
    super.initState();
    _petAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _feedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _playAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _petAnimationController.dispose();
    _feedAnimationController.dispose();
    _playAnimationController.dispose();
    super.dispose();
  }

  Future<void> _feedPet() async {
    // アニメーション実行
    await _feedAnimationController.forward();
    await _feedAnimationController.reverse();

    // ペットにエサをあげる
    final food = ref.watch(petFoodShopProvider).first; // りんご
    await ref.read(currentPetProvider.notifier).feedPet(food.satietyRestore);

    setState(() {
      _lastAction = 'エサをあげた！😋';
      _lastActionTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('りんごをあげました！'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _playWithPet() async {
    // アニメーション実行
    await _playAnimationController.forward();
    await _playAnimationController.reverse();

    // ペットと遊ぶ
    await ref.read(currentPetProvider.notifier).playWithPet();

    setState(() {
      _lastAction = 'ペットと遊んだ！🎮';
      _lastActionTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('楽しく遊びました！'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _petPet() async {
    await ref.read(currentPetProvider.notifier).petPet();

    setState(() {
      _lastAction = 'ペットをなでた！💕';
      _lastActionTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ペットが喜びました！'),
          backgroundColor: Colors.pink,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(currentPetProvider);
    final pet = petAsync ?? widget.pet;

    return Scaffold(
      appBar: AppBar(
        title: Text('🐾 ${pet.nickname}のお世話'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            children: [
              // ペット表示エリア
              _PetDisplayArea(
                pet: pet,
                animationController: _petAnimationController,
              ),
              AppSpacing.verticalSpacerLg,

              // ステータスバー
              _StatusIndicators(pet: pet),
              AppSpacing.verticalSpacerLg,

              // 最後のアクション表示
              if (_lastAction != null)
                Card(
                  color: Colors.amber.withOpacity(0.1),
                  child: Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Text(
                      _lastAction!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              AppSpacing.verticalSpacerLg,

              // インタラクションボタン
              Text(
                'ペットのお世話をしましょう',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              AppSpacing.verticalSpacerMd,

              // エサやりエリア
              _InteractionActionCard(
                icon: '🍎',
                title: 'エサをあげる',
                subtitle: '満腹度を回復します',
                enabled: pet.satiety < 90,
                onTap: _feedPet,
              ),
              AppSpacing.verticalSpacerMd,

              // 遊ぶエリア
              _InteractionActionCard(
                icon: '🎮',
                title: '遊ぶ',
                subtitle: '幸福度が上がります',
                enabled: pet.satiety > 20,
                onTap: _playWithPet,
              ),
              AppSpacing.verticalSpacerMd,

              // なでるエリア
              _InteractionActionCard(
                icon: '💕',
                title: 'なでる',
                subtitle: 'ペットが喜びます',
                enabled: true,
                onTap: _petPet,
              ),
              AppSpacing.verticalSpacerLg,

              // 情報カード
              _PetInfoCard(pet: pet),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }
}

/// ペット表示エリア
class _PetDisplayArea extends StatelessWidget {
  final Pet pet;
  final AnimationController animationController;

  const _PetDisplayArea({
    required this.pet,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: AppSpacing.allPaddingLg,
          child: Column(
            children: [
              // 絵文字
              Text(
                pet.emoji,
                style: const TextStyle(fontSize: 120),
              ),
              AppSpacing.verticalSpacerMd,
              // 名前
              Text(
                pet.nickname,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerSm,
              // 進化段階
              Text(
                pet.evolutionStageName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ステータスインジケーター
class _StatusIndicators extends StatelessWidget {
  final Pet pet;

  const _StatusIndicators({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // レベル
        _StatusRow(
          label: 'レベル',
          value: '${pet.level}',
          icon: '⭐',
        ),
        AppSpacing.verticalSpacerMd,

        // 経験値
        _StatusProgressRow(
          label: '経験値',
          current: pet.experience,
          max: 100,
          icon: '✨',
          color: Colors.purple,
        ),
        AppSpacing.verticalSpacerMd,

        // 満腹度
        _StatusProgressRow(
          label: '満腹度',
          current: pet.satiety,
          max: 100,
          icon: '🍖',
          color: pet.satiety < 30 ? Colors.red : Colors.orange,
        ),
        AppSpacing.verticalSpacerMd,

        // 幸福度
        _StatusProgressRow(
          label: '幸福度',
          current: pet.happiness,
          max: 100,
          icon: '💕',
          color: Colors.pink,
        ),
      ],
    );
  }
}

/// ステータス行
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            AppSpacing.horizontalSpacerMd,
            Text(label),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// ステータスプログレス行
class _StatusProgressRow extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final String icon;
  final Color color;

  const _StatusProgressRow({
    required this.label,
    required this.current,
    required this.max,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (current / max * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                AppSpacing.horizontalSpacerMd,
                Text(label),
              ],
            ),
            Text('$current/$max ($percentage%)'),
          ],
        ),
        AppSpacing.verticalSpacerSm,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / max,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// インタラクションアクションカード
class _InteractionActionCard extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _InteractionActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_InteractionActionCard> createState() => _InteractionActionCardState();
}

class _InteractionActionCardState extends State<_InteractionActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.enabled) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.enabled) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: Transform.scale(
        scale: _isPressed ? 0.95 : 1.0,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Card(
            elevation: widget.enabled ? 4 : 2,
            color: widget.enabled
                ? null
                : Colors.grey.withOpacity(0.2),
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Row(
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.enabled)
                    const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ペット情報カード
class _PetInfoCard extends StatelessWidget {
  final Pet pet;

  const _PetInfoCard({required this.pet});

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
              '📊 ペット情報',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            _InfoRow('種族', pet.species.name),
            _InfoRow('状態', pet.satietyStatus),
            _InfoRow('心情', pet.happinessStatus),
            _InfoRow('学んだ単語', '${pet.learnedWords.length}個'),
            _InfoRow('給食回数', '${pet.totalFeedsCount}回'),
            _InfoRow('遊んだ回数', '${pet.totalPlayCount}回'),
          ],
        ),
      ),
    );
  }
}

/// 情報行
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
