import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin feature flags management screen
class AdminFeatureFlagsScreen extends ConsumerWidget {
  const AdminFeatureFlagsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('機能フラグ管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateFlagDialog(context, ref),
            tooltip: 'フラグ作成',
          ),
        ],
      ),
      body: _FeatureFlagsListView(),
    );
  }

  void _showCreateFlagDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateFeatureFlagDialog(),
    );
  }
}

/// Feature flags list view
class _FeatureFlagsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagsAsync = ref.watch(featureFlagsProvider);

    return flagsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (flags) {
        if (flags.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'フラグがありません',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flags.length,
          itemBuilder: (context, index) {
            return _FeatureFlagCard(flag: flags[index]);
          },
        );
      },
    );
  }
}

/// Feature flag card
class _FeatureFlagCard extends ConsumerWidget {
  final FeatureFlag flag;

  const _FeatureFlagCard({required this.flag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        flag.name,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flag.description,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(flag.isEnabled ? '有効' : '無効'),
                  backgroundColor: flag.isEnabled
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: flag.isEnabled ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FlagMetaRow(
              label: 'ロールアウト',
              value: '${flag.rolloutPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            if (flag.targetUserIds.isNotEmpty) ...[
              _FlagMetaRow(
                label: 'ターゲットユーザー',
                value: '${flag.targetUserIds.length}ユーザー',
              ),
              const SizedBox(height: 8),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: flag.rolloutPercentage / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('編集'),
                  onPressed: () => _showEditFlagDialog(context, flag),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('削除'),
                  onPressed: () => _showDeleteConfirmation(context, flag),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFlagDialog(BuildContext context, FeatureFlag flag) {
    showDialog(
      context: context,
      builder: (context) => _EditFeatureFlagDialog(flag: flag),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FeatureFlag flag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フラグを削除'),
        content: Text('「${flag.name}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('フラグ「${flag.name}」を削除しました')),
              );
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

/// Flag meta row
class _FlagMetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _FlagMetaRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Create feature flag dialog
class _CreateFeatureFlagDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateFeatureFlagDialog> createState() =>
      _CreateFeatureFlagDialogState();
}

class _CreateFeatureFlagDialogState
    extends ConsumerState<_CreateFeatureFlagDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  bool isEnabled = true;
  double rolloutPercentage = 100.0;
  List<String> targetUserIds = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('フラグを作成'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'フラグ名',
                hintText: 'newFeature',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: 'フラグの説明を入力',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('有効'),
              value: isEnabled,
              onChanged: (value) {
                setState(() => isEnabled = value ?? true);
              },
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ロールアウト: ${rolloutPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: rolloutPercentage,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() => rolloutPercentage = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ターゲットユーザー',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: targetUserIds.isEmpty
                  ? Text(
                      '未設定（全ユーザー対象）',
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  : Wrap(
                      spacing: 8,
                      children: targetUserIds
                          .map(
                            (userId) => Chip(
                              label: Text(userId),
                              onDeleted: () {
                                setState(() => targetUserIds.remove(userId));
                              },
                            ),
                          )
                          .toList(),
                    ),
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
          onPressed: () => _createFlag(),
          child: const Text('作成'),
        ),
      ],
    );
  }

  Future<void> _createFlag() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必須フィールドを入力してください')),
      );
      return;
    }

    await createFeatureFlagAction(
      ref,
      name: nameController.text,
      description: descriptionController.text,
      isEnabled: isEnabled,
      rolloutPercentage: rolloutPercentage,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フラグを作成しました')),
      );
    }
  }
}

/// Edit feature flag dialog
class _EditFeatureFlagDialog extends ConsumerStatefulWidget {
  final FeatureFlag flag;

  const _EditFeatureFlagDialog({required this.flag});

  @override
  ConsumerState<_EditFeatureFlagDialog> createState() =>
      _EditFeatureFlagDialogState();
}

class _EditFeatureFlagDialogState
    extends ConsumerState<_EditFeatureFlagDialog> {
  late bool isEnabled;
  late double rolloutPercentage;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.flag.isEnabled;
    rolloutPercentage = widget.flag.rolloutPercentage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('フラグを編集: ${widget.flag.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('有効'),
              value: isEnabled,
              onChanged: (value) {
                setState(() => isEnabled = value ?? true);
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ロールアウト: ${rolloutPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: rolloutPercentage,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() => rolloutPercentage = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'フラグ情報',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    _InfoLine('説明', widget.flag.description),
                    _InfoLine('ターゲットユーザー',
                        widget.flag.targetUserIds.isEmpty ? '全ユーザー' : '${widget.flag.targetUserIds.length}ユーザー'),
                  ],
                ),
              ),
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
          onPressed: () => _updateFlag(),
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _updateFlag() async {
    await updateFeatureFlagAction(
      ref,
      flagId: widget.flag.name,
      isEnabled: isEnabled,
      rolloutPercentage: rolloutPercentage,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フラグを更新しました')),
      );
    }
  }
}

/// Info line widget
class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
