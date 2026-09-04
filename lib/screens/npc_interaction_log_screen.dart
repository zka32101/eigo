import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/providers/npc_dialogue_provider.dart';
import 'package:eigo/models/npc_dialogue_model.dart';

/// NPC 相互作用ログスクリーン
class NPCInteractionLogScreen extends ConsumerWidget {
  final String npcId;
  final String npcName;

  const NPCInteractionLogScreen({
    required this.npcId,
    required this.npcName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(eventHistoryProvider(npcId));
    final statsAsync = ref.watch(npcEventStatisticsProvider(npcId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$npcName - Interaction Log'),
        centerTitle: true,
      ),
      body: statsAsync.when(
        data: (stats) => historyAsync.when(
          data: (history) => _buildContent(context, history, stats),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err'),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<EventLog> history,
    EventStatistics stats,
  ) {
    return Column(
      children: [
        // サマリーカード
        _buildSummaryCard(stats),

        // ログリスト
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No interactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = history[history.length - 1 - index]; // 逆順
                    return _buildLogTile(context, log);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(EventStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat(
                'Total Events',
                '${stats.totalEvents}',
                Icons.event,
              ),
              _buildSummaryStat(
                'Processed',
                '${stats.processedEvents}',
                Icons.check_circle,
              ),
              _buildSummaryStat(
                'Pending',
                '${stats.pendingEvents}',
                Icons.schedule,
              ),
              _buildSummaryStat(
                'Affection',
                '+${stats.totalAffectionFromEvents}',
                Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, EventLog log) {
    return InkWell(
      onTap: () {
        _showLogDetail(context, log);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventTypeIcon(log.eventType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.eventType.english,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(log.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                if (log.metadata != null && log.metadata!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.triggerType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeIcon(EventType eventType) {
    IconData icon;
    Color color;

    switch (eventType) {
      case EventType.dialogue_triggered:
        icon = Icons.chat;
        color = Colors.blue;
        break;
      case EventType.relationship_milestone:
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case EventType.mood_changed:
        icon = Icons.emoji_emotions;
        color = Colors.orange;
        break;
      case EventType.quest_given:
        icon = Icons.assignment;
        color = Colors.purple;
        break;
      case EventType.quest_completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case EventType.location_unlocked:
        icon = Icons.location_on;
        color = Colors.teal;
        break;
      case EventType.skill_learned:
        icon = Icons.school;
        color = Colors.indigo;
        break;
      case EventType.item_received:
        icon = Icons.card_giftcard;
        color = Colors.pink;
        break;
      case EventType.custom_event:
        icon = Icons.star;
        color = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _showLogDetail(BuildContext context, EventLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log.eventType.english),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Message',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(log.message),
            const SizedBox(height: 12),
            const Text(
              'Trigger Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(log.triggerType),
            const SizedBox(height: 12),
            const Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              log.timestamp.toString(),
              style: const TextStyle(fontSize: 12),
            ),
            if (log.metadata != null && log.metadata!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Metadata',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              ...log.metadata!.entries.map((e) {
                return Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(fontSize: 11),
                );
              }).toList(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
