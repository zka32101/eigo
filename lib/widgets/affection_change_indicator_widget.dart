import 'package:flutter/material.dart';
import 'package:eigo/services/npc_animation_service.dart';
import 'package:eigo/services/npc_particle_effects_service.dart';
import 'package:eigo/services/npc_sound_effects_service.dart';
import 'package:eigo/widgets/particle_effect_widget.dart';

/// 親密度変化インジケーターウィジェット
/// 親密度の増減をアニメーション＋エフェクトで表示
class AffectionChangeIndicatorWidget extends StatefulWidget {
  final int affectionChange;
  final String npcName;
  final Offset position;

  const AffectionChangeIndicatorWidget({
    Key? key,
    required this.affectionChange,
    required this.npcName,
    required this.position,
  }) : super(key: key);

  @override
  State<AffectionChangeIndicatorWidget> createState() =>
      _AffectionChangeIndicatorWidgetState();
}

class _AffectionChangeIndicatorWidgetState
    extends State<AffectionChangeIndicatorWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<Offset> _floatAnimation;
  late Animation<double> _opacityAnimation;

  final NPCAnimationService _animationService = NPCAnimationService.getInstance();
  final NPCSoundEffectsService _soundService = NPCSoundEffectsService.getInstance();
  final NPCParticleEffectsService _particleService =
      NPCParticleEffectsService.getInstance();

  late NPCParticleEffectsService.ParticleEffect _particleEffect;

  @override
  void initState() {
    super.initState();

    // フローティングアニメーション
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatAnimation = Tween<Offset>(
      begin: widget.position,
      end: widget.position + Offset(0, -100),
    ).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOut),
    );

    // フェードアウトアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // パーティクルエフェクト
    if (widget.affectionChange > 0) {
      _particleEffect = _particleService.getAffectionIncreaseEffect(widget.position);
      _soundService.playAffectionChangeSound(widget.affectionChange);
    } else if (widget.affectionChange < 0) {
      _particleEffect = _particleService.getEmotionEffect('sad', widget.position);
      _soundService.playAffectionChangeSound(widget.affectionChange);
    } else {
      _particleEffect = _particleService.getEmotionEffect('neutral', widget.position);
    }

    _floatController.forward();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _fadeController]),
      builder: (context, child) {
        return Positioned(
          left: _floatAnimation.value.dx,
          top: _floatAnimation.value.dy,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // パーティクルエフェクト背景
          SizedBox(
            width: 100,
            height: 100,
            child: ParticleEffectWidget(effect: _particleEffect),
          ),

          // テキスト表示
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 感情エモジ
              Text(
                _getEmoji(widget.affectionChange),
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),

              // 親密度変化テキスト
              Text(
                _getAffectionText(widget.affectionChange),
                style: TextStyle(
                  color: _getAffectionColor(widget.affectionChange),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmoji(int affectionChange) {
    if (affectionChange > 0) return '💕';
    if (affectionChange < 0) return '💔';
    return '😊';
  }

  String _getAffectionText(int affectionChange) {
    if (affectionChange > 0) {
      return '+${affectionChange.abs()}';
    } else if (affectionChange < 0) {
      return '${affectionChange.abs()}';
    }
    return 'No Change';
  }

  Color _getAffectionColor(int affectionChange) {
    if (affectionChange > 0) return Colors.red;
    if (affectionChange < 0) return Colors.blue;
    return Colors.grey;
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
