import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/morning_notification_service.dart';

final morningNotificationServiceProvider = Provider((ref) {
  return MorningNotificationService();
});

final morningNotificationStateProvider = StateNotifierProvider<
    MorningNotificationStateNotifier,
    MorningNotificationState>((ref) {
  final service = ref.watch(morningNotificationServiceProvider);
  return MorningNotificationStateNotifier(service);
});

class MorningNotificationState {
  final bool isEnabled;
  final int hour;
  final int minute;
  final String? error;

  const MorningNotificationState({
    this.isEnabled = false,
    this.hour = 7,
    this.minute = 0,
    this.error,
  });

  String get timeLabel => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  MorningNotificationState copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    String? error,
  }) {
    return MorningNotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      error: error ?? this.error,
    );
  }
}

class MorningNotificationStateNotifier
    extends StateNotifier<MorningNotificationState> {
  final MorningNotificationService _service;

  MorningNotificationStateNotifier(this._service)
      : super(const MorningNotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.initialize();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize notifications: $e');
    }
  }

  Future<void> enableMorningNotification(int hour, int minute) async {
    try {
      await _service.scheduleMorningNotification(hour: hour, minute: minute);
      state = MorningNotificationState(
        isEnabled: true,
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to schedule notification: $e');
    }
  }

  Future<void> disableMorningNotification() async {
    try {
      await _service.cancelMorningNotification();
      state = state.copyWith(isEnabled: false, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel notification: $e');
    }
  }

  Future<void> updateTime(int hour, int minute) async {
    try {
      if (state.isEnabled) {
        await _service.scheduleMorningNotification(hour: hour, minute: minute);
      }
      state = state.copyWith(hour: hour, minute: minute, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update time: $e');
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await _service.sendTestNotification();
    } catch (e) {
      state = state.copyWith(error: 'Failed to send test notification: $e');
    }
  }
}
