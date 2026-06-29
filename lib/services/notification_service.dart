import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import '../data/notification_phrases_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  void Function(String?)? onNotificationTap;

  static const _channelId = 'eigo_kore_daily';
  static const _channelName = '英語コレ！毎日リマインダー';
  static const _notifId = 1001;
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinKey = 'reminder_min';
  static const _reminderEnabledKey = 'reminder_enabled';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleDailyReminder({
    int hour = 19,
    int minute = 0,
  }) async {
    await init();
    await _plugin.cancel(_notifId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final phrase = notificationPhrases[Random().nextInt(notificationPhrases.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      _notifId,
      '🎤 ${phrase['phrase']}',
      phrase['hint'],
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinKey, minute);
    await prefs.setBool(_reminderEnabledKey, true);
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(_notifId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, false);
  }

  Future<({bool enabled, int hour, int minute})> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      enabled: prefs.getBool(_reminderEnabledKey) ?? false,
      hour: prefs.getInt(_reminderHourKey) ?? 19,
      minute: prefs.getInt(_reminderMinKey) ?? 0,
    );
  }

  // ストリーク達成通知（即時）
  Future<void> showStreakAchievement(int days) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'eigo_kore_achievement',
      '英語コレ！達成通知',
      importance: Importance.defaultImportance,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      2000 + days,
      '🔥 $days日連続達成！',
      'すごい！毎日続けている証拠です。この調子で頑張ろう！',
      details,
    );
  }

  // バッジ獲得通知（即時）
  Future<void> showBadgeEarned(String badgeName, String emoji) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'eigo_kore_badge',
      '英語コレ！バッジ通知',
      importance: Importance.defaultImportance,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      3000,
      '$emoji バッジ獲得！',
      '「$badgeName」バッジを獲得しました！',
      details,
    );
  }

  TimeOfDay getDefaultReminderTime() => const TimeOfDay(hour: 19, minute: 0);
}
