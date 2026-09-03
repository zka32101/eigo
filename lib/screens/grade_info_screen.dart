import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';

/// Display user's grade information and promotion status
class GradeInfoScreen extends ConsumerWidget {
  final String userId;

  const GradeInfoScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradeInfoAsync = ref.watch(userGradeInfoProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('学年情報'),
      ),
      body: gradeInfoAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
        data: (gradeInfo) {
          if (gradeInfo == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('学年情報が見つかりません'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current grade card
                _GradeCard(gradeInfo: gradeInfo),
                const SizedBox(height: 24),

                // Promotion countdown
                if (gradeInfo.nextPromotionDate != null)
                  _PromotionCountdown(gradeInfo: gradeInfo),
                const SizedBox(height: 24),

                // Promotion history
                _PromotionHistory(gradeInfo: gradeInfo),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Current grade card
class _GradeCard extends StatelessWidget {
  final UserGradeInfo gradeInfo;

  const _GradeCard({required this.gradeInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '現在の学年',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${gradeInfo.currentGrade}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 12),
                Text(
                  '年生',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoColumn(
                    label: '開始日',
                    value: _formatDate(gradeInfo.startDate),
                  ),
                  _InfoColumn(
                    label: '昇進回数',
                    value: '${gradeInfo.promotionHistory.length}回',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// Promotion countdown
class _PromotionCountdown extends StatelessWidget {
  final UserGradeInfo gradeInfo;

  const _PromotionCountdown({required this.gradeInfo});

  @override
  Widget build(BuildContext context) {
    final daysLeft = gradeInfo.getDaysUntilPromotion(DateTime.now());
    final nextDate = gradeInfo.nextPromotionDate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '次の昇進',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (nextDate != null && daysLeft != null)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '昇進予定日',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nextDate.year}年${nextDate.month}月${nextDate.day}日',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Text(
                              daysLeft.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '日後',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 1.0 - ((daysLeft ?? 365) / 365),
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Promotion history list
class _PromotionHistory extends StatelessWidget {
  final UserGradeInfo gradeInfo;

  const _PromotionHistory({required this.gradeInfo});

  @override
  Widget build(BuildContext context) {
    final history = gradeInfo.promotionHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '昇進履歴',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '昇進履歴がありません',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final promotion = history[index];
              return _PromotionHistoryItem(promotion: promotion);
            },
          ),
      ],
    );
  }
}

/// Promotion history item
class _PromotionHistoryItem extends StatelessWidget {
  final GradePromotion promotion;

  const _PromotionHistoryItem({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${promotion.previousGrade}年 → ${promotion.newGrade}年',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${promotion.promotionDate.year}年${promotion.promotionDate.month}月${promotion.promotionDate.day}日',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (promotion.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Chip(
                        label: Text(
                          _getReasonLabel(promotion.reason),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        backgroundColor: _getReasonColor(promotion.reason)
                            .withOpacity(0.2),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonLabel(String reason) {
    switch (reason) {
      case 'automatic':
        return '自動昇進';
      case 'manual':
        return '手動昇進';
      case 'retroactive':
        return '遡及昇進';
      default:
        return reason;
    }
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'automatic':
        return Colors.green;
      case 'manual':
        return Colors.blue;
      case 'retroactive':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Info column
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
