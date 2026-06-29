import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SkillProgressBar extends StatelessWidget {
  final String icon;
  final String label;
  final double value; // 0.0 - 1.0
  final Color color;
  final String? trailing;

  const SkillProgressBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(fontSize: 13, color: kTextDark)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: trailing != null ? 50 : 36,
          child: Text(
            trailing ?? '${(value * 100).round()}%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
