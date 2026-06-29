import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/morning_phrase_data.dart';

class MorningNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'morning_english_channel';
  static const String _channelName = 'Morning English';
  static const int _notificationId = 1;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Daily morning English phrases',
            importance: Importance.defaultImportance,
            enableVibration: true,
            playSound: true,
          ),
        );
  }

  Future<void> scheduleMorningNotification({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final phrase = _getRandomPhrase();

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _notificationId,
        '🌅 Morning English',
        phrase.english,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily morning English phrases',
            importance: Importance.defaultImportance,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            styleInformation: BigTextStyleInformation(
              '${phrase.english}\n\n${phrase.japanese}',
              contentTitle: '🌅 Morning English',
              summaryText: phrase.category,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelMorningNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(_notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendTestNotification() async {
    final phrase = _getRandomPhrase();
    try {
      await _flutterLocalNotificationsPlugin.show(
        _notificationId,
        '🌅 Morning English (Test)',
        phrase.english,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily morning English phrases',
            importance: Importance.defaultImportance,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              '${phrase.english}\n\n${phrase.japanese}',
              contentTitle: '🌅 Morning English',
              summaryText: phrase.category,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  MorningPhrase _getRandomPhrase() {
    final random = Random();
    return morningPhrases[random.nextInt(morningPhrases.length)];
  }
}
