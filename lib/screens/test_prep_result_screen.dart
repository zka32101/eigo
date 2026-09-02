import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class TestPrepResultScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const TestPrepResultScreen({super.key, required this.args});

  @override
  State<TestPrepResultScreen> createState() => _TestPrepResultScreenState();
}

class _TestPrepResultScreenState extends State<TestPrepResultScreen> {
  late ConfettiController _confetti;

  int get score => widget.args['score'] as int;
  int get correct => widget.args['correct'] as int;
  int get total => widget.args['total'] as int;
  double get accuracy => widget.args['accuracy'] as double;

  bool get isPassed => accuracy >= 0.6;
  bool get isExcellent => accuracy >= 0.9;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (isPassed) {
      Future.delayed(const Duration(milliseconds: 300), _confetti.play);
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = isExcellent ? '🏆' : isPassed ? '⭐' : '💪';
    final message = isExcellent
        ? '完璧！弱点を克服しました！'
        : isPassed
            ? '弱点を改善しています！'
            : 'もう一度挑戦しよう！';
    final color = isPassed ? AppColors.accentGreen : AppColors.accentOrange;

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: AppColors.error,
        automaticallyImplyLeading: false,
        title: const Text('🎯 テスト対策 - 結果'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              children: [
                AppSpacing.verticalSpacerMd,
                // 結果ヘッダー
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Text(emoji, style: AppTypography.headlineLarge),
                        AppSpacing.verticalSpacerSm,
                        Text(
                          message,
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.verticalSpacerLg,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Stat('スコア', '$score点', AppColors.error),
                            _Stat('正解', '$correct / $total', color),
                            _Stat('正解率', '${(accuracy * 100).round()}%', color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                // 弱点改善メッセージ
                Card(
                  color: const Color(0xFFF0FFF4),
                  child: Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📈 弱点対策の効果',
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                        AppSpacing.verticalSpacerSm,
                        if (isExcellent)
                          Text(
                            '素晴らしい！弱点問題を90%以上正解しました。\nこれらの問題はもはや弱点ではありません！',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5),
                          )
                        else if (isPassed)
                          Text(
                            '弱点問題への対策ができています。\n繰り返し練習することで、さらに定着します。',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5),
                          )
                        else
                          Text(
                            'まだ弱点が残っています。\n聞いてから真似する練習を繰り返しましょう。',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5),
                          ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalSpacerLg,
                // アクションボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.replay),
                    label: const Text('もう一度テスト対策'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/test-prep');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                ),
                AppSpacing.verticalSpacerSm,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('ホームへ'),
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                AppSpacing.verticalSpacerXl,
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.accentGreen, AppColors.primary, AppColors.accentOrange],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
