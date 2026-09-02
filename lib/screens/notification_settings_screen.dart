import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedTime = TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      // 設定時刻を変更
      if (mounted) {
        await ref.read(settingsProvider.notifier).setReminderTime(picked.hour, picked.minute);
      }
    }
  }

  Future<void> _setTimePreset(int hour, int minute) async {
    setState(() => _selectedTime = TimeOfDay(hour: hour, minute: minute));
    await ref.read(settingsProvider.notifier).setReminderTime(hour, minute);
  }

  Future<void> _toggleNotification(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      if (enabled) {
        // パーミッション確認
        final granted = await NotificationService().requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('通知許可が必要です')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }
      // Riverpod 経由で設定変更
      await ref.read(settingsProvider.notifier).setNotificationEnabled(
        enabled,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? '通知を有効にしました' : '通知を無効にしました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      final notif = NotificationService();
      await notif.init();
      await notif.showStreakAchievement(1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('テスト通知を送信しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 通知設定'),
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingMd,
        children: [
          // 通知の有効/無効トグル
          Card(
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '毎日の英語通知',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: settings.notificationEnabled,
                        onChanged: _isLoading ? null : _toggleNotification,
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '毎朝、ランダムな英語フレーズで練習を促します',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 時刻選択
          if (settings.notificationEnabled)
            Card(
              child: Padding(
                padding: AppSpacing.allPaddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '通知の時刻',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.verticalSpacerSm,
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule, color: AppColors.readingColor),
                      title: Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.readingColor,
                        ),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectTime,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      '例: 7:00 AM に毎日通知します',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      'クイック設定:',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        _PresetButton('朝7:00', 7, 0, _setTimePreset),
                        _PresetButton('昼12:00', 12, 0, _setTimePreset),
                        _PresetButton('夜19:00', 19, 0, _setTimePreset),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          AppSpacing.verticalSpacerLg,

          // テスト通知ボタン
          if (settings.notificationEnabled)
            ElevatedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('テスト通知を送信'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              ),
            ),
          AppSpacing.verticalSpacerLg,

          // 情報
          Card(
            color: AppColors.bgLight,
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 毎日の英語通知について',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '毎朝設定した時刻に、ランダムな英語フレーズと日本語ヒントが届きます。\n\n'
                    '• スピーキング練習\n'
                    '• リスニング練習\n'
                    '• 日常英会話フレーズ\n\n'
                    'など、様々なジャンルの英語フレーズが毎日変わります。',
                    style: AppTypography.bodySmall.copyWith(height: 1.6),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    '※ 通知を受け取るにはデバイスの通知許可が必要です',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final Function(int, int) onPressed;

  const _PresetButton(this.label, this.hour, this.minute, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(hour, minute),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withAlpha(25),
        foregroundColor: AppColors.primaryDark,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
      ),
      child: Text(label, style: AppTypography.bodySmall),
    );
  }
}
