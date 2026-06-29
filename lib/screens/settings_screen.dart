import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_api_key_provider.dart';
import '../providers/morning_notification_provider.dart';
import '../services/purchase_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final purchase = ref.watch(purchaseProvider);
    final apiKeys = ref.watch(aiApiKeysProvider);
    final morningNotification = ref.watch(morningNotificationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ せってい'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // プランバッジ
          _PlanBadgeCard(purchase: purchase),
          const SizedBox(height: 16),

          // 子どもの名前
          _ChildNameCard(settings: settings, ref: ref),
          const SizedBox(height: 16),

          _SectionHeader('学習設定'),
          _SoundToggle(settings: settings, ref: ref),
          _TTSSpeedCard(settings: settings, ref: ref),
          _AutoPlayToggle(settings: settings, ref: ref),
          _PhoneticToggle(settings: settings, ref: ref),

          const SizedBox(height: 16),
          _SectionHeader('通知設定'),
          _NotificationCard(settings: settings, ref: ref),
          _MorningEnglishCard(morningNotification: morningNotification, ref: ref),

          const SizedBox(height: 16),
          _SectionHeader('AI キー設定'),
          _ApiKeysCard(apiKeys: apiKeys, ref: ref),

          const SizedBox(height: 16),
          _SectionHeader('アカウント'),
          _SettingsTile(
            icon: Icons.star,
            color: kAccentOrange,
            label: 'プランをアップグレード',
            subtitle: purchase.planDisplayName,
            onTap: () => Navigator.of(context).pushNamed('/upgrade'),
          ),
          _SettingsTile(
            icon: Icons.restore,
            color: kPrimaryColor,
            label: '購入を復元',
            subtitle: '以前の購入を復元します',
            onTap: () async {
              await ref.read(purchaseProvider.notifier).restore();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('購入を復元しました')),
                );
              }
            },
          ),
          _SettingsTile(
            icon: Icons.bar_chart,
            color: kAccentGreen,
            label: '親向けダッシュボード',
            subtitle: '学習詳細・スピーキング分析',
            onTap: () => Navigator.of(context).pushNamed('/parent'),
          ),
          _SettingsTile(
            icon: Icons.emoji_events,
            color: kAccentOrange,
            label: 'バッジ一覧',
            subtitle: '${progress.clearedStages.length}ステージクリア済み',
            onTap: () => Navigator.of(context).pushNamed('/badges'),
          ),

          const SizedBox(height: 16),
          _SectionHeader('その他'),
          _SettingsTile(
            icon: Icons.privacy_tip,
            color: kTextMuted,
            label: 'プライバシーポリシー',
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
          _SettingsTile(
            icon: Icons.info,
            color: kTextMuted,
            label: 'アプリについて',
            subtitle: 'バージョン 1.1.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '英語コレ！',
              applicationVersion: '1.1.0',
              applicationLegalese: '© 2026 Petit Works',
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Plan Badge ─────────────────────────────────────────────────

class _PlanBadgeCard extends StatelessWidget {
  final PurchaseState purchase;
  const _PlanBadgeCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final isFree = purchase.activePlan == PurchasePlan.free;
    return Card(
      color: isFree ? kBgLight : kPrimaryColor.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFree ? Colors.grey.shade200 : kAccentOrange.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Text(
                isFree ? '🆓' : '⭐',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在のプラン: ${purchase.planDisplayName}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (isFree)
                    const Text(
                      '2週間無料でProをお試しください！',
                      style: TextStyle(fontSize: 12, color: kAccentOrange),
                    ),
                ],
              ),
            ),
            if (isFree)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('試す', style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Child Name ─────────────────────────────────────────────────

class _ChildNameCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _ChildNameCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.child_care, color: kPrimaryColor),
        title: const Text('子どもの名前'),
        subtitle: Text(
          settings.childName.isEmpty ? '未設定（タップして設定）' : settings.childName,
          style: TextStyle(color: settings.childName.isEmpty ? kTextMuted : kTextDark),
        ),
        trailing: const Icon(Icons.edit, color: kTextMuted, size: 18),
        onTap: () => _showNameDialog(context),
      ),
    );
  }

  void _showNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: settings.childName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('子どもの名前を設定'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: '例: たろう',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setChildName(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ─── Sound Toggle ───────────────────────────────────────────────

class _SoundToggle extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _SoundToggle({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(
          settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
          color: kPrimaryColor,
        ),
        title: const Text('サウンド'),
        subtitle: const Text('効果音とTTSを有効にする'),
        value: settings.soundEnabled,
        onChanged: (v) => ref.read(settingsProvider.notifier).setSoundEnabled(v),
        activeThumbColor: kPrimaryColor,
      ),
    );
  }
}

