import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin moderation panel
class AdminModerationPanelScreen extends ConsumerWidget {
  const AdminModerationPanelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モデレーション管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showIssueModerationDialog(context, ref),
            tooltip: 'アクション追加',
          ),
        ],
      ),
      body: _ModerationListView(),
    );
  }

  void _showIssueModerationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _IssueModerationDialog(),
    );
  }
}

/// Moderation list view
class _ModerationListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(activeModerationActionsProvider);

    return actionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (actions) {
        if (actions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'アクティブなモデレーションアクションなし',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _ModerationActionCard(action: actions[index]);
          },
        );
      },
    );
  }
}

/// Moderation action card
class _ModerationActionCard extends StatelessWidget {
  final ModerationAction action;

  const _ModerationActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = _getActionColor(action.actionType);
    final daysLeft = action.expiresAt != null
        ? action.expiresAt!.difference(DateTime.now()).inDays
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ユーザーID: ${action.userId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.reason,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(_getActionLabel(action.actionType)),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '作成者: ${action.actionBy ?? "不明"}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '作成日: ${_formatDate(action.createdAt)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (daysLeft != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '残り日数: $daysLeft日',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: daysLeft <= 3 ? Colors.red : null,
                            ),
                      ),
                    ],
                  ],
                ),
                if (action.notes != null)
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => _showNotesDialog(context, action.notes!),
                    tooltip: 'ノート表示',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'warning':
        return Colors.orange;
      case 'mute':
        return Colors.blue;
      case 'ban':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getActionLabel(String actionType) {
    switch (actionType) {
      case 'warning':
        return '警告';
      case 'mute':
        return 'ミュート';
      case 'ban':
        return 'バン';
      default:
        return actionType;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _showNotesDialog(BuildContext context, String notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ノート'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

/// Issue moderation dialog
class _IssueModerationDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_IssueModerationDialog> createState() =>
      _IssueModerationDialogState();
}

class _IssueModerationDialogState
    extends ConsumerState<_IssueModerationDialog> {
  late TextEditingController userIdController;
  late TextEditingController reasonController;
  late TextEditingController notesController;
  String selectedAction = 'warning';
  bool isTemporary = false;
  int durationDays = 7;

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    reasonController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    userIdController.dispose();
    reasonController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('モデレーションアクション追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'ユーザーID',
                hintText: 'ユーザーIDを入力',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: selectedAction,
              items: ['warning', 'mute', 'ban', 'unban']
                  .map((action) => DropdownMenuItem(
                        value: action,
                        child: Text(_getActionLabel(action)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedAction = value ?? 'warning');
              },
              decoration: const InputDecoration(
                labelText: 'アクション',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '理由',
                hintText: 'アクションの理由を入力',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('期限を設定'),
              value: isTemporary,
              onChanged: (value) {
                setState(() => isTemporary = value ?? false);
              },
            ),
            if (isTemporary) ...[
              const SizedBox(height: 8),
              Slider(
                value: durationDays.toDouble(),
                min: 1,
                max: 90,
                divisions: 89,
                label: '$durationDays日',
                onChanged: (value) {
                  setState(() => durationDays = value.toInt());
                },
              ),
              Text(
                '期限: $durationDays日間',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ノート (オプション)',
                hintText: '内部ノートを入力',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () => _submitModeration(),
          child: const Text('送信'),
        ),
      ],
    );
  }

  String _getActionLabel(String actionType) {
    switch (actionType) {
      case 'warning':
        return '警告';
      case 'mute':
        return 'ミュート';
      case 'ban':
        return 'バン';
      case 'unban':
        return 'バン解除';
      default:
        return actionType;
    }
  }

  Future<void> _submitModeration() async {
    if (userIdController.text.isEmpty || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必須フィールドを入力してください')),
      );
      return;
    }

    await issueModerationActionAction(
      ref,
      userId: userIdController.text,
      actionType: selectedAction,
      reason: reasonController.text,
      actionBy: 'admin_user', // TODO: Get from auth
      duration: isTemporary ? Duration(days: durationDays) : null,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('モデレーションアクションを発行しました')),
      );
    }
  }
}
