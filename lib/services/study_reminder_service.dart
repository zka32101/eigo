import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_core/shared_core.dart'
    show
        NotificationContext,
        NotificationPlanNotifier,
        NotificationTone,
        SmartReminderScheduler;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

/// 学習リマインダー（ローカル通知）。shared_core の `SmartNotificationPlanner`
/// が決めた時刻・文面を、端末のローカル通知として予約する。
///
/// プラグインの初期化は既存の [NotificationService.init] に任せる
/// （二重 initialize しない）。学習するたびに予約し直す（cancel → 再予約）。
/// 予約するのは次の3件だけ:
/// - 翌日: 連続記録・復習の声かけ
/// - 3日後 / 7日後: 来なかったときの「おかえり」
class StudyReminderService {
  StudyReminderService._();
  static final StudyReminderService instance = StudyReminderService._();

  static const _enabledKey = 'app_reminder_enabled';
  static const _idNextDay = 7001;
  static const _idAfter3Days = 7002;
  static const _idAfter7Days = 7003;

  // FlutterLocalNotificationsPlugin() は同一のシングルトンを返す。
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _permissionAsked = false;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  /// 保護者が通知を ON/OFF する。OFF にすると予約済みの通知も消す。
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (enabled) {
      await NotificationService().init();
      await _requestPermission();
    } else {
      await cancelAll();
    }
  }

  Future<void> cancelAll() async {
    try {
      await NotificationService().init();
      for (final id in [_idNextDay, _idAfter3Days, _idAfter7Days]) {
        await _plugin.cancel(id);
      }
    } catch (e) {
      debugPrint('[Reminder] 取消をスキップ: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (_permissionAsked) return;
    _permissionAsked = true;
    await NotificationService().requestPermission();
  }

  /// 学習した直後に呼ぶ。[plan] は shared_core の通知計画（時刻・文面の元）。
  Future<void> reschedule({
    required NotificationPlanNotifier plan,
    required int streak,
    required int dueReviewTomorrow,
    NotificationTone tone = NotificationTone.standard,
    DateTime? now,
  }) async {
    try {
      if (!await isEnabled()) return;
      await NotificationService().init();
      await _requestPermission();

      final base = now ?? DateTime.now();
      final scheduler = SmartReminderScheduler(_plugin);

      Future<void> schedule(int id, int daysAway, NotificationContext ctx) =>
          scheduler.schedule(
            plan.planFor(ctx, tone: tone),
            notificationId: id,
            channelId: 'study_reminder_channel',
            channelName: '学習リマインダー',
            now: base.add(Duration(days: daysAway - 1)),
          );

      await schedule(
          _idNextDay,
          1,
          NotificationContext(
              currentStreak: streak,
              doneToday: true,
              dueReviewCount: dueReviewTomorrow));
      await schedule(_idAfter3Days, 3,
          const NotificationContext(daysAway: 3, doneToday: true));
      await schedule(_idAfter7Days, 7,
          const NotificationContext(daysAway: 7, doneToday: true));
    } catch (e) {
      debugPrint('[Reminder] 予約をスキップ: $e');
    }
  }
}
