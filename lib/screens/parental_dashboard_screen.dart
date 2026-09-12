// Phase 4.21: パイプラッシュ統合
// 各アプリでコピーして使用
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class ParentalDashboardScreen extends StatelessWidget {
  final String appId; // 'eigo', 'sansu', 'kokugo' など

  const ParentalDashboardScreen({
    super.key,
    required this.appId,
  });

  @override
  Widget build(BuildContext context) {
    // アプリごとにカラースキームを変更
    final primaryColors = {
      'eigo': const Color(0xFF4A90E2),      // Blue
      'sansu': const Color(0xFFE94B3C),     // Red
      'kokugo': const Color(0xFF9B59B6),    // Purple
      'newrepo': const Color(0xFF00BCD4),   // Cyan (理科)
      'social': const Color(0xFF4CAF50),    // Green (社会)
      'shinshin': const Color(0xFFFF6B9D),  // Pink (道徳)
      'programming': const Color(0xFFFFA500), // Orange
      'yourwish': const Color(0xFFFFD700),  // Gold
    };

    final primaryColor = primaryColors[appId] ?? const Color(0xFF4A90E2);

    return ParentalDashboard(
      childName: '学習者さん', // 子どもの名前に変更可能
      primaryColor: primaryColor,
    );
  }
}
