import 'package:flutter/material.dart';
import '../models/english_town_advanced.dart';
import '../services/english_town_animation_service.dart';
import '../design_system/design_system.dart';

/// Animated reward card widget for XP and coin display
class AnimatedRewardCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Duration animationDuration;
  final VoidCallback? onAnimationComplete;
  final bool playAnimation;

  const AnimatedRewardCard({
    Key? key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.onAnimationComplete,
    this.playAnimation = true,
  }) : super(key: key);

  @override
  State<AnimatedRewardCard> createState() => _AnimatedRewardCardState();
}

class _AnimatedRewardCardState extends State<AnimatedRewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = TweenSequence<double>(
      EnglishTownAnimationService.getXpPulseKeyframes(widget.animationDuration),
    ).animate(_animationController);

    if (widget.playAnimation) {
      _animationController.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedRewardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playAnimation != widget.playAnimation && widget.playAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: AppSpacing.allPaddingMd,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          border: Border.all(color: widget.color, width: 2),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              widget.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              widget.value,
              style: AppTypography.displaySmall.copyWith(
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confetti animation widget
class ConfettiAnimation extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;
  final int particleCount;
  final VoidCallback? onComplete;

  const ConfettiAnimation({
    Key? key,
    this.isPlaying = true,
    this.duration = const Duration(milliseconds: 2000),
    this.particleCount = 50,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _generateParticles();

    if (widget.isPlaying) {
      _animationController.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  void _generateParticles() {
    _particles = EnglishTownAnimationService.generateConfettiParticles(
      count: widget.particleCount,
      containerSize: MediaQuery.of(context).size,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying && widget.isPlaying) {
      _generateParticles();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _animationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPositionAtTime(progress);
      final rotation = particle.getRotationAtTime(progress);
      final opacity = particle.getOpacityAtTime(progress);

      // Skip particles that have fallen off screen
      if (position.dy > size.height + 100) continue;

      _drawConfettiShape(
        canvas,
        position,
        particle.shape,
        particle.color.withOpacity(opacity),
        rotation,
      );
    }
  }

  void _drawConfettiShape(
    Canvas canvas,
    Offset position,
    ConfettiShape shape,
    Color color,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation * 3.14159 / 180);

    final paint = Paint()..color = color;

    switch (shape) {
      case ConfettiShape.circle:
        canvas.drawCircle(Offset.zero, 4, paint);
      case ConfettiShape.square:
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 8, height: 8), paint);
      case ConfettiShape.star:
        _drawStar(canvas, Offset.zero, 6, paint);
      case ConfettiShape.diamond:
        _drawDiamond(canvas, Offset.zero, 6, paint);
      case ConfettiShape.hexagon:
        _drawHexagon(canvas, Offset.zero, 5, paint);
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * 3.14159 / 5) - 3.14159 / 2;
      final x = center.dx + size * (3 - i.isEven ? 1 : 2) / 3 * (angle).cos();
      final y = center.dy + size * (3 - i.isEven ? 1 : 2) / 3 * (angle).sin();
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * 3.14159 / 6);
      final x = center.dx + size * (angle).cos();
      final y = center.dy + size * (angle).sin();
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Achievement particle animation widget
class AchievementParticleAnimation extends StatefulWidget {
  final Offset position;
  final bool isPlaying;
  final Duration duration;
  final int particleCount;
  final VoidCallback? onComplete;

  const AchievementParticleAnimation({
    Key? key,
    required this.position,
    this.isPlaying = true,
    this.duration = const Duration(milliseconds: 1500),
    this.particleCount = 8,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AchievementParticleAnimation> createState() => _AchievementParticleAnimationState();
}

class _AchievementParticleAnimationState extends State<AchievementParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AchievementParticle> _particles;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _generateParticles();

    if (widget.isPlaying) {
      _animationController.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  void _generateParticles() {
    _particles = EnglishTownAnimationService.generateAchievementParticles(
      count: widget.particleCount,
      position: widget.position,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(AchievementParticleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying && widget.isPlaying) {
      _generateParticles();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: AchievementParticlePainter(
            particles: _particles,
            progress: _animationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for achievement particles
class AchievementParticlePainter extends CustomPainter {
  final List<AchievementParticle> particles;
  final double progress;

  AchievementParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPositionAtTime(progress);
      final opacity = particle.getOpacityAtTime(progress);

      // Skip particles that have moved off screen
      if (position.dy < -50 || position.dx < -50 || position.dx > size.width + 50) {
        continue;
      }

      _drawEmoji(canvas, position, particle.emoji, opacity);
    }
  }

  void _drawEmoji(
    Canvas canvas,
    Offset position,
    String emoji,
    double opacity,
  ) {
    final paint = Paint()..color = Colors.black.withOpacity(opacity);
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 28),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(AchievementParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