// ─── TTS Speed ──────────────────────────────────────────────────

class _TTSSpeedCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _TTSSpeedCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: kPrimaryColor),
                const SizedBox(width: 12),
                const Text('TTS発音速度', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  settings.ttsSpeed < 0.4 ? 'ゆっくり' : settings.ttsSpeed > 0.7 ? '速い' : '普通',
                  style: const TextStyle(fontSize: 13, color: kTextMuted),
                ),
              ],
            ),
            Slider(
              value: settings.ttsSpeed,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              activeColor: kPrimaryColor,
              label: settings.ttsSpeed.toStringAsFixed(1),
              onChanged: (v) => ref.read(settingsProvider.notifier).setTtsSpeed(v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('ゆっくり', style: TextStyle(fontSize: 11, color: kTextMuted)),
                Text('速い', style: TextStyle(fontSize: 11, color: kTextMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Auto Play Toggle ───────────────────────────────────────────

class _AutoPlayToggle extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _AutoPlayToggle({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: const Icon(Icons.play_circle, color: kListeningColor),
        title: const Text('リスニング自動再生'),
        subtitle: const Text('問題が始まったら自動で英語を再生'),
        value: settings.autoPlayListening,
        onChanged: (v) => ref.read(settingsProvider.notifier).setAutoPlayListening(v),
        activeThumbColor: kListeningColor,
      ),
    );
  }
}

// ─── Phonetic Toggle ────────────────────────────────────────────

class _PhoneticToggle extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _PhoneticToggle({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: const Icon(Icons.text_fields, color: kAccentPurple),
        title: const Text('発音記号を表示'),
        subtitle: const Text('IPA 発音記号を問題カードに表示'),
        value: settings.showPhonetics,
        onChanged: (v) => ref.read(settingsProvider.notifier).setShowPhonetics(v),
        activeThumbColor: kAccentPurple,
      ),
    );
  }
}

// ─── Notification Card ──────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _NotificationCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: kAccentOrange),
            title: const Text('毎日リマインダー'),
            subtitle: const Text('毎日の学習を通知でサポート'),
            value: settings.notificationEnabled,
            onChanged: (v) async {
              if (v) {
                final notif = NotificationService();
                await notif.init();
                final granted = await notif.requestPermission();
                if (granted && context.mounted) {
                  await ref.read(settingsProvider.notifier).setNotificationEnabled(true);
                }
              } else {
                await ref.read(settingsProvider.notifier).setNotificationEnabled(false);
              }
            },
            activeThumbColor: kAccentOrange,
          ),
          if (settings.notificationEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(
                'リマインダー時刻: ${settings.reminderTimeLabel}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.access_time, color: kTextMuted),
              onTap: () => _showTimePicker(context),
            ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (time != null) {
      await ref.read(settingsProvider.notifier).setReminderTime(time.hour, time.minute);
    }
  }
}

// ─── Helpers ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: kTextMuted, fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: kTextMuted),
        onTap: onTap,
      ),
    );
  }
}

// ─── Morning English Card ──────────────────────────────────────

