import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('笞呻ｸ・縺帙▲縺ｦ縺・),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingLg,
        children: [
          // 繝励Λ繝ｳ繝舌ャ繧ｸ
          _PlanBadgeCard(purchase: purchase),
          AppSpacing.verticalSpacerMd,

          // 蟄舌←繧ゅ・蜷榊燕
          _ChildNameCard(settings: settings, ref: ref),
          AppSpacing.verticalSpacerMd,

          _SectionHeader('蟄ｦ鄙定ｨｭ螳・),
          _SoundToggle(settings: settings, ref: ref),
          _TTSSpeedCard(settings: settings, ref: ref),
          _AutoPlayToggle(settings: settings, ref: ref),
          _PhoneticToggle(settings: settings, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('騾夂衍險ｭ螳・),
          _NotificationCard(settings: settings, ref: ref),
          _MorningEnglishCard(morningNotification: morningNotification, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('AI 繧ｭ繝ｼ險ｭ螳・),
          _ApiKeysCard(apiKeys: apiKeys, ref: ref),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('繧｢繧ｫ繧ｦ繝ｳ繝・),
          _SettingsTile(
            icon: Icons.star,
            color: AppColors.accentOrange,
            label: '繝励Λ繝ｳ繧偵い繝・・繧ｰ繝ｬ繝ｼ繝・,
            subtitle: purchase.planDisplayName,
            onTap: () => Navigator.of(context).pushNamed('/upgrade'),
          ),
          _SettingsTile(
            icon: Icons.restore,
            color: AppColors.primary,
            label: '雉ｼ蜈･繧貞ｾｩ蜈・,
            subtitle: '莉･蜑阪・雉ｼ蜈･繧貞ｾｩ蜈・＠縺ｾ縺・,
            onTap: () async {
              await ref.read(purchaseProvider.notifier).restore();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('雉ｼ蜈･繧貞ｾｩ蜈・＠縺ｾ縺励◆')),
                );
              }
            },
          ),
          _SettingsTile(
            icon: Icons.bar_chart,
            color: AppColors.accentGreen,
            label: '隕ｪ蜷代￠繝繝・す繝･繝懊・繝・,
            subtitle: '蟄ｦ鄙定ｩｳ邏ｰ繝ｻ繧ｹ繝斐・繧ｭ繝ｳ繧ｰ蛻・梵',
            onTap: () => Navigator.of(context).pushNamed('/parent'),
          ),
          _SettingsTile(
            icon: Icons.emoji_events,
            color: AppColors.accentOrange,
            label: '繝舌ャ繧ｸ荳隕ｧ',
            subtitle: '${progress.clearedStages.length}繧ｹ繝・・繧ｸ繧ｯ繝ｪ繧｢貂医∩',
            onTap: () => Navigator.of(context).pushNamed('/badges'),
          ),

          AppSpacing.verticalSpacerMd,
          _SectionHeader('縺昴・莉・),
          _SettingsTile(
            icon: Icons.privacy_tip,
            color: AppColors.textMuted,
            label: '繝励Λ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ',
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
          _SettingsTile(
            icon: Icons.info,
            color: AppColors.textMuted,
            label: '繧｢繝励Μ縺ｫ縺､縺・※',
            subtitle: '繝舌・繧ｸ繝ｧ繝ｳ 1.1.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '闍ｱ隱槭さ繝ｬ・・,
              applicationVersion: '1.1.0',
              applicationLegalese: 'ﾂｩ 2026 ',
            ),
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

// 笏笏笏 Plan Badge 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
                isFree ? '・' : '箝・,
                style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
              ),
            ),
            AppSpacing.horizontalSpacerSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '迴ｾ蝨ｨ縺ｮ繝励Λ繝ｳ: ${purchase.planDisplayName}',
                    style: AppTypography.labelLarge,
                  ),
                  if (isFree)
                    const Text(
                      '2騾ｱ髢鍋┌譁吶〒Pro繧偵♀隧ｦ縺励￥縺縺輔＞・・,
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
                child: const Text('隧ｦ縺・),
              ),
          ],
        ),
      ),
    );
  }
}

// 笏笏笏 Child Name 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

class _ChildNameCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;
  const _ChildNameCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.child_care, color: AppColors.primary),
        title: const Text('蟄舌←繧ゅ・蜷榊燕'),
        subtitle: Text(
          settings.childName.isEmpty ? '譛ｪ險ｭ螳夲ｼ医ち繝・・縺励※險ｭ螳夲ｼ・ : settings.childName,
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
        title: const Text('蟄舌←繧ゅ・蜷榊燕繧定ｨｭ螳・),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: '萓・ 縺溘ｍ縺・,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setChildName(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('菫晏ｭ・),
          ),
        ],
      ),
    );
  }
}

