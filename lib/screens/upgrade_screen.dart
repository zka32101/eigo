import 'package:flutter/material.dart';

import 'paywall_screen.dart';

/// 課金画面の入口（`/upgrade`）。
///
/// 小学コレシリーズ共通のプレミアム（月額¥300 / 年額¥2,400）1本のみ。
/// 画面本体は [PaywallScreen]。
class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) => const PaywallScreen();
}
