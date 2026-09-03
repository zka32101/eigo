import 'package:flutter/material.dart';
import '../models/english_town_advanced.dart';

/// Animation service for English-Only Town UI enhancements
class EnglishTownAnimationService {
  /// Get reward animation config with customizable timings
  static RewardAnimationConfig getRewardAnimationConfig({
    int slideInMs = 500,
    int holdMs = 2000,
    int slideOutMs = 300,
    int coinSpinMs = 800,
    int xpPulseMs = 600,
  }) {
    return RewardAnimationConfig(
      slideInDuration: Duration(milliseconds: slideInMs),
      holdDuration: Duration(milliseconds: holdMs),
      slideOutDuration: Duration(milliseconds: slideOutMs),
      coinSpinDuration: Duration(milliseconds: coinSpinMs),
      xpPulseDuration: Duration(milliseconds: xpPulseMs),
    );
  }

  /// Calculate confetti particle positions for explosion effect
  static List<ConfettiParticle> generateConfettiParticles({
    required int count,
    required Size containerSize,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final particles = <ConfettiParticle>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * 3.14159; // Radians for full circle
      final velocity = 150.0 + (random % 100);
      final spin = (random % 360).toDouble();

      particles.add(ConfettiParticle(
        startX: containerSize.width / 2,
        startY: containerSize.height / 2,
        velocityX: velocity * (angle).cos(),
        velocityY: velocity * (angle).sin(),
        spinAmount: spin,
        duration: duration,
        color: _getRandomConfettiColor(),
        shape: _getRandomConfettiShape(),
      ));
    }

    return particles;
  }

  /// Get random confetti color from celebration palette
  static Color _getRandomConfettiColor() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF6B6B), // Red
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFF06292), // Pink
    ];
    final index = DateTime.now().microsecondsSinceEpoch % colors.length;
    return colors[index];
  }

  /// Get random confetti shape
  static ConfettiShape _getRandomConfettiShape() {
    final shapes = ConfettiShape.values;
    final index = DateTime.now().microsecondsSinceEpoch % shapes.length;
    return shapes[index];
  }

  /// Calculate bounce animation keyframes for coin spin effect
  static List<TweenSequenceItem<double>> getCoinSpinKeyframes(
    Duration totalDuration,
  ) {
    return <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: 360),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 360, end: 720),
        weight: 50,
      ),
    ];
  }

  /// Calculate pulse animation for XP reward display
  static List<TweenSequenceItem<double>> getXpPulseKeyframes(
    Duration totalDuration,
  ) {
    return <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.2, end: 0.8),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.8, end: 1.1),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 25,
      ),
    ];
  }

  /// Generate particle effects for achievement unlock
  static List<AchievementParticle> generateAchievementParticles({
    required int count,
    required Offset position,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final particles = <AchievementParticle>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * 3.14159;
      final velocity = 100.0 + (random % 150);

      particles.add(AchievementParticle(
        startX: position.dx,
        startY: position.dy,
        velocityX: velocity * (angle).cos(),
        velocityY: velocity * (angle).sin() - 150, // Bias upward
        duration: duration,
        emoji: _getRandomAchievementEmoji(),
      ));
    }

    return particles;
  }

  static String _getRandomAchievementEmoji() {
    final emojis = ['⭐', '✨', '🌟', '💫', '⚡'];
    final index = DateTime.now().microsecondsSinceEpoch % emojis.length;
    return emojis[index];
  }

  /// Calculate slide-in animation curve for reward card
  static Curve getRewardCardEntryCurve() => Curves.easeOutBack;

  /// Calculate slide-out animation curve for reward card
  static Curve getRewardCardExitCurve() => Curves.easeInQuad;

  /// Get bounce curve for celebration effect
  static Curve getCelebrationBounce() => Curves.elasticOut;
}

/// Confetti particle data
class ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double spinAmount;
  final Duration duration;
  final Color color;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.spinAmount,
    required this.duration,
    required this.color,
    required this.shape,
  });

  /// Calculate position at time t (0-1)
  Offset getPositionAtTime(double t) {
    return Offset(
      startX + (velocityX * (duration.inMilliseconds * t / 1000)),
      startY + (velocityY * (duration.inMilliseconds * t / 1000)) + (980 * t * t * 1000), // Add gravity
    );
  }

  /// Calculate rotation at time t (0-1)
  double getRotationAtTime(double t) {
    return spinAmount * t * 360;
  }

  /// Calculate opacity fade at end of animation
  double getOpacityAtTime(double t) {
    if (t < 0.8) return 1.0;
    return 1.0 - ((t - 0.8) / 0.2);
  }
}

/// Confetti shape types
enum ConfettiShape {
  circle,
  square,
  star,
  diamond,
  hexagon,
}

/// Achievement particle for milestone/achievement unlocks
class AchievementParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Duration duration;
  final String emoji;

  AchievementParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.duration,
    required this.emoji,
  });

  /// Calculate position at time t (0-1)
  Offset getPositionAtTime(double t) {
    return Offset(
      startX + (velocityX * (duration.inMilliseconds * t / 1000)),
      startY + (velocityY * (duration.inMilliseconds * t / 1000)) + (500 * t * t * 1000), // Gravity
    );
  }

  /// Calculate opacity fade (fast fade at end)
  double getOpacityAtTime(double t) {
    if (t < 0.7) return 1.0;
    return 1.0 - ((t - 0.7) / 0.3);
  }
}
