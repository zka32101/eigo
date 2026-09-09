import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    hide progressProvider, ProgressNotifier, LearningProgress;
import '../providers/progress_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_api_key_provider.dart';
import '../providers/morning_notification_provider.dart';
import '../services/purchase_service.dart';
import '../services/notification_service.dart';
import '../design_system/design_system.dart';

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
        title: const Text('設定'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingLg,
        children: [
          // プランバッジ
          _PlanBadgeCard(purchase: purchase),
          AppSpacing.verticalSpacerMd,

          // 子どもの名前
          _ChildNameCard(settings: settings, ref: ref),
          AppSpacing.verticalSpacerMd,

          _SectionHeader('学習設定'),
          _SoundToggle(settings: settings, ref: ref),
          _TTSSpeedCard(settings: settings, ref: ref),
          _AutoPlayToggle(settings: settings, ref: ref),
          _PhoneticToggle(settings: settings, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('通知設定'),
          _NotificationCard(settings: settings, ref: ref),
          _MorningEnglishCard(morningNotification: morningNotification, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('AI キー設定'),
          _ApiKeysCard(apiKeys: apiKeys, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('アカウント'),
          _SettingsTile(
            icon: Icons.star,
            color: AppColors.accentOrange,
            label: 'プランをアップグレード',
            subtitle: purchase.planDisplayName,
            onTap: () => Navigator.of(context).pushNamed('/upgrade'),
          ),
          _SettingsTile(
            icon: Icons.restore,
            color: AppColors.primary,
            label: '購入を復元',
            subtitle: '以前の購入を復元します',
            onTap: () async {
              final success = await ref.read(purchaseProvider.notifier).restore();
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('購入を復元しました')),
                );
              } else {
                final errorMessage = ref.read(purchaseProvider).errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage ?? '復元できる購入が見つかりませんでした'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
          _SettingsTile(
            icon: Icons.bar_chart,
            color: AppColors.accentGreen,
            label: '親向けダッシュボード',
            subtitle: '学習詳細・スピーキング分析',
            onTap: () async {
              final passedGate = await requireParentalGate(context);
              if (!passedGate || !context.mounted) return;
              Navigator.of(context).pushNamed('/parent');
            },
          ),
          _SettingsTile(
            icon: Icons.emoji_events,
            color: AppColors.accentOrange,
            label: 'バッジ一覧',
            subtitle: '${progress.clearedStages.length}ステージクリア済み',
            onTap: () => Navigator.of(context).pushNamed('/badges'),
          ),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('その他'),
          _SettingsTile(
            icon: Icons.privacy_tip,
            color: AppColors.textMuted,
            label: 'プライバシーポリシー',
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
          _SettingsTile(
            icon: Icons.feedback,
            color: AppColors.textMuted,
            label: 'バグ報告・ご意見',
            subtitle: '不具合や改善要望を送る',
            onTap: () => Navigator.of(context).pushNamed('/feedback'),
          ),
          _SettingsTile(
            icon: Icons.info,
            color: AppColors.textMuted,
            label: 'アプリについて',
            subtitle: 'バージョン 1.1.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '英語コレ！',
              applicationVersion: '1.1.0',
              applicationLegalese: '© 2026 ',
            ),
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

// ─── Plan Badge ───────────────────────────────────────────

class _PlanBadgeCard extends StatelessWidget {
  final PurchaseState purchase;
  const _PlanBadgeCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final isFree = purchase.activePlan == PurchasePlan.free;
    return Card(
      color: isFree ? AppColors.bgLight : AppColors.primary.withAlpha(15),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Row(
          children: [
            Container(
              padding: AppSpacing.allPaddingSm,
              decoration: BoxDecoration(
                color: isFree ? AppColors.bgLight : AppColors.accentOrange.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Text(
                isFree ? '🆓' : '👑',
                style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
              ),
            ),
            AppSpacing.horizontalSpacerSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在のプラン: ${purchase.planDisplayName}',
                    style: AppTypography.labelLarge,
                  ),
                  if (isFree)
                    const Text(
                      '2週間無料でProをお試しください！',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.accentOrange),
                    ),
                ],
              ),
            ),
            if (isFree)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                ),
                child: const Text('試す'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Child Name ───────────────────────────────────────────

class _ChildNameCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _ChildNameCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.child_care, color: AppColors.primary),
        title: const Text('子どもの名前'),
        subtitle: Text(
          settings.childName.isEmpty ? '未設定（タップして設定）' : settings.childName,
          style: TextStyle(color: settings.childName.isEmpty ? AppColors.textMuted : AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.edit, color: AppColors.textMuted, size: 18),
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

// ─── Sound Toggle ───────────────────────────────────────────

class _SoundToggle extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _SoundToggle({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: SwitchListTile(
        secondary: Icon(
          settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
          color: AppColors.primary,
        ),
        title: const Text('サウンド'),
        subtitle: const Text('効果音とTTSを有効にする'),
        value: settings.soundEnabled,
        onChanged: (v) => ref.read(settingsProvider.notifier).setSoundEnabled(v),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

// ─── TTS Speed ───────────────────────────────────────────

class _TTSSpeedCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _TTSSpeedCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: AppSpacing.horizontalPaddingLg + EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: AppColors.primary),
                AppSpacing.horizontalSpacerSm,
                Text('TTS発音速度', style: AppTypography.labelLarge),
                const Spacer(),
                Text(
                  settings.ttsSpeed < 0.4 ? 'ゆっくり' : settings.ttsSpeed > 0.7 ? '速い' : '普通',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            Slider(
              value: settings.ttsSpeed,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              activeColor: AppColors.primary,
              label: settings.ttsSpeed.toStringAsFixed(1),
              onChanged: (v) => ref.read(settingsProvider.notifier).setTtsSpeed(v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('ゆっくり', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                Text('速い', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
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
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: SwitchListTile(
        secondary: const Icon(Icons.play_circle, color: AppColors.listeningColor),
        title: const Text('リスニング自動再生'),
        subtitle: const Text('問題が始まったら自動で英語を再生'),
        value: settings.autoPlayListening,
        onChanged: (v) => ref.read(settingsProvider.notifier).setAutoPlayListening(v),
        activeThumbColor: AppColors.listeningColor,
      ),
    );
  }
}

// ─── Phonetic Toggle ───────────────────────────────────────────

class _PhoneticToggle extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _PhoneticToggle({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: SwitchListTile(
        secondary: const Icon(Icons.text_fields, color: AppColors.accentPurple),
        title: const Text('発音記号を表示'),
        subtitle: const Text('IPA 発音記号を問題カードに表示'),
        value: settings.showPhonetics,
        onChanged: (v) => ref.read(settingsProvider.notifier).setShowPhonetics(v),
        activeThumbColor: AppColors.accentPurple,
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _NotificationCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppColors.accentOrange),
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
            activeThumbColor: AppColors.accentOrange,
          ),
          if (settings.notificationEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(
                'リマインダー時刻: ${settings.reminderTimeLabel}',
                style: AppTypography.bodySmall,
              ),
              trailing: const Icon(Icons.access_time, color: AppColors.textMuted),
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

// ─── Helpers ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs, top: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
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
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Container(
          padding: AppSpacing.allPaddingXs,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label),
        subtitle: subtitle != null ? Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)) : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}

// ─── Morning English Card ───────────────────────────────────────────

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
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny, color: AppColors.accentOrange),
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
            activeThumbColor: AppColors.accentOrange,
          ),
          if (morningNotification.isEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(
                '通知時刻: ${morningNotification.timeLabel}',
                style: AppTypography.bodySmall,
              ),
              trailing: const Icon(Icons.access_time, color: AppColors.textMuted),
              onTap: () => _showTimePicker(context),
            ),
            Padding(
              padding: AppSpacing.horizontalPaddingLg + EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                    foregroundColor: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
          ],
          if (morningNotification.error != null)
            Container(
              padding: AppSpacing.allPaddingMd,
              color: AppColors.error.withAlpha(25),
              child: Text(
                morningNotification.error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
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

// ─── API Keys Card ───────────────────────────────────────────

class _ApiKeysCard extends StatelessWidget {
  final AiApiKeys apiKeys;
  final WidgetRef ref;
  const _ApiKeysCard({required this.apiKeys, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.api, color: AppColors.primary),
            title: const Text('Gemini API キー'),
            subtitle: Text(
              apiKeys.hasGeminiKey ? '✅ 設定済み' : '未設定',
              style: TextStyle(
                color: apiKeys.hasGeminiKey ? AppColors.accentGreen : AppColors.textMuted,
                fontSize: AppTypography.bodySmall.fontSize,
              ),
            ),
            trailing: const Icon(Icons.edit, color: AppColors.textMuted, size: 18),
            onTap: () => _showKeyDialog(context, 'Gemini', apiKeys.geminiKey),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.api, color: AppColors.accentPurple),
            title: const Text('Claude API キー'),
            subtitle: Text(
              apiKeys.hasClaudeKey ? '✅ 設定済み (フォールバック)' : '未設定',
              style: TextStyle(
                color: apiKeys.hasClaudeKey ? AppColors.accentGreen : AppColors.textMuted,
                fontSize: AppTypography.bodySmall.fontSize,
              ),
            ),
            trailing: const Icon(Icons.edit, color: AppColors.textMuted, size: 18),
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
                  ? 'Google AI Studio (https://aistudio.google.com) からキーを取得して入力してください'
                  : 'Anthropic コンソールからキーを取得して入力してください',
              style: TextStyle(fontSize: AppTypography.bodySmall.fontSize, color: AppColors.textMuted),
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
              child: Text('削除', style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
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
