import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/services/npc_event_service.dart';
import 'package:eigo/providers/npc_behavior_provider.dart';

final npcEventServiceProvider = Provider((ref) {
  return NPCEventService.getInstance();
});

/// NPC イベント統計
final npcEventStatisticsProvider =
    FutureProvider.family<EventStatistics, String>((ref, npcId) async {
  final service = ref.watch(npcEventServiceProvider);
  return service.generateStatistics(npcId);
});

/// ペンディングイベント
final pendingEventsProvider =
    FutureProvider.family<List<NPCEvent>, String>((ref, npcId) async {
  final service = ref.watch(npcEventServiceProvider);
  return service.getPendingEvents(npcId);
});

/// イベント履歴
final eventHistoryProvider =
    FutureProvider.family<List<EventLog>, String>((ref, npcId) async {
  final service = ref.watch(npcEventServiceProvider);
  return service.getEventHistory(npcId);
});

/// イベント管理 Notifier
final eventManagerProvider =
    StateNotifierProvider.family<EventManagerNotifier, void, String>(
  (ref, npcId) {
    final service = ref.watch(npcEventServiceProvider);
    return EventManagerNotifier(
      service: service,
      npcId: npcId,
    );
  },
);

class EventManagerNotifier extends StateNotifier<void> {
  final NPCEventService service;
  final String npcId;

  EventManagerNotifier({
    required this.service,
    required this.npcId,
  }) : super(null);

  void processEvent(String eventId) {
    service.processEvent(eventId);
    state = null;
  }

  void registerTrigger(EventTriggerDefinition trigger) {
    service.registerTrigger(trigger);
    state = null;
  }

  void deactivateTrigger(String triggerId) {
    service.deactivateTrigger(triggerId);
    state = null;
  }
}
