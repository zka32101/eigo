import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/purchase_provider.dart';
import '../providers/progress_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // プラン情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kAccentOrange.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('⭐', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'プランについて',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          purchase.planDisplayName,
                          style: const TextStyle(fontSize: 12, color: kTextMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: kTextMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 学習情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '学習統計',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('クリア', style: TextStyle(fontSize: 12, color: kTextMuted)),
                          Text('${progress.clearedStages.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('学習時間', style: TextStyle(fontSize: 12, color: kTextMuted)),
                          const Text('--', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // その他
          _SettingsTile(
            icon: Icons.privacy_tip,
            label: 'プライバシーポリシー',
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
          _SettingsTile(
            icon: Icons.info,
            label: 'アプリについて',
            subtitle: 'バージョン 3.1.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '英語コレ！',
              applicationVersion: '3.1.0',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
