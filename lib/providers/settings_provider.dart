import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class AppSettings {
  final bool soundEnabled;
  final bool ttsEnabled;
  final double ttsSpeed;          // 0.3 - 1.0
  final bool notificationEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool autoPlayListening;   // リスニング問題の自動再生
  final bool showPhonetics;       // 発音記号を表示
  final String childName;         // 子どもの名前（親ダッシュボード用）

  const AppSettings({
    this.soundEnabled = true,
    this.ttsEnabled = true,
    this.ttsSpeed = 0.5,
    this.notificationEnabled = false,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.autoPlayListening = true,
    this.showPhonetics = true,
    this.childName = '',
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? ttsEnabled,
    double? ttsSpeed,
    bool? notificationEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? autoPlayListening,
    bool? showPhonetics,
    String? childName,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      autoPlayListening: autoPlayListening ?? this.autoPlayListening,
      showPhonetics: showPhonetics ?? this.showPhonetics,
      childName: childName ?? this.childName,
    );
  }

  String get reminderTimeLabel {
    final h = reminderHour.toString().padLeft(2, '0');
    final m = reminderMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      ttsEnabled: prefs.getBool('tts_enabled') ?? true,
      ttsSpeed: prefs.getDouble('tts_speed') ?? 0.5,
      notificationEnabled: prefs.getBool('notification_enabled') ?? false,
      reminderHour: prefs.getInt('reminder_hour') ?? 19,
      reminderMinute: prefs.getInt('reminder_min') ?? 0,
      autoPlayListening: prefs.getBool('auto_play_listening') ?? true,
      showPhonetics: prefs.getBool('show_phonetics') ?? true,
      childName: prefs.getString('child_name') ?? '',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', state.soundEnabled);
    await prefs.setBool('tts_enabled', state.ttsEnabled);
    await prefs.setDouble('tts_speed', state.ttsSpeed);
    await prefs.setBool('notification_enabled', state.notificationEnabled);
    await prefs.setInt('reminder_hour', state.reminderHour);
    await prefs.setInt('reminder_min', state.reminderMinute);
    await prefs.setBool('auto_play_listening', state.autoPlayListening);
    await prefs.setBool('show_phonetics', state.showPhonetics);
    await prefs.setString('child_name', state.childName);
  }

  Future<void> setSoundEnabled(bool v) async {
    state = state.copyWith(soundEnabled: v);
    await _save();
  }

  Future<void> setTtsEnabled(bool v) async {
    state = state.copyWith(ttsEnabled: v);
    await _save();
  }

  Future<void> setTtsSpeed(double v) async {
    state = state.copyWith(ttsSpeed: v.clamp(0.3, 1.0));
    await _save();
  }

  Future<void> setNotificationEnabled(bool v, {int? hour, int? minute}) async {
    final h = hour ?? state.reminderHour;
    final m = minute ?? state.reminderMinute;
    state = state.copyWith(notificationEnabled: v, reminderHour: h, reminderMinute: m);
    await _save();

    final notif = NotificationService();
    if (v) {
      await notif.scheduleDailyReminder(hour: h, minute: m);
    } else {
      await notif.cancelReminder();
    }
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _save();
    if (state.notificationEnabled) {
      await NotificationService().scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  Future<void> setAutoPlayListening(bool v) async {
    state = state.copyWith(autoPlayListening: v);
    await _save();
  }

  Future<void> setShowPhonetics(bool v) async {
    state = state.copyWith(showPhonetics: v);
    await _save();
  }

  Future<void> setChildName(String name) async {
    state = state.copyWith(childName: name);
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
