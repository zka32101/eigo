import 'package:flutter/material.dart';
import 'package:eigo/services/npc_particle_effects_service.dart';
import 'package:eigo/services/npc_sound_effects_service.dart';
import 'package:eigo/widgets/particle_effect_widget.dart';

/// ダイアログ選択肢ボタンウィジェット
/// ダイアログの選択肢を表示し、選択時にエフェクトを表示
class DialogueChoiceButtonWidget extends StatefulWidget {
  final String choiceText;
  final int choiceIndex;
  final VoidCallback onSelected;
  final bool enabled;
  final Duration delay;

  const DialogueChoiceButtonWidget({
    Key? key,
    required this.choiceText,
    required this.choiceIndex,
    required this.onSelected,
    this.enabled = true,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<DialogueChoiceButtonWidget> createState() =>
      _DialogueChoiceButtonWidgetState();
}

class _DialogueChoiceButtonWidgetState extends State<DialogueChoiceButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _selectController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final NPCSoundEffectsService _soundService = NPCSoundEffectsService.getInstance();
  final NPCParticleEffectsService _particleService = NPCParticleEffectsService.getInstance();

  bool _isSelected = false;
  late NPCParticleEffectsService.ParticleEffect _selectEffect;

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _selectController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.elasticOut),
    );

    // 選択エフェクトを生成
    _selectEffect = _particleService.getDialogueChoiceEffect(
      Offset(MediaQuery.of(context).size.width / 2, 0),
    );

    // ディレイ後にアニメーション開始
    Future.delayed(widget.delay, () {
      if (mounted) {
        _appearanceController.forward();
      }
    });
  }

  void _onPressed() {
    if (!widget.enabled || _isSelected) return;

    setState(() => _isSelected = true);
    _soundService.playButtonClickSound();
    _selectController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onSelected();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              // 選択時のエフェクトを表示
              if (_isSelected)
                Positioned.fill(
                  child: ParticleEffectWidget(
                    effect: _selectEffect,
                  ),
                ),

              // ボタン本体
              GestureDetector(
                onTap: _onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isSelected
                        ? Colors.amber.shade600
                        : Colors.amber.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSelected ? Colors.amber : Colors.amber.shade400,
                      width: 2,
                    ),
                    boxShadow: [
                      if (_isSelected)
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 選択肢番号
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.choiceIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 選択肢テキスト
                      Expanded(
                        child: Text(
                          widget.choiceText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 選択時のチェックマーク
                      if (_isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _selectController.dispose();
    super.dispose();
  }
}
