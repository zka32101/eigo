import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/providers/npc_event_provider.dart';

/// NPC イベント通知スクリーン
class NPCEventNotificationScreen extends ConsumerWidget {
  final String npcId;
  final String npcName;

  const NPCEventNotificationScreen({
    required this.npcId,
    required this.npcName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingEventsProvider(npcId));
    final statsAsync = ref.watch(npcEventStatisticsProvider(npcId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$npcName - Events'),
        centerTitle: true,
      ),
      body: statsAsync.when(
        data: (stats) => pendingAsync.when(
          data: (pendingEvents) =>
              _buildContent(context, ref, pendingEvents, stats),
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
    WidgetRef ref,
    List<NPCEvent> pendingEvents,
    EventStatistics stats,
  ) {
    return Column(
      children: [
        // イベント統計
        _buildStatsBar(stats),

        // イベントリスト
        Expanded(
          child: pendingEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pending events',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pendingEvents.length,
                  itemBuilder: (context, index) {
                    final event = pendingEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildEventCard(
                        context,
                        ref,
                        event,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(EventStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            '${stats.totalEvents}',
            Icons.event,
          ),
          _buildStatItem(
            'Pending',
            '${stats.pendingEvents}',
            Icons.hourglass_bottom,
          ),
          _buildStatItem(
            'Processed',
            '${stats.processedEvents}',
            Icons.done_all,
          ),
          _buildStatItem(
            'Affection',
            '+${stats.totalAffectionFromEvents}',
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    NPCEvent event,
  ) {
    final priorityColor = _getPriorityColor(event.priority);
    final priorityIcon = _getPriorityIcon(event.priority);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: priorityColor.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            _showEventDetail(context, ref, event);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 優先度アイコン
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        priorityIcon,
                        color: priorityColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // イベント情報
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.eventType.english,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 説明
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // 報酬セクション
                if (event.reward != null) ...[
                  _buildRewardSection(event.reward!),
                  const SizedBox(height: 12),
                ],

                // アクションボタン
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          _processEvent(ref, event);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Process'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          _showEventDetail(context, ref, event);
                        },
                        icon: const Icon(Icons.info),
                        label: const Text('Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardSection(EventReward reward) {
    final rewards = <Widget>[];

    if (reward.affectionBonus > 0) {
      rewards.add(
        _buildRewardBadge(
          'Icons.favorite',
          '+${reward.affectionBonus} Affection',
          Colors.red,
        ),
      );
    }

    if (reward.xpReward > 0) {
      rewards.add(
        _buildRewardBadge(
          'Icons.star',
          '+${reward.xpReward} XP',
          Colors.amber,
        ),
      );
    }

    if (reward.goldReward > 0) {
      rewards.add(
        _buildRewardBadge(
          'Icons.monetization_on',
          '+${reward.goldReward} Gold',
          Colors.orange,
        ),
      );
    }

    if (reward.itemRewardIds != null && reward.itemRewardIds!.isNotEmpty) {
      rewards.add(
        _buildRewardBadge(
          'Icons.card_giftcard',
          '${reward.itemRewardIds!.length} Item(s)',
          Colors.purple,
        ),
      );
    }

    if (reward.locationUnlockId != null) {
      rewards.add(
        _buildRewardBadge(
          'Icons.location_on',
          'Location Unlocked',
          Colors.teal,
        ),
      );
    }

    if (reward.skillRewardId != null) {
      rewards.add(
        _buildRewardBadge(
          'Icons.school',
          'Skill Learned',
          Colors.indigo,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rewards,
    );
  }

  Widget _buildRewardBadge(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.critical:
        return Colors.red;
      case EventPriority.high:
        return Colors.orange;
      case EventPriority.normal:
        return Colors.blue;
      case EventPriority.low:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(EventPriority priority) {
    switch (priority) {
      case EventPriority.critical:
        return Icons.priority_high;
      case EventPriority.high:
        return Icons.warning;
      case EventPriority.normal:
        return Icons.info;
      case EventPriority.low:
        return Icons.arrow_downward;
    }
  }

  void _showEventDetail(
    BuildContext context,
    WidgetRef ref,
    NPCEvent event,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // イベント情報
              _buildDetailRow('Type', event.eventType.english),
              _buildDetailRow('Priority', event.priority.english),
              _buildDetailRow(
                'Status',
                event.isProcessed ? 'Processed' : 'Pending',
              ),
              const Divider(),

              // 説明
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(event.description),
              const SizedBox(height: 12),

              // 報酬
              if (event.reward != null) ...[
                const Text(
                  'Rewards',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                _buildRewardSection(event.reward!),
                const SizedBox(height: 12),
              ],

              // タイムスタンプ
              Text(
                'Triggered: ${event.triggeredAt}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!event.isProcessed)
            TextButton.icon(
              onPressed: () {
                _processEvent(ref, event);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Process'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _processEvent(WidgetRef ref, NPCEvent event) {
    final notifier = ref.read(eventManagerProvider(npcId).notifier);
    notifier.processEvent(event.eventId);

    ScaffoldMessenger.of(
      ref.context,
    ).showSnackBar(
      SnackBar(
        content: Text('Event "${event.title}" processed!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
