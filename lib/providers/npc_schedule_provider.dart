import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_schedule_model.dart';
import 'package:eigo/services/npc_schedule_service.dart';

/// NPC スケジュール管理プロバイダー
final npcScheduleServiceProvider = Provider<NPCScheduleService>((ref) {
  return NPCScheduleService.getInstance();
});

/// NPCスケジュールプロバイダー (StateNotifier)
class NPCScheduleNotifier extends StateNotifier<AsyncValue<NPCSchedule>> {
  final NPCScheduleService service;

  NPCScheduleNotifier(this.service, NPCSchedule initialSchedule)
      : super(AsyncValue.data(initialSchedule));

  /// 利用可能性を更新
  Future<void> updateAvailability(
    String npcId,
    List<DayPattern> weeklyPattern,
    List<SeasonalPattern> seasonalPatterns,
  ) async {
    final currentSchedule = state.maybeWhen(
      data: (schedule) => schedule,
      orElse: () => null,
    );

    if (currentSchedule != null) {
      final updated = service.updateSchedule(
        currentSchedule,
        weeklyPattern,
        seasonalPatterns,
      );
      state = AsyncValue.data(updated);
    }
  }

  /// スケジュールをリセット
  void resetSchedule() {
    state = state.whenData((schedule) => service.resetSchedule(schedule));
  }

  /// 季節調整を適用
  void applySeasonalAdjustments(Season season) {
    state = state.whenData((schedule) =>
        service.applySeasonalAdjustments(schedule, season));
  }
}

/// NPCスケジュール管理プロバイダー (StateNotifierProvider.family)
final npcScheduleProvider = StateNotifierProvider.family<
    NPCScheduleNotifier,
    AsyncValue<NPCSchedule>,
    String>((ref, npcId) {
  final service = ref.watch(npcScheduleServiceProvider);

  // 初期スケジュールを作成（本来はDBから取得）
  final initialSchedule = service.initializeSchedule(
    npcId,
    [],
    [],
    [],
  );

  return NPCScheduleNotifier(service, initialSchedule);
});

/// NPCの可用性プロバイダー
final npcAvailabilityProvider = Provider.family<
    AsyncValue<NPCAvailability>,
    String>((ref, npcId) {
  final schedule = ref.watch(npcScheduleProvider(npcId));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.getAvailability(s, DateTime.now()));
});

/// NPCが特定時刻で利用可能か確認
final npcIsAvailableAtProvider = Provider.family<
    AsyncValue<bool>,
    (String npcId, DateTime dateTime)>((ref, params) {
  final schedule = ref.watch(npcScheduleProvider(params.$1));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.isAvailableAt(s, params.$2));
});

/// NPCの週間スケジュールプロバイダー
final npcWeeklyScheduleProvider = Provider.family<
    AsyncValue<Map<DayOfWeek, List<NPCBusinessHours>>>,
    String>((ref, npcId) {
  final schedule = ref.watch(npcScheduleProvider(npcId));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.getWeeklySchedule(s));
});

/// 次に会える時間プロバイダー
final npcNextMeetTimeProvider = Provider.family<
    AsyncValue<DateTime?>,
    (String npcId, String? preferredLocationId)>((ref, params) {
  final schedule = ref.watch(npcScheduleProvider(params.$1));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.getNextMeetTime(s, DateTime.now(), params.$2));
});

/// 次に会えない時間プロバイダー
final npcNextUnavailableTimeProvider = Provider.family<
    AsyncValue<DateTime?>,
    String>((ref, npcId) {
  final schedule = ref.watch(npcScheduleProvider(npcId));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.getNextUnavailableTime(s, DateTime.now()));
});

/// スケジュール要約プロバイダー
final schedulesSummaryProvider = Provider.family<
    AsyncValue<ScheduleSummary>,
    String>((ref, npcId) {
  final schedule = ref.watch(npcScheduleProvider(npcId));
  final service = ref.watch(npcScheduleServiceProvider);

  return schedule.whenData((s) =>
      service.generateSummary(s));
});

/// 複数NPCの利用可能性比較プロバイダー
final npcAvailabilityComparisonProvider = Provider.family<
    AsyncValue<List<(String, double)>>,
    (List<NPCSchedule>, DateTime)>((ref, params) {
  final service = ref.watch(npcScheduleServiceProvider);

  return AsyncValue.data(
      service.compareAvailability(params.$1, params.$2));
});
