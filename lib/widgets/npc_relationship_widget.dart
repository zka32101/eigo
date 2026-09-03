import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_relationship_model.dart';
import 'package:eigo/providers/npc_relationship_provider.dart';

/// NPC関係表示ウィジェット
class NPCRelationshipWidget extends ConsumerWidget {
  final String npcId;
  final String npcName;
  final String npcEmoji;

  const NPCRelationshipWidget({
    Key? key,
    required this.npcId,
    required this.npcName,
    required this.npcEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(relationshipSummaryProvider(npcId));
    final status = ref.watch(relationshipStatusProvider(npcId));

    if (summary == null || status == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, status),
            const SizedBox(height: 16),
            _buildAffectionBar(context, summary),
            const SizedBox(height: 12),
            _buildStats(context, summary),
            const SizedBox(height: 12),
            _buildStatusIndicators(context, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RelationshipStatus status) {
    return Row(
      children: [
        Text(npcEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                npcName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                status.japanese,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status),
                    ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildAffectionBar(BuildContext context, RelationshipSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '好感度',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: summary.getProgressPercentage(),
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(summary.status),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${summary.affectionScore}/100',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '次のランク: +${summary.getPointsToNextStatus()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, RelationshipSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: '会話',
            value: summary.totalInteractions.toString(),
            icon: Icons.chat,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'ダイアログ',
            value: summary.unlockedDialoguesCount.toString(),
            icon: Icons.lock_open,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'アチーブ',
            value: summary.achievementsCount.toString(),
            icon: Icons.star,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(
      BuildContext context, RelationshipSummary summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          label: Text('最終: ${_formatTime(summary.lastInteractionTime)}'),
          avatar: Icon(
            Icons.access_time,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(RelationshipStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        status.english,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.stranger:
        return Colors.grey;
      case RelationshipStatus.acquaintance:
        return Colors.blue;
      case RelationshipStatus.friend:
        return Colors.green;
      case RelationshipStatus.goodFriend:
        return Colors.orange;
      case RelationshipStatus.bestFriend:
        return Colors.red;
      case RelationshipStatus.soulmate:
        return Colors.pink;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'まだ';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';
    return '${diff.inDays ~/ 7}週間前';
  }
}

/// 統計タイル
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

/// ダイアログチェーン進捗ウィジェット
class DialogueChainProgressWidget extends StatelessWidget {
  final String chainName;
  final double progress;
  final int unlockedCount;
  final int totalCount;

  const DialogueChainProgressWidget({
    Key? key,
    required this.chainName,
    required this.progress,
    required this.unlockedCount,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chainName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$unlockedCount/$totalCount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// マイルストーン表示ウィジェット
class MilestoneWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isAchieved;
  final int pointsNeeded;

  const MilestoneWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.isAchieved,
    required this.pointsNeeded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isAchieved ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isAchieved)
                  Icon(Icons.check_circle, color: Colors.green, size: 20)
                else
                  Icon(Icons.lock, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isAchieved) ...[
              const SizedBox(height: 8),
              Text(
                '+$pointsNeeded で達成',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.orange,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
