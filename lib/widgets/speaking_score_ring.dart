import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeakingScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final bool showLabel;

  const SpeakingScoreRing({
    super.key,
    required this.score,
    this.size = 80,
    this.showLabel = true,
  });

  Color get _color {
    if (score >= 85) return kAccentGreen;
    if (score >= 70) return kPrimaryColor;
    if (score >= 55) return kAccentOrange;
    return kAccentRed;
  }

  String get _grade {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: size * 0.09,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.bold,
                      color: _color,
                    ),
                  ),
                  Text(
                    _grade,
                    style: TextStyle(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.bold,
                      color: _color.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '発音スコア',
            style: TextStyle(fontSize: size * 0.14, color: kTextMuted),
          ),
        ],
      ],
    );
  }
}
