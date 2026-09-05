import 'package:flutter/material.dart';
import 'package:eigo/services/npc_particle_effects_service.dart';
import 'package:eigo/widgets/particle_effect_widget.dart';

/// エフェクトオーバーレイウィジェット
/// 複数のパーティクルエフェクトを同時に表示・管理
class EffectOverlayWidget extends StatefulWidget {
  final List<NPCParticleEffectsService.ParticleEffect> effects;
  final VoidCallback? onAllEffectsComplete;

  const EffectOverlayWidget({
    Key? key,
    required this.effects,
    this.onAllEffectsComplete,
  }) : super(key: key);

  @override
  State<EffectOverlayWidget> createState() => _EffectOverlayWidgetState();
}

class _EffectOverlayWidgetState extends State<EffectOverlayWidget> {
  late List<bool> _completedEffects;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _completedEffects = List.filled(widget.effects.length, false);
  }

  void _onEffectComplete(int index) {
    if (!_completedEffects[index]) {
      setState(() {
        _completedEffects[index] = true;
        _completedCount++;
      });

      // すべてのエフェクトが完了したかチェック
      if (_completedCount == widget.effects.length) {
        widget.onAllEffectsComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 各エフェクトを独立したウィジェットとして描画
        for (int i = 0; i < widget.effects.length; i++)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: ParticleEffectWidget(
              effect: widget.effects[i],
              onComplete: () => _onEffectComplete(i),
            ),
          ),
      ],
    );
  }
}
