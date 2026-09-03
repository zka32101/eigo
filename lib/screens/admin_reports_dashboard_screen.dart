import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin reports dashboard screen
class AdminReportsDashboardScreen extends ConsumerWidget {
  const AdminReportsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGenerateReportDialog(context, ref),
            tooltip: 'レポート生成',
          ),
        ],
      ),
      body: _ReportsListView(),
    );
  }

  void _showGenerateReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _GenerateReportDialog(),
    );
  }
}

/// Reports list view
class _ReportsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return reportsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'レポートがありません',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return _ReportCard(report: reports[index]);
          },
        );
      },
    );
  }
}

/// Report card
class _ReportCard extends StatelessWidget {
  final AdminReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
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
                        report.title,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getReportTypeLabel(report.type),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getReportTypeIcon(report.type),
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ReportMetaRow(
              label: '生成日時',
              value: _formatDateTime(report.generatedAt),
            ),
            const SizedBox(height: 8),
            if (report.startDate != null)
              _ReportMetaRow(
                label: '期間',
                value:
                    '${_formatDate(report.startDate!)} 〜 ${_formatDate(report.endDate!)}',
              ),
            if (report.generatedBy != null) ...[
              const SizedBox(height: 8),
              _ReportMetaRow(
                label: '生成者',
                value: report.generatedBy!,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('ダウンロード'),
                  onPressed: () => _downloadReport(context, report),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('共有'),
                  onPressed: () => _shareReport(context, report),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.dailySummary:
        return '日次サマリー';
      case ReportType.weeklySummary:
        return '週次サマリー';
      case ReportType.monthlySummary:
        return '月次サマリー';
      case ReportType.userAnalysis:
        return 'ユーザー分析';
      case ReportType.engagementReport:
        return 'エンゲージメントレポート';
      case ReportType.retentionAnalysis:
        return 'リテンション分析';
      case ReportType.revenueReport:
        return '収益レポート';
      case ReportType.churnAnalysis:
        return 'チャーン分析';
      case ReportType.customReport:
        return 'カスタムレポート';
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.dailySummary:
      case ReportType.weeklySummary:
      case ReportType.monthlySummary:
        return Icons.calendar_today;
      case ReportType.userAnalysis:
        return Icons.people;
      case ReportType.engagementReport:
        return Icons.trending_up;
      case ReportType.retentionAnalysis:
        return Icons.show_chart;
      case ReportType.revenueReport:
        return Icons.monetization_on;
      case ReportType.churnAnalysis:
        return Icons.person_remove;
      case ReportType.customReport:
        return Icons.assessment;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _downloadReport(BuildContext context, AdminReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('レポート「${report.title}」をダウンロード中...')),
    );
    // TODO: Implement actual download
  }

  void _shareReport(BuildContext context, AdminReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('レポート「${report.title}」を共有中...')),
    );
    // TODO: Implement actual sharing
  }
}

/// Report meta row
class _ReportMetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportMetaRow({
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

/// Generate report dialog
class _GenerateReportDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GenerateReportDialog> createState() =>
      _GenerateReportDialogState();
}

class _GenerateReportDialogState extends ConsumerState<_GenerateReportDialog> {
  String selectedReportType = ReportType.dailySummary.toString().split('.').last;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('レポート生成'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedReportType,
              items: _getReportTypeOptions(),
              onChanged: (value) {
                setState(() => selectedReportType = value ?? selectedReportType);
              },
              decoration: const InputDecoration(
                labelText: 'レポートタイプ',
              ),
            ),
            const SizedBox(height: 16),
            if (_requiresDateRange())
              Column(
                children: [
                  ListTile(
                    title: const Text('開始日'),
                    subtitle: Text(
                      startDate != null
                          ? '${startDate!.year}年${startDate!.month}月${startDate!.day}日'
                          : '選択',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectStartDate(context),
                  ),
                  ListTile(
                    title: const Text('終了日'),
                    subtitle: Text(
                      endDate != null
                          ? '${endDate!.year}年${endDate!.month}月${endDate!.day}日'
                          : '選択',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectEndDate(context),
                  ),
                ],
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
          onPressed: () => _generateReport(),
          child: const Text('生成'),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getReportTypeOptions() {
    return [
      DropdownMenuItem(
        value: 'dailySummary',
        child: const Text('日次サマリー'),
      ),
      DropdownMenuItem(
        value: 'weeklySummary',
        child: const Text('週次サマリー'),
      ),
      DropdownMenuItem(
        value: 'monthlySummary',
        child: const Text('月次サマリー'),
      ),
      DropdownMenuItem(
        value: 'userAnalysis',
        child: const Text('ユーザー分析'),
      ),
      DropdownMenuItem(
        value: 'engagementReport',
        child: const Text('エンゲージメントレポート'),
      ),
      DropdownMenuItem(
        value: 'retentionAnalysis',
        child: const Text('リテンション分析'),
      ),
    ];
  }

  bool _requiresDateRange() {
    return selectedReportType == 'userAnalysis' ||
        selectedReportType == 'customReport';
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now().subtract(Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> _generateReport() async {
    if (_requiresDateRange() && (startDate == null || endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('開始日と終了日を選択してください')),
      );
      return;
    }

    await generateDailyReportAction(
      ref,
      generatedBy: 'admin_user', // TODO: Get from auth
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('レポート生成中...')),
      );
    }
  }
}
