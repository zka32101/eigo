import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/providers/dialogue_context_provider.dart';

/// インタラクション結果ウィジェット
/// ダイアログ終了後の結果（スコア、XP、コイン、フィードバック）を表示
class InteractionResultWidget extends ConsumerWidget {
  final int score;
  final int xpEarned;
  final int coinsEarned;
  final String feedback;
  final Map<String, double> qualityBreakdown;
  final String? nextSuggestion;
  final VoidCallback? onClose;

  const InteractionResultWidget({
    Key? key,
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
    required this.feedback,
    required this.qualityBreakdown,
    this.nextSuggestion,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー：スコアと評価
            _buildScoreSection(),
            const SizedBox(height: 24),

            // リワード：XPとコイン
            _buildRewardSection(),
            const SizedBox(height: 24),

            // 品質評価の内訳
            _buildQualityBreakdownSection(),
            const SizedBox(height: 24),

            // フィードバック
            _buildFeedbackSection(),
            const SizedBox(height: 24),

            // 次のステップの提案
            if (nextSuggestion != null) ...[
              _buildSuggestionSection(),
              const SizedBox(height: 24),
            ],

            // 閉じるボタン
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  /// スコアセクションを構築
  Widget _buildScoreSection() {
    final grade = _getGrade(score);
    final gradeColor = _getGradeColor(score);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // スコア表示（大きく）
            Text(
              '$score',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 8),

            // 満点表示
            Text(
              '/ 100',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // 評価グレード
            Text(
              grade['label'] as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 8),

            // 星表示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starCount = grade['stars'] as int;
                return Icon(
                  index < starCount ? Icons.star : Icons.star_outline,
                  color: gradeColor,
                  size: 24,
                );
              }),
            ),

            // スコア進捗バー
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100.0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// リワードセクションを構築
  Widget _buildRewardSection() {
    return Row(
      children: [
        // XP獲得
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$xpEarned',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'XP Earned',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // コイン獲得
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$coinsEarned',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coins',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 品質評価の内訳セクションを構築
  Widget _buildQualityBreakdownSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quality Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 各コンポーネントの品質スコア
            ...qualityBreakdown.entries.map((entry) {
              final percentage = (entry.value * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: entry.value,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getComponentColor(entry.value),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// フィードバックセクションを構築
  Widget _buildFeedbackSection() {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 提案セクションを構築
  Widget _buildSuggestionSection() {
    return Card(
      elevation: 1,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Next Step',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nextSuggestion!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 閉じるボタンを構築
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onClose ?? () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// スコアに基づいてグレードを取得
  Map<String, dynamic> _getGrade(int score) {
    if (score >= 90) {
      return {'label': 'Excellent', 'stars': 5};
    } else if (score >= 80) {
      return {'label': 'Very Good', 'stars': 4};
    } else if (score >= 70) {
      return {'label': 'Good', 'stars': 3};
    } else if (score >= 60) {
      return {'label': 'Acceptable', 'stars': 2};
    } else if (score >= 50) {
      return {'label': 'Below Average', 'stars': 1};
    } else {
      return {'label': 'Poor', 'stars': 0};
    }
  }

  /// グレードに対応する色を取得
  Color _getGradeColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.amber;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  /// スコアに応じた色を取得（0.0-1.0の値用）
  Color _getComponentColor(double value) {
    if (value >= 0.9) return Colors.green;
    if (value >= 0.8) return Colors.lightGreen;
    if (value >= 0.7) return Colors.blue;
    if (value >= 0.6) return Colors.amber;
    if (value >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

/// インタラクション結果ダイアログを表示するヘルパー関数
Future<void> showInteractionResultDialog(
  BuildContext context, {
  required int score,
  required int xpEarned,
  required int coinsEarned,
  required String feedback,
  required Map<String, double> qualityBreakdown,
  String? nextSuggestion,
  VoidCallback? onClose,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: InteractionResultWidget(
        score: score,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        feedback: feedback,
        qualityBreakdown: qualityBreakdown,
        nextSuggestion: nextSuggestion,
        onClose: onClose ?? () => Navigator.of(context).pop(),
      ),
    ),
  );
}

/// ミニマル結果表示ウィジェット（シンプル版）
class CompactInteractionResultWidget extends StatelessWidget {
  final int score;
  final int xpEarned;
  final int coinsEarned;

  const CompactInteractionResultWidget({
    Key? key,
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final grade = _getGrade(score);
    final gradeColor = _getGradeColor(score);

    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // スコア表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      grade['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: gradeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // リワード表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '+$xpEarned XP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '+$coinsEarned',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// スコアに基づいてグレードを取得
  Map<String, dynamic> _getGrade(int score) {
    if (score >= 90) {
      return {'label': 'Excellent', 'stars': 5};
    } else if (score >= 80) {
      return {'label': 'Very Good', 'stars': 4};
    } else if (score >= 70) {
      return {'label': 'Good', 'stars': 3};
    } else if (score >= 60) {
      return {'label': 'Acceptable', 'stars': 2};
    } else if (score >= 50) {
      return {'label': 'Below Average', 'stars': 1};
    } else {
      return {'label': 'Poor', 'stars': 0};
    }
  }

  /// グレードに対応する色を取得
  Color _getGradeColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.amber;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