class _MorningEnglishCard extends StatelessWidget {
  final MorningNotificationState morningNotification;
  final WidgetRef ref;
  const _MorningEnglishCard({
    required this.morningNotification,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny, color: kAccentOrange),
            title: const Text('朝英語通知'),
            subtitle: const Text('毎朝ランダムな英語フレーズを通知'),
            value: morningNotification.isEnabled,
            onChanged: (v) async {
              if (v) {
                await ref.read(morningNotificationStateProvider.notifier)
                    .enableMorningNotification(
                  morningNotification.hour,
                  morningNotification.minute,
                );
              } else {
                await ref.read(morningNotificationStateProvider.notifier)
                    .disableMorningNotification();
              }
            },
            activeThumbColor: kAccentOrange,
          ),
          if (morningNotification.isEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(
                '通知時刻: ${morningNotification.timeLabel}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.access_time, color: kTextMuted),
              onTap: () => _showTimePicker(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.notifications),
                  label: const Text('テスト通知を送信'),
                  onPressed: () async {
                    await ref
                        .read(morningNotificationStateProvider.notifier)
                        .sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('テスト通知を送信しました'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kAccentOrange,
                  ),
                ),
              ),
            ),
          ],
          if (morningNotification.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Text(
                morningNotification.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: morningNotification.hour,
        minute: morningNotification.minute,
      ),
    );
    if (time != null) {
      await ref.read(morningNotificationStateProvider.notifier).updateTime(
        time.hour,
        time.minute,
      );
    }
  }
}

// ─── API Keys Card ──────────────────────────────────────────────

class _ApiKeysCard extends StatelessWidget {
  final AiApiKeys apiKeys;
  final WidgetRef ref;
  const _ApiKeysCard({required this.apiKeys, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.api, color: kPrimaryColor),
            title: const Text('Gemini API キー'),
            subtitle: Text(
              apiKeys.hasGeminiKey ? '✓ 設定済み' : '未設定',
              style: TextStyle(
                color: apiKeys.hasGeminiKey ? kAccentGreen : kTextMuted,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.edit, color: kTextMuted, size: 18),
            onTap: () => _showKeyDialog(context, 'Gemini', apiKeys.geminiKey),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.api, color: Color(0xFF7C3AED)),
            title: const Text('Claude API キー'),
            subtitle: Text(
              apiKeys.hasClaudeKey ? '✓ 設定済み (フォールバック)' : '未設定',
              style: TextStyle(
                color: apiKeys.hasClaudeKey ? kAccentGreen : kTextMuted,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.edit, color: kTextMuted, size: 18),
            onTap: () => _showKeyDialog(context, 'Claude', apiKeys.claudeKey),
          ),
        ],
      ),
    );
  }

  void _showKeyDialog(BuildContext context, String provider, String? currentKey) {
    final ctrl = TextEditingController(text: currentKey ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$provider API キー'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider == 'Gemini'
                  ? 'Google AI Studio (https://aistudio.google.com) から取得したキーを入力してください'
                  : 'Anthropic コンソールから取得したキーを入力してください',
              style: const TextStyle(fontSize: 12, color: kTextMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'API キーを入力',
                border: OutlineInputBorder(),
                isCollapsed: true,
                contentPadding: EdgeInsets.all(10),
              ),
              autofocus: true,
              obscureText: true,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          if (currentKey != null && currentKey.isNotEmpty)
            TextButton(
              onPressed: () {
                if (provider == 'Gemini') {
                  ref.read(aiApiKeysProvider.notifier).setGeminiKey('');
                } else {
                  ref.read(aiApiKeysProvider.notifier).setClaudeKey('');
                }
                Navigator.pop(ctx);
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              if (provider == 'Gemini') {
                ref.read(aiApiKeysProvider.notifier).setGeminiKey(ctrl.text.trim());
              } else {
                ref.read(aiApiKeysProvider.notifier).setClaudeKey(ctrl.text.trim());
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$provider キーを保存しました')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
