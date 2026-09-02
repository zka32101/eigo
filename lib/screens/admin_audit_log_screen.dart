import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin audit log viewer
class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('監査ログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportAuditLog(context),
            tooltip: 'ログをエクスポート',
          ),
        ],
      ),
      body: _AuditLogView(),
    );
  }

  void _exportAuditLog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('監査ログをエクスポート中...')),
    );
    // TODO: Implement actual export
  }
}

/// Audit log view
class _AuditLogView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _AuditLogStats(),
          const SizedBox(height: 16),
          _AuditLogEntries(),
        ],
      ),
    );
  }
}

/// Audit log statistics
class _AuditLogStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '監査ログサマリー（過去30日）',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatWidget(
                    label: 'アクション数',
                    value: '2,847',
                  ),
                  _StatWidget(
                    label: 'ユーザー管理',
                    value: '456',
                  ),
                  _StatWidget(
                    label: 'コンテンツ編集',
                    value: '892',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat widget
class _StatWidget extends StatelessWidget {
  final String label;
  final String value;

  const _StatWidget({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// Audit log entries list
class _AuditLogEntries extends StatefulWidget {
  @override
  State<_AuditLogEntries> createState() => _AuditLogEntriesState();
}

class _AuditLogEntriesState extends State<_AuditLogEntries> {
  String selectedAction = 'all';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ログエントリ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: selectedAction,
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('すべてのアクション'),
                    ),
                    const DropdownMenuItem(
                      value: 'createUser',
                      child: Text('ユーザー作成'),
                    ),
                    const DropdownMenuItem(
                      value: 'deleteUser',
                      child: Text('ユーザー削除'),
                    ),
                    const DropdownMenuItem(
                      value: 'editSettings',
                      child: Text('設定編集'),
                    ),
                    const DropdownMenuItem(
                      value: 'issueModerationAction',
                      child: Text('モデレーション実行'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedAction = value ?? 'all');
                  },
                  decoration: const InputDecoration(
                    labelText: 'アクション',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _AuditLogEntry(
                action: ['createUser', 'deleteUser', 'editSettings', 'issueModerationAction'][index % 4],
                adminName: 'Admin ${(index % 3) + 1}',
                description: _getDescription(index),
                timestamp: DateTime.now().subtract(Duration(hours: index)),
                targetId: 'user_${1000 + index}',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String _getDescription(int index) {
    const descriptions = [
      'ユーザー「user_1000」を作成',
      'ユーザー「user_1001」を削除',
      '設定を編集（システムヘルスチェック間隔）',
      'ユーザー「user_1002」にバンを発行',
    ];
    return descriptions[index % 4];
  }
}

/// Audit log entry
class _AuditLogEntry extends StatelessWidget {
  final String action;
  final String adminName;
  final String description;
  final DateTime timestamp;
  final String targetId;

  const _AuditLogEntry({
    required this.action,
    required this.adminName,
    required this.description,
    required this.timestamp,
    required this.targetId,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getActionColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ユーザー ID: $targetId',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_getActionLabel()),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  adminName,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  _formatTime(timestamp),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor() {
    switch (action) {
      case 'createUser':
        return Colors.green;
      case 'deleteUser':
        return Colors.red;
      case 'editSettings':
        return Colors.blue;
      case 'issueModerationAction':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getActionLabel() {
    switch (action) {
      case 'createUser':
        return '作成';
      case 'deleteUser':
        return '削除';
      case 'editSettings':
        return '編集';
      case 'issueModerationAction':
        return 'モデレーション';
      default:
        return action;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
  }
}
