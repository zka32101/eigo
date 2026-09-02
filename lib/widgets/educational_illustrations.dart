import '../design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Custom SVG-based illustrations for educational content
/// All illustrations are created specifically and are commercially usable

class ListeningIllustration extends StatelessWidget {
  final double size;
  const ListeningIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ListeningPainter(),
      ),
    );
  }
}

class _ListeningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Head circle
    canvas.drawCircle(
      Offset(centerX, centerY - 15),
      25,
      Paint()..color = const Color(0xFFFFB74D),
    );

    // Eyes
    canvas.drawCircle(
      Offset(centerX - 8, centerY - 20),
      3,
      Paint()..color = const Color(0xFF333),
    );
    canvas.drawCircle(
      Offset(centerX + 8, centerY - 20),
      3,
      Paint()..color = const Color(0xFF333),
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF333)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.arcToPoint(
      Offset(centerX + 8, centerY - 10),
      radius: const Radius.circular(6),
      clockwise: false,
    );
    canvas.drawPath(path, smilePaint);

    // Headphone left ear cup
    canvas.drawCircle(
      Offset(centerX - 22, centerY - 18),
      8,
      Paint()..color = const Color(0xFF1976D2),
    );

    // Headphone right ear cup
    canvas.drawCircle(
      Offset(centerX + 22, centerY - 18),
      8,
      Paint()..color = const Color(0xFF1976D2),
    );

    // Headphone band
    final bandPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final bandPath = Path();
    bandPath.arcToPoint(
      Offset(centerX + 22, centerY - 18),
      radius: Radius.circular(size.width * 0.3),
      clockwise: false,
    );
    canvas.drawPath(bandPath, bandPaint);

    // Sound waves
    final wavePaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(centerX + 35, centerY - 18), 5, wavePaint);
    canvas.drawCircle(Offset(centerX + 35, centerY - 18), 12, wavePaint);
    canvas.drawCircle(Offset(centerX + 35, centerY - 18), 19, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpeakingIllustration extends StatelessWidget {
  final double size;
  const SpeakingIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpeakingPainter(),
      ),
    );
  }
}

class _SpeakingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Head
    canvas.drawCircle(
      Offset(centerX - 20, centerY - 10),
      20,
      Paint()..color = const Color(0xFFFFB74D),
    );

    // Eyes
    canvas.drawCircle(
      Offset(centerX - 28, centerY - 15),
      2.5,
      Paint()..color = const Color(0xFF333),
    );
    canvas.drawCircle(
      Offset(centerX - 12, centerY - 15),
      2.5,
      Paint()..color = const Color(0xFF333),
    );

    // Mouth open
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - 20, centerY + 5),
        width: 8,
        height: 12,
      ),
      Paint()..color = const Color(0xFFD32F2F),
    );

    // Microphone
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + 15, centerY),
          width: 8,
          height: 25,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF424242),
    );

    // Microphone head (rounded)
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 16),
      6,
      Paint()..color = const Color(0xFF616161),
    );

    // Sound waves from mouth
    final wavePaint = Paint()
      ..color = const Color(0xFFFFA726)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(centerX - 20 + 12 + i * 3, centerY),
        i * 4.0,
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParentFeedbackIllustration extends StatelessWidget {
  final double size;
  const ParentFeedbackIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ParentFeedbackPainter(),
      ),
    );
  }
}

class _ParentFeedbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Parent head
    canvas.drawCircle(
      Offset(centerX - 18, centerY - 20),
      16,
      Paint()..color = const Color(0xFFD4AF37),
    );

    // Child head
    canvas.drawCircle(
      Offset(centerX + 15, centerY),
      14,
      Paint()..color = const Color(0xFFFFB74D),
    );

    // Connection line/arrow
    final linePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(centerX - 5, centerY - 15),
      Offset(centerX + 10, centerY - 5),
      linePaint,
    );

    // Arrow head
    final arrowPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(centerX + 10, centerY - 5);
    arrowPath.lineTo(centerX + 7, centerY - 2);
    arrowPath.lineTo(centerX + 8, centerY - 8);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Feedback chart/graph symbol
    final chartPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Chart bars
    canvas.drawLine(
      Offset(centerX - 25, centerY + 20),
      Offset(centerX - 25, centerY + 10),
      chartPaint,
    );
    canvas.drawLine(
      Offset(centerX - 20, centerY + 20),
      Offset(centerX - 20, centerY + 5),
      chartPaint,
    );
    canvas.drawLine(
      Offset(centerX - 15, centerY + 20),
      Offset(centerX - 15, centerY + 8),
      chartPaint,
    );

    // Baseline
    canvas.drawLine(
      Offset(centerX - 28, centerY + 20),
      Offset(centerX - 12, centerY + 20),
      chartPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GamificationIllustration extends StatelessWidget {
  final double size;
  const GamificationIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GamificationPainter(),
      ),
    );
  }
}

class _GamificationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Trophy cup
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 5),
          width: 20,
          height: 25,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFB300),
    );

    // Trophy handles
    final handlePaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Left handle
    final leftHandlePath = Path();
    leftHandlePath.arcToPoint(
      Offset(centerX - 15, centerY - 5),
      radius: const Radius.circular(8),
      clockwise: false,
    );
    canvas.drawPath(leftHandlePath, handlePaint);

    // Right handle
    final rightHandlePath = Path();
    rightHandlePath.moveTo(centerX + 10, centerY);
    rightHandlePath.arcToPoint(
      Offset(centerX + 15, centerY - 5),
      radius: const Radius.circular(8),
      clockwise: true,
    );
    canvas.drawPath(rightHandlePath, handlePaint);

    // Base
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 18),
        width: 28,
        height: 4,
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // Badge/Medal
    canvas.drawCircle(
      Offset(centerX - 20, centerY - 20),
      12,
      Paint()..color = const Color(0xFF42A5F5),
    );

    // Badge star in center
    final starPaint = Paint()..color = AppColors.accentOrange.withAlpha(25);
    _drawStar(canvas, Offset(centerX - 20, centerY - 20), 5, starPaint);

    // Star particles
    canvas.drawCircle(
      Offset(centerX + 20, centerY - 15),
      3,
      Paint()..color = AppColors.accentOrange.withAlpha(25),
    );
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 25),
      2.5,
      Paint()..color = AppColors.accentOrange.withAlpha(25),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const double angleSlice = 2 * 3.14159 / 5;
    final points = <Offset>[];

    for (int i = 0; i < 5; i++) {
      final angle = i * angleSlice - 3.14159 / 2;
      points.add(Offset(
        center.dx + radius * 0.5 * 3.14159.cos() * (i.isEven ? 2 : 1),
        center.dy + radius * 0.5 * 3.14159.sin() * (i.isEven ? 2 : 1),
      ));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < 5; i++) {
      path.lineTo(points[(i + 2) % 5].dx, points[(i + 2) % 5].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vocabulary visual aid - shows word relationship
class VocabularyAidIllustration extends StatelessWidget {
  final String emoji;
  final double size;
  const VocabularyAidIllustration({
    super.key,
    required this.emoji,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3F2FD), width: 2),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}

/// Learning progress visualization
class ProgressVisualization extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final Color color;

  const ProgressVisualization({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Learning method icons with descriptions
class LearningMethodCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const LearningMethodCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
