import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.id ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('通知設定')),
        body: const Center(child: Text('ユーザーが見つかりません')),
      );
    }

    final preferencesAsync = ref.watch(notificationPreferencesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 通知設定'),
        elevation: 0,
      ),
      body: preferencesAsync.when(
        data: (preferences) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Main notification toggles
                _SettingSection(
                  title: '通知の種類',
                  children: [
                    _ToggleSetting(
                      label: 'チャレンジ通知',
                      emoji: '🏆',
                      value: preferences.enableChallengeReminders,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableChallengeReminders: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'ペット通知',
                      emoji: '🐾',
                      value: preferences.enablePetNotifications,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enablePetNotifications: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'ビデオ推奨',
                      emoji: '🎬',
                      value: preferences.enableVideoRecommendations,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableVideoRecommendations: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'フレンドチャレンジ',
                      emoji: '👥',
                      value: preferences.enableFriendChallenges,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableFriendChallenges: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'アチーブメント',
                      emoji: '🏅',
                      value: preferences.enableAchievements,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableAchievements: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'デイリークエスト',
                      emoji: '📋',
                      value: preferences.enableDailyQuests,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableDailyQuests: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'ストリーク達成',
                      emoji: '🔥',
                      value: preferences.enableStreakMilestones,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableStreakMilestones: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'ショップ新商品',
                      emoji: '🛍️',
                      value: preferences.enableShopUpdates,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableShopUpdates: value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerLg,

                // Delivery method toggles
                _SettingSection(
                  title: '配信方法',
                  children: [
                    _ToggleSetting(
                      label: 'プッシュ通知',
                      emoji: '📱',
                      value: preferences.enablePushNotifications,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enablePushNotifications: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'メール通知',
                      emoji: '📧',
                      value: preferences.enableEmailNotifications,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableEmailNotifications: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: '音通知',
                      emoji: '🔊',
                      value: preferences.enableSoundNotifications,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableSoundNotifications: value,
                          ),
                        );
                      },
                    ),
                    _ToggleSetting(
                      label: 'バイブレーション',
                      emoji: '📳',
                      value: preferences.enableVibrationNotifications,
                      onChanged: (value) {
                        _updatePreferences(
                          ref,
                          userId,
                          preferences.copyWith(
                            enableVibrationNotifications: value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerLg,

                // Quiet hours
                _SettingSection(
                  title: '通知をお休みする時間',
                  children: [
                    Padding(
                      padding: AppSpacing.allPaddingMd,
                      child: Text(
                        '以下の時間帯は通知が届きません',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerXl,
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  void _updatePreferences(
    WidgetRef ref,
    String userId,
    NotificationPreference preferences,
  ) {
    ref.read(updatePreferencesActionProvider(preferences));
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalSpacerMd,
          Card(
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String label;
  final String emoji;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    required this.emoji,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allPaddingMd,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                AppSpacing.horizontalSpacerMd,
                Text(label),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
