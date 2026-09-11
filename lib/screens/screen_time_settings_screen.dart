import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import '../design_system/design_system.dart';

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
