import 'package:flutter/material.dart';
import 'dart:math';
import 'package:eigo/services/npc_particle_effects_service.dart';

/// パーティクルエフェクトウィジェット
/// NPCパーティクルエフェクトサービスからのエフェクト設定を可視化
class ParticleEffectWidget extends StatefulWidget {
  final NPCParticleEffectsService.ParticleEffect effect;
  final VoidCallback? onComplete;

  const ParticleEffectWidget({
    Key? key,
    required this.effect,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ParticleEffectWidget> createState() => _ParticleEffectWidgetState();
}

class _ParticleEffectWidgetState extends State<ParticleEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.effect.duration,
      vsync: this,
    );

    _initializeParticles();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _initializeParticles() {
    _particles = List.generate(
      widget.effect.particleCount,
      (index) {
        final angle = (_random.nextDouble() * 2 * pi);
        final velocity = Offset(
          cos(angle) * widget.effect.speed,
          sin(angle) * widget.effect.speed,
        );

        return _Particle(
          startPosition: widget.effect.position,
          velocity: velocity,
          color: widget.effect.color,
          size: widget.effect.size,
          life: 1.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // パーティクルの位置と不透明度を更新
        for (final particle in _particles) {
          final progress = _controller.value;
          particle.life = 1.0 - progress;
          particle.position = particle.startPosition +
              particle.velocity * widget.effect.duration.inMilliseconds * progress;
        }

        return CustomPaint(
          painter: _ParticleEffectPainter(
            particles: _particles,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// パーティクル
class _Particle {
  final Offset startPosition;
  final Offset velocity;
  final Color color;
  final double size;

  Offset position;
  double life;

  _Particle({
    required this.startPosition,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
  }) : position = startPosition;
}

/// パーティクルエフェクト描画
class _ParticleEffectPainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticleEffectPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life)
        ..style = PaintingStyle.fill;

      // パーティクルを円形で描画
      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticleEffectPainter oldDelegate) => true;
}
