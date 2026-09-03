import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

/// ビデオクイズ画面
class VideoQuizScreen extends ConsumerStatefulWidget {
  final PronunciationVideo video;
  final VideoQuiz quiz;

  const VideoQuizScreen({
    Key? key,
    required this.video,
    required this.quiz,
  }) : super(key: key);

  @override
  ConsumerState<VideoQuizScreen> createState() => _VideoQuizScreenState();
}

class _VideoQuizScreenState extends ConsumerState<VideoQuizScreen> {
  late List<String?> _selectedAnswers;
  bool _submitted = false;
  int? _score;
  bool? _passed;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List<String?>.filled(widget.quiz.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    if (_submitted && _score != null && _passed != null) {
      return _ResultScreen(
        video: widget.video,
        quiz: widget.quiz,
        score: _score!,
        passed: _passed!,
        selectedAnswers: _selectedAnswers.whereType<String>().toList(),
        onRetry: () {
          setState(() {
            _selectedAnswers = List<String?>.filled(widget.quiz.questions.length, null);
            _submitted = false;
            _score = null;
            _passed = null;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 クイズ'),
        elevation: 0,
        actions: [
          Padding(
            padding: AppSpacing.allPaddingMd,
            child: Center(
              child: Text('${_selectedAnswers.where((a) => a != null).length}/${widget.quiz.questions.length}'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ビデオタイトル
              Text(
                widget.video.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                'このビデオについてのクイズに答えてください。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              AppSpacing.verticalSpacerLg,

              // クイズ質問
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  return _QuestionCard(
                    questionNumber: index + 1,
                    question: question,
                    selectedAnswer: _selectedAnswers[index],
                    onAnswerSelected: (answer) {
                      setState(() {
                        _selectedAnswers[index] = answer;
                      });
                    },
                  );
                },
              ),
              AppSpacing.verticalSpacerLg,

              // 提出ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit()
                      ? () async {
                          await _submitQuiz(userId);
                        }
                      : null,
                  child: const Text('答えを提出する'),
                ),
              ),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedAnswers.every((answer) => answer != null);
  }

  Future<void> _submitQuiz(String userId) async {
    final answers = _selectedAnswers.map((a) => a ?? '').toList();

    final resultAsync = await ref.read(submitQuizActionProvider(
      SubmitQuizParams(
        userId: userId,
        videoId: widget.video.id,
        answers: answers,
      ),
    ).future);

    if (resultAsync != null) {
      setState(() {
        _score = resultAsync.score;
        _passed = resultAsync.passed;
        _submitted = true;
      });
    }
  }
}

/// クイズ質問カード
class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final QuizQuestion question;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 質問番号
            Chip(
              label: Text('問題 $questionNumber'),
              backgroundColor: Colors.blue.withOpacity(0.2),
            ),
            AppSpacing.verticalSpacerMd,

            // 質問テキスト
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,

            // 選択肢
            Column(
              children: question.options
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedAnswer == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => onAnswerSelected(option),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                          ),
                          padding: AppSpacing.allPaddingMd,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey,
                                  ),
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalSpacerMd,
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 結果画面
class _ResultScreen extends ConsumerWidget {
  final PronunciationVideo video;
  final VideoQuiz quiz;
  final int score;
  final bool passed;
  final List<String> selectedAnswers;
  final VoidCallback onRetry;

  const _ResultScreen({
    required this.video,
    required this.quiz,
    required this.score,
    required this.passed,
    required this.selectedAnswers,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 結果'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 結果カード
              Card(
                color: passed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: AppSpacing.allPaddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ステータス
                      Text(
                        passed ? '✅ 合格!' : '❌ 不合格',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: passed ? Colors.green : Colors.orange,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSpacerMd,

                      // スコア
                      Text(
                        '$score点 / 100点',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSpacerMd,

                      // プログレスバー
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            passed ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      AppSpacing.verticalSpacerMd,

                      // メッセージ
                      Text(
                        passed
                            ? 'おめでとうございます！クイズに合格しました。'
                            : '残念ながら合格点に達しませんでした。もう一度挑戦できます。',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSpacerMd,

                      // 合格基準
                      Text(
                        '合格基準: ${quiz.passingScore}点',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // 詳細結果
              Text(
                '詳細結果',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalSpacerMd,

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  final selectedAnswer = selectedAnswers.isNotEmpty && index < selectedAnswers.length
                      ? selectedAnswers[index]
                      : '';
                  final isCorrect = selectedAnswer == question.correctAnswer;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCorrect ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                    child: Padding(
                      padding: AppSpacing.allPaddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isCorrect ? '✅' : '❌',
                                style: const TextStyle(fontSize: 20),
                              ),
                              AppSpacing.horizontalSpacerMd,
                              Expanded(
                                child: Text(
                                  'Q${index + 1}: ${question.questionText}',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalSpacerMd,
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.allPaddingMd,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'あなたの回答:',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(selectedAnswer),
                                AppSpacing.verticalSpacerMd,
                                Text(
                                  '正解:',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  question.correctAnswer,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.verticalSpacerMd,
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.allPaddingMd,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '解説:',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                AppSpacing.verticalSpacerSm,
                                Text(question.explanation),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              AppSpacing.verticalSpacerLg,

              // アクションボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ビデオに戻る'),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('もう一度チャレンジ'),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ),
    );
  }
}
