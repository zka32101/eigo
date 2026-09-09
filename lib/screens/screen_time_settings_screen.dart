import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// 利用時間制限（スクリーンタイム管理）の設定画面。
///
/// shared_core の [ScreenTimeSettingsWidget] をアプリのテーマ色でラップする。
/// 保護者ダッシュボードから `requireParentalGate` を通した後に遷移する想定。
class ScreenTimeSettingsScreen extends StatelessWidget {
  const ScreenTimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏰ 利用時間の設定'),
        backgroundColor: AppColors.primary,
      ),
      body: const ScreenTimeSettingsWidget(primaryColor: AppColors.primary),
    );
  }
}
