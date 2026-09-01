import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

/// 通知設定を管理
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const String _storageKey = 'eigo_kore_notification_settings';

  NotificationSettingsNotifier()
      : super(NotificationSettings(lastUpdated: DateTime.now())) {
    _loadSettings();
  }

  /// 設定をロード
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = NotificationSettings.fromJson(json);
      } catch (e) {
        print('Error loading notification settings: $e');
      }
    }
  }

  /// 設定を保存
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 日常リマインダーを有効/無効にする
  Future<void> setDailyRemindersEnabled(bool enabled) async {
    state = state.copyWith(
      dailyRemindersEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// 日常リマインダー時間を変更
  Future<void> setDailyReminderHour(int hour) async {
    state = state.copyWith(
      dailyReminderHour: hour,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// ストリークリマインダーを有効/無効にする
  Future<void> setStreakRemindersEnabled(bool enabled) async {
    state = state.copyWith(
      streakRemindersEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// ストリークリマインダー時間を変更
  Future<void> setStreakReminderHour(int hour) async {
    state = state.copyWith(
      streakReminderHour: hour,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// アチーブメント通知を有効/無効にする
  Future<void> setAchievementNotifications(bool enabled) async {
    state = state.copyWith(
      achievementNotifications: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// フレンド通知を有効/無効にする
  Future<void> setFriendNotifications(bool enabled) async {
    state = state.copyWith(
      friendNotifications: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// プロモーション通知を有効/無効にする
  Future<void> setPromotionalNotifications(bool enabled) async {
    state = state.copyWith(
      promotionalNotifications: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// 音声を有効/無効にする
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(
      soundEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }

  /// 振動を有効/無効にする
  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(
      vibrationEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await _saveSettings();
  }
}

/// 通知履歴を管理
final notificationHistoryProvider =
    StateNotifierProvider<NotificationHistoryNotifier, List<NotificationRecord>>((ref) {
  return NotificationHistoryNotifier();
});

class NotificationHistoryNotifier extends StateNotifier<List<NotificationRecord>> {
  static const String _storageKey = 'eigo_kore_notification_history';

  NotificationHistoryNotifier() : super([]) {
    _loadHistory();
  }

  /// 履歴をロード
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items = decoded
            .map((json) => NotificationRecord.fromJson(json as Map<String, dynamic>))
            .toList();
        state = items;
      } catch (e) {
        print('Error loading notification history: $e');
      }
    }
  }

  /// 履歴を保存
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// 通知を記録
  Future<void> recordNotification(NotificationRecord notification) async {
    state = [...state, notification];
    await _saveHistory();
  }

  /// 通知を既読にする
  Future<void> markAsRead(String notificationId) async {
    final index = state.indexWhere((n) => n.notificationId == notificationId);
    if (index >= 0) {
      final notification = state[index];
      state = [
        ...state.sublist(0, index),
        notification.copyWith(isRead: true),
        ...state.sublist(index + 1),
      ];
      await _saveHistory();
    }
  }

  /// すべて既読にする
  Future<void> markAllAsRead() async {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    await _saveHistory();
  }

  /// 通知を削除
  Future<void> deleteNotification(String notificationId) async {
    state = state.where((n) => n.notificationId != notificationId).toList();
    await _saveHistory();
  }

  /// 未読数を取得
  int getUnreadCount() {
    return state.where((n) => !n.isRead).length;
  }

  /// 未読通知を取得
  List<NotificationRecord> getUnreadNotifications() {
    return state.where((n) => !n.isRead).toList();
  }

  /// タイプ別通知を取得
  List<NotificationRecord> getNotificationsByType(NotificationType type) {
    return state.where((n) => n.type == type).toList();
  }
}
