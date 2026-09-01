import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_mode_model.dart';
import '../providers/teacher_mode_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class TeacherModeInteractiveScreen extends ConsumerStatefulWidget {
  final String phrase;
  final String phraseMeaning;
  final TeacherModeDifficulty difficulty;

  const TeacherModeInteractiveScreen({
    super.key,
    required this.phrase,
    required this.phraseMeaning,
    required this.difficulty,
  });

  @override
  ConsumerState<TeacherModeInteractiveScreen> createState() =>
      _TeacherModeInteractiveScreenState();
}

class _TeacherModeInteractiveScreenState
    extends ConsumerState<TeacherModeInteractiveScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _responseController;
  late AnimationController _animationController;
  bool _showFeedback = false;
  bool? _lastRoundCorrect;

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializeSession();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    await ref.read(teacherModeSessionProvider.notifier).startSession(
          widget.phrase,
          widget.phraseMeaning,
          widget.difficulty,
        );

    // 最初のミスを生成
    _generateNextMistake();
  }

  Future<void> _generateNextMistake() async {
    final mistake = await ref.read(
      aiMistakeGeneratorProvider((widget.phrase, widget.difficulty)).future,
    );
    await ref.read(teacherModeSessionProvider.notifier).setCurrentMistake(mistake);
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please say or type your correction!')),
      );
      return;
    }

    // ラウンドを完了
    await ref.read(teacherModeSessionProvider.notifier).completeRound(
          _responseController.text,
          85.0, // シミュレーション：固定スコア
        );

    final session = ref.read(teacherModeSessionProvider);
    if (session == null) return;

    final lastRound = session.completedRounds.isNotEmpty
        ? session.completedRounds.last
        : null;

    setState(() {
      _showFeedback = true;
      _lastRoundCorrect = lastRound?.isCorrect ?? false;
    });

    _animationController.forward();

    // フィードバック表示後に次のラウンドに進む
    await Future.delayed(const Duration(seconds: 2));

    if (session.completedRounds.length < session.totalRounds) {
      _responseController.clear();
      setState(() {
        _showFeedback = false;
        _lastRoundCorrect = null;
      });
      _animationController.reset();
      _generateNextMistake();
    } else {
      // セッション完了
      await ref.read(teacherModeSessionProvider.notifier).completeSession();
      await ref.read(teacherModeStatsProvider.notifier).updateStatsFromSession(session);
      
      if (mounted) {
        _showSessionResults(session);
      }
    }
  }

  void _showSessionResults(TeacherModeSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SessionResultsDialog(session: session),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(teacherModeSessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🧑‍🏫 先生ごっこ'),
          backgroundColor: kPrimaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (session.currentMistake == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🧑‍🏫 先生ごっこ'),
          backgroundColor: kPrimaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final mistake = session.currentMistake!;
    final roundNumber = session.completedRounds.length + 1;
    final progress = (roundNumber / session.totalRounds) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧑‍🏫 先生ごっこ'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プログレスバー
            _buildProgressSection(roundNumber, session.totalRounds, progress),
            AppSpacing.verticalSpacerLg,

            // AIの間違い表示
            _buildMistakeSection(mistake),
            AppSpacing.verticalSpacerLg,

            // 子どもの応答入力
            _buildResponseSection(mistake),
            AppSpacing.verticalSpacerLg,

            // フィードバック表示
            if (_showFeedback && _lastRoundCorrect != null)
              _buildFeedbackSection(_lastRoundCorrect!),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int current, int total, double percentage) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kPrimaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kPrimaryColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ラウンド $current / $total', style: AppTypography.labelLarge),
              Text('${percentage.toStringAsFixed(0)}%', style: AppTypography.labelLarge),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeSection(AIStudentMistake mistake) {
    final mistakeTypeLabel = {
      MistakeType.pronunciation: '発音ミス 🎤',
      MistakeType.grammar: '文法ミス 📝',
      MistakeType.meaning: '意味ミス 💭',
    }[mistake.mistakeType];

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kAccentOrange.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kAccentOrange.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(mistakeTypeLabel ?? 'ミス'),
            backgroundColor: kAccentOrange.withAlpha(30),
            labelStyle: const TextStyle(color: kAccentOrange, fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            'AIの先生が言ったこと:',
            style: AppTypography.labelSmall.copyWith(color: kTextMuted),
          ),
          AppSpacing.verticalSpacerSm,
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Text(
              '"${mistake.mistakeText}"',
              style: AppTypography.headlineSmall.copyWith(
                fontStyle: FontStyle.italic,
                color: kAccentOrange,
              ),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            '説明: ${mistake.explanation}',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseSection(AIStudentMistake mistake) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '正しい言い方を教えてください！',
          style: AppTypography.labelLarge,
        ),
        AppSpacing.verticalSpacerMd,
        TextField(
          controller: _responseController,
          decoration: InputDecoration(
            hintText: 'ここに正しい言い方を入力してください',
            prefixIcon: const Icon(Icons.edit, color: kPrimaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          maxLines: 2,
          enabled: !_showFeedback,
        ),
        AppSpacing.verticalSpacerMd,
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _showFeedback ? null : _submitResponse,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGreen,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              '答えを確認',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(bool isCorrect) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(_animationController),
      child: Container(
        padding: AppSpacing.allPaddingMd,
        decoration: BoxDecoration(
          color: isCorrect ? kAccentGreen.withAlpha(10) : Colors.red.withAlpha(10),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: isCorrect ? kAccentGreen.withAlpha(50) : Colors.red.withAlpha(50),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isCorrect ? '✓ 正解！' : '✗ もう一度',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isCorrect ? kAccentGreen : Colors.red,
                  ),
                ),
                const Spacer(),
                Text(
                  isCorrect ? '🎉' : '💡',
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              isCorrect
                  ? ref.watch(teacherModeSessionProvider)?.currentMistake?.encouragement ??
                      'Great job!'
                  : '正しい答えは: "${ref.watch(teacherModeSessionProvider)?.currentMistake?.correctAnswer}"',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionResultsDialog extends StatelessWidget {
  final TeacherModeSession session;

  const _SessionResultsDialog({required this.session});

  @override
  Widget build(BuildContext context) {
    final accuracy = session.accuracyRate;
    final coinsEarned = session.correctAnswers * 10;

    return AlertDialog(
      title: const Text('🎉 セッション完了！'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '${accuracy.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kAccentGreen),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          _buildResultRow(
            '正解数',
            '${session.correctAnswers} / ${session.totalRounds}',
          ),
          _buildResultRow('正解率', '${accuracy.toStringAsFixed(1)}%'),
          _buildResultRow('コイン報酬', '+ $coinsEarned 💰'),
          AppSpacing.verticalSpacerMd,
          const Divider(),
          AppSpacing.verticalSpacerSm,
          Text(
            '学習フレーズ: ${session.phrase}',
            style: const TextStyle(fontStyle: FontStyle.italic, color: kTextMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('戻る'),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kTextMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