// 笏笏笏 Sound Toggle 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
        title: const Text('繧ｵ繧ｦ繝ｳ繝・),
        subtitle: const Text('蜉ｹ譫憺浹縺ｨTTS繧呈怏蜉ｹ縺ｫ縺吶ｋ'),
        value: settings.soundEnabled,
        onChanged: (v) => ref.read(settingsProvider.notifier).setSoundEnabled(v),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

// 笏笏笏 TTS Speed 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
                Text('TTS逋ｺ髻ｳ騾溷ｺｦ', style: AppTypography.labelLarge),
                const Spacer(),
                Text(
                  settings.ttsSpeed < 0.4 ? '繧・▲縺上ｊ' : settings.ttsSpeed > 0.7 ? '騾溘＞' : '譎ｮ騾・,
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
                Text('繧・▲縺上ｊ', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                Text('騾溘＞', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 笏笏笏 Auto Play Toggle 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
        title: const Text('繝ｪ繧ｹ繝九Φ繧ｰ閾ｪ蜍募・逕・),
        subtitle: const Text('蝠城｡後′蟋九∪縺｣縺溘ｉ閾ｪ蜍輔〒闍ｱ隱槭ｒ蜀咲函'),
        value: settings.autoPlayListening,
        onChanged: (v) => ref.read(settingsProvider.notifier).setAutoPlayListening(v),
        activeThumbColor: AppColors.listeningColor,
      ),
    );
  }
}

// 笏笏笏 Phonetic Toggle 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
        title: const Text('逋ｺ髻ｳ險伜捷繧定｡ｨ遉ｺ'),
        subtitle: const Text('IPA 逋ｺ髻ｳ險伜捷繧貞撫鬘後き繝ｼ繝峨↓陦ｨ遉ｺ'),
        value: settings.showPhonetics,
        onChanged: (v) => ref.read(settingsProvider.notifier).setShowPhonetics(v),
        activeThumbColor: AppColors.accentPurple,
      ),
    );
  }
}

// 笏笏笏 Notification Card 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
            title: const Text('豈取律繝ｪ繝槭う繝ｳ繝繝ｼ'),
            subtitle: const Text('豈取律縺ｮ蟄ｦ鄙偵ｒ騾夂衍縺ｧ繧ｵ繝昴・繝・),
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
                '繝ｪ繝槭う繝ｳ繝繝ｼ譎ょ綾: ${settings.reminderTimeLabel}',
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

// 笏笏笏 Helpers 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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

// 笏笏笏 Morning English Card 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
            title: const Text('譛晁恭隱樣夂衍'),
            subtitle: const Text('豈取悃繝ｩ繝ｳ繝繝縺ｪ闍ｱ隱槭ヵ繝ｬ繝ｼ繧ｺ繧帝夂衍'),
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
                '騾夂衍譎ょ綾: ${morningNotification.timeLabel}',
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
                  label: const Text('繝・せ繝磯夂衍繧帝∽ｿ｡'),
                  onPressed: () async {
                    await ref
                        .read(morningNotificationStateProvider.notifier)
                        .sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('繝・せ繝磯夂衍繧帝∽ｿ｡縺励∪縺励◆'),
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

// 笏笏笏 API Keys Card 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

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
            title: const Text('Gemini API 繧ｭ繝ｼ'),
            subtitle: Text(
              apiKeys.hasGeminiKey ? '笨・險ｭ螳壽ｸ医∩' : '譛ｪ險ｭ螳・,
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
            title: const Text('Claude API 繧ｭ繝ｼ'),
            subtitle: Text(
              apiKeys.hasClaudeKey ? '笨・險ｭ螳壽ｸ医∩ (繝輔か繝ｼ繝ｫ繝舌ャ繧ｯ)' : '譛ｪ險ｭ螳・,
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
        title: Text('$provider API 繧ｭ繝ｼ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider == 'Gemini'
                  ? 'Google AI Studio (https://aistudio.google.com) 縺九ｉ蜿門ｾ励＠縺溘く繝ｼ繧貞・蜉帙＠縺ｦ縺上□縺輔＞'
                  : 'Anthropic 繧ｳ繝ｳ繧ｽ繝ｼ繝ｫ縺九ｉ蜿門ｾ励＠縺溘く繝ｼ繧貞・蜉帙＠縺ｦ縺上□縺輔＞',
              style: TextStyle(fontSize: AppTypography.bodySmall.fontSize, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'API 繧ｭ繝ｼ繧貞・蜉・,
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
              child: Text('蜑企勁', style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ')),
          ElevatedButton(
            onPressed: () {
              if (provider == 'Gemini') {
                ref.read(aiApiKeysProvider.notifier).setGeminiKey(ctrl.text.trim());
              } else {
                ref.read(aiApiKeysProvider.notifier).setClaudeKey(ctrl.text.trim());
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$provider 繧ｭ繝ｼ繧剃ｿ晏ｭ倥＠縺ｾ縺励◆')),
              );
            },
            child: const Text('菫晏ｭ・),
          ),
        ],
      ),
    );
  }
}

