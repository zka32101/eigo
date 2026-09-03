import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin screen for managing grade promotions
class AdminGradePromotionScreen extends ConsumerWidget {
  const AdminGradePromotionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学年昇進管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPromotionInfo(context),
            tooltip: '情報',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PromotionConfigCard(),
            const SizedBox(height: 16),
            _ManualPromotionCard(),
            const SizedBox(height: 16),
            _BulkPromotionCard(),
            const SizedBox(height: 16),
            _PromotionHistoryCard(),
          ],
        ),
      ),
    );
  }

  void _showPromotionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学年昇進について'),
        content: const Text(
          '学年昇進機能により、生徒の学年を自動または手動で昇進させることができます。\n\n'
          '• 自動昇進：毎年4月1日に実行\n'
          '• 手動昇進：管理者が直接昇進可能\n'
          '• 一括昇進：複数ユーザーを一度に昇進\n\n'
          '昇進履歴は監査ログに記録されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}

/// Promotion configuration card
class _PromotionConfigCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(gradePromotionConfigProvider);

    return configAsync.when(
      data: (config) {
        if (config == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('設定を読み込めません'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '昇進設定',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('昇進日'),
                  subtitle: Text(config.promotionDateStr),
                  leading: const Icon(Icons.calendar_today),
                ),
                ListTile(
                  title: const Text('最大学年'),
                  subtitle: Text('${config.maxGrade}年生'),
                  leading: const Icon(Icons.trending_up),
                ),
                ListTile(
                  title: const Text('自動昇進'),
                  trailing: Switch(
                    value: config.isEnabled,
                    onChanged: (value) {
                      // TODO: Update promotion config
                    },
                  ),
                  leading: const Icon(Icons.autorenew),
                ),
                ListTile(
                  title: const Text('前回チェック'),
                  subtitle: Text(
                    config.lastCheckDate != null
                        ? '${config.lastCheckDate!.year}年${config.lastCheckDate!.month}月${config.lastCheckDate!.day}日'
                        : '未実施',
                  ),
                  leading: const Icon(Icons.history),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('エラー: $err'),
        ),
      ),
    );
  }
}

/// Manual promotion card for single user
class _ManualPromotionCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ManualPromotionCard> createState() =>
      _ManualPromotionCardState();
}

class _ManualPromotionCardState extends ConsumerState<_ManualPromotionCard> {
  final _userIdController = TextEditingController();
  String? _selectedGrade;
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '手動昇進',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'ユーザーID',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGrade,
              items: ['4', '5', '6', '7', '8', '9']
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text('$grade年生'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedGrade = value);
              },
              decoration: InputDecoration(
                labelText: '昇進先学年',
                prefixIcon: const Icon(Icons.grade),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _promoteUser,
                icon: const Icon(Icons.upload),
                label: _isLoading ? const Text('処理中...') : const Text('昇進'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _promoteUser() async {
    if (_userIdController.text.isEmpty || _selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザーIDと昇進先学年を入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newGrade = int.parse(_selectedGrade!);

      // TODO: Call promotion service
      // await promoteUserAction(
      //   ref,
      //   userId: _userIdController.text,
      //   newGrade: newGrade,
      //   reason: 'manual',
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ユーザー ${_userIdController.text} を $_selectedGrade 年生に昇進させました',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _userIdController.clear();
        setState(() => _selectedGrade = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Bulk promotion card
class _BulkPromotionCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BulkPromotionCard> createState() =>
      _BulkPromotionCardState();
}

class _BulkPromotionCardState extends ConsumerState<_BulkPromotionCard> {
  String _bulkMode = 'byGrade';
  String? _selectedGrade;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '一括昇進',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'byGrade',
                  label: Text('学年別'),
                  icon: Icon(Icons.school),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text('全員'),
                  icon: Icon(Icons.people),
                ),
              ],
              selected: {_bulkMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _bulkMode = newSelection.first);
              },
            ),
            const SizedBox(height: 12),
            if (_bulkMode == 'byGrade')
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                items: ['4', '5', '6', '7', '8']
                    .map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text('$grade年生 → ${int.parse(grade) + 1}年生'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedGrade = value);
                },
                decoration: InputDecoration(
                  labelText: '昇進対象学年',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '全ユーザーを昇進させます。確認が必要です。',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : (_bulkMode == 'byGrade' && _selectedGrade == null)
                        ? null
                        : _bulkPromote,
                icon: const Icon(Icons.cloud_upload),
                label: _isLoading
                    ? const Text('処理中...')
                    : const Text('一括昇進を実行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bulkPromote() {
    final message = _bulkMode == 'byGrade'
        ? '本当に $_ 年生を一括昇進させますか？'
        : '全ユーザーを一括昇進させますか？';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('一括昇進の確認'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeBulkPromotion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('実行'),
          ),
        ],
      ),
    );
  }

  void _executeBulkPromotion() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Call bulk promotion service
      // await bulkPromoteUsersAction(
      //   ref,
      //   mode: _bulkMode,
      //   grade: _bulkMode == 'byGrade' ? int.parse(_selectedGrade!) : null,
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('一括昇進が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Promotion history card
class _PromotionHistoryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load actual promotion history from service
    final promotions = [
      {
        'userId': 'user_001',
        'userName': '田中太郎',
        'previousGrade': 4,
        'newGrade': 5,
        'reason': 'automatic',
        'date': DateTime.now().subtract(const Duration(days: 10)),
      },
      {
        'userId': 'user_002',
        'userName': '山田花子',
        'previousGrade': 5,
        'newGrade': 6,
        'reason': 'manual',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'userId': 'user_003',
        'userName': '佐藤次郎',
        'previousGrade': 3,
        'newGrade': 4,
        'reason': 'retroactive',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '昇進履歴',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return _PromotionHistoryItem(
                  userName: promo['userName'] as String,
                  previousGrade: promo['previousGrade'] as int,
                  newGrade: promo['newGrade'] as int,
                  reason: promo['reason'] as String,
                  date: promo['date'] as DateTime,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Promotion history item
class _PromotionHistoryItem extends StatelessWidget {
  final String userName;
  final int previousGrade;
  final int newGrade;
  final String reason;
  final DateTime date;

  const _PromotionHistoryItem({
    required this.userName,
    required this.previousGrade,
    required this.newGrade,
    required this.reason,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    Color reasonColor;
    String reasonLabel;

    switch (reason) {
      case 'automatic':
        reasonColor = Colors.blue;
        reasonLabel = '自動';
        break;
      case 'manual':
        reasonColor = Colors.green;
        reasonLabel = '手動';
        break;
      case 'retroactive':
        reasonColor = Colors.orange;
        reasonLabel = '遡及';
        break;
      default:
        reasonColor = Colors.grey;
        reasonLabel = reason;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$previousGrade年生 → $newGrade年生',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(reasonLabel),
                    backgroundColor: reasonColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: reasonColor),
                    compact: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
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
