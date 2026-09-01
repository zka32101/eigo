import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/level_provider.dart';
import '../services/claude_api_service.dart';
import '../providers/ai_api_key_provider.dart';
import '../providers/teacher_mode_provider.dart' show TeacherModeQuestion;
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class TeacherModeScreen extends ConsumerStatefulWidget {
  final int sessionSize;

  const TeacherModeScreen({
    Key? key,
    this.sessionSize = 5,
  }) : super(key: key);

  @override
  ConsumerState<TeacherModeScreen> createState() => _TeacherModeScreenState();
}

class _TeacherModeScreenState extends ConsumerState<TeacherModeScreen> {
  late stt.SpeechToText _speechToText;
  late FlutterTts _tts;

  int _currentQuestion = 0;
  int _correctAnswers = 0;
  int _coinsEarned = 0;
  int _sessionSize = 5;
  bool _isListening = false;
  String _recognizedText = '';
  late List<TeacherModeQuestion> _questions;

  // プリセット質問（フォールバック用）
  final List<TeacherModeQuestion> _presetQuestions = [
    TeacherModeQuestion(
      correctPhrase: 'What is your name?',
      wrongPhrase: 'What is you name?',
      mistakeType: 'grammar',
      explanation: 'I の後は "am" を使います',
      japaneseTranslation: 'あなたの名前は何ですか？',
      teachingTip: '"you" の後に be動詞が必要だよ、と教えてあげよう',
    ),
    TeacherModeQuestion(
      correctPhrase: 'I like apples',
      wrongPhrase: 'I likes apples',
      mistakeType: 'grammar',
      explanation: '1人称単数では "like" を使います',
      japaneseTranslation: '私はりんごが好きです',
      teachingTip: '"I" の後には "s" をつけないよ、と教えてあげよう',
    ),
    TeacherModeQuestion(
      correctPhrase: 'She goes to school',
      wrongPhrase: 'She go to school',
      mistakeType: 'grammar',
      explanation: '3人称単数には "s" をつけます',
      japaneseTranslation: '彼女は学校に行きます',
      teachingTip: '"she" の後の動詞には "s" が必要だよ、と教えてあげよう',
    ),
    TeacherModeQuestion(
      correctPhrase: 'Hello, how are you?',
      wrongPhrase: 'Hello, how you are?',
      mistakeType: 'grammar',
      explanation: '英語の語順は固定です',
      japaneseTranslation: 'こんにちは、元気ですか？',
      teachingTip: '疑問文の語順は "how + be動詞 + you" だよ、と教えてあげよう',
    ),
    TeacherModeQuestion(
      correctPhrase: 'I am interested in learning English',
      wrongPhrase: 'I am interesting in learning English',
      mistakeType: 'semantic',
      explanation: 'interested = 興味がある、interesting = 興味深い',
      japaneseTranslation: '英語を勉強することに興味があります',
      teachingTip: '"interested"（興味がある側）と "interesting"（興味深い側）の違いを教えてあげよう',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sessionSize = widget.sessionSize;
    _questions = (_presetQuestions..shuffle()).take(_sessionSize).toList();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
  }

  Future<void> _initializeTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speakPhrase(String text) async {
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (!_isListening && _speechToText.isAvailable) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords.toLowerCase());
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _checkAnswer() {
    final question = _questions[_currentQuestion];
    final isCorrect = _judgeAnswer(
      userAnswer: _recognizedText,
      correctPhrase: question.correctPhrase,
      wrongPhrase: question.wrongPhrase,
    );

    if (isCorrect) {
      setState(() => _correctAnswers++);
      _showCorrectFeedback();
    } else {
      _showIncorrectFeedback();
    }

    _nextQuestion();
  }

  /// 正答判定ロジック
  /// 返却値: true = 正解（子どもが正しく教えた）, false = 不正解
  bool _judgeAnswer({
    required String userAnswer,
    required String correctPhrase,
    required String wrongPhrase,
  }) {
    final userLower = userAnswer.toLowerCase().trim();
    final correctLower = correctPhrase.toLowerCase();
    final wrongLower = wrongPhrase.toLowerCase();

    // 1. 完全一致確認
    if (userLower == correctLower) return true;

    // 2. キーワード検出（正解フレーズの主要単語を含むか）
    final correctWords = correctLower.split(' ');
    int matchedWords = 0;
    for (final word in correctWords) {
      if (word.length > 3 && userLower.contains(word)) {
        matchedWords++;
      }
    }
    if (matchedWords >= (correctWords.length * 0.7).toInt()) return true;

    // 3. 「正解」「正しい」「そう」などの肯定表現
    if (userLower.contains('正しい') ||
        userLower.contains('そう') ||
        userLower.contains('right') ||
        userLower.contains('correct')) {
      return true;
    }

    // 4. Levenshtein 距離による類似度
    final similarity = _calculateSimilarity(userLower, correctLower);
    if (similarity > 0.7) return true;

    return false;
  }

  /// Levenshtein 距離で類似度計算（0.0-1.0）
  double _calculateSimilarity(String s1, String s2) {
    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return 1.0 - (editDistance / longer.length);
  }

  /// Levenshtein 距離計算
  int _levenshteinDistance(String s1, String s2) {
    final costs = List<int>.filled(s2.length + 1, 0);
    for (int i = 0; i <= s2.length; i++) costs[i] = i;

    for (int i = 1; i <= s1.length; i++) {
      int nw = i - 1, w = i;
      for (int j = 1; j <= s2.length; j++) {
        int nc = nw + (s1[i - 1] == s2[j - 1] ? 0 : 1);
        nw = costs[j];
        w = costs[j] = w < nc ? (nw < w ? nw : w) : nc;
      }
    }
    return costs[s2.length];
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _recognizedText = '';
      });
    } else {
      _showSessionComplete();
    }
  }

  void _showCorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 先生、ありがとう！完璧です！'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showIncorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ もう一度教えてください'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSessionComplete() async {
    final userId = ref.read(currentUserProvider)?.id ?? '';
    final coinsEarned = _correctAnswers * 10;
    final accuracy = (_correctAnswers / _questions.length * 100).toInt();

    // リワード計算
    final rewardBonus = _calculateRewardBonus(accuracy);
    final totalCoins = coinsEarned + rewardBonus;
    final bonusMessage = _generateBonusMessage(accuracy);

    // コイン加算
    await ref.read(coinProvider.notifier).addCoins(totalCoins);
    if (mounted) setState(() => _coinsEarned = totalCoins);

    // ペット幸福度加算（先生として教えた喜び）
    if (userId.isNotEmpty) {
      try {
        await ref.read(petNotifierProvider(userId).notifier).applyDailyBonus();
      } catch (e) {
        print('Pet bonus error: $e');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('🎉 セッション完了！'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.verticalSpacerMd,
                Text(
                  '$accuracy%',
                  style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.verticalSpacerXs,
                Text('$_correctAnswers / ${_questions.length} 正解'),
                AppSpacing.verticalSpacerMd,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  ),
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💰 ', style: TextStyle(fontSize: 24)),
                          Text(
                            '+ $coinsEarned コイン',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (rewardBonus > 0) ...[
                        AppSpacing.verticalSpacerXs,
                        Text(
                          '🌟 ボーナス + $rewardBonus',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                      AppSpacing.verticalSpacerXs,
                      Text(
                        '合計: $totalCoins コイン',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpacerSm,
                if (bonusMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                    ),
                    child: Text(
                      bonusMessage,
                      style: TextStyle(color: Colors.blue.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('戻る'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetSession();
              },
              child: const Text('もう一度'),
            ),
          ],
        ),
      );
    }
  }

  /// リワードボーナス計算（正答率に基づく）
  int _calculateRewardBonus(int accuracy) {
    if (accuracy >= 90) return 50; // 🌟 Perfect!
    if (accuracy >= 80) return 30; // 🌟 Great!
    if (accuracy >= 70) return 20; // 👏 Good
    if (accuracy >= 60) return 10; // ✨ Nice
    return 0;
  }

  /// ボーナスメッセージ生成
  String _generateBonusMessage(int accuracy) {
    if (accuracy >= 90) {
      return '🌟 パーフェクト！本当に素晴らしい先生ですね！';
    } else if (accuracy >= 80) {
      return '🌟 素晴らしい！また教えてください！';
    } else if (accuracy >= 70) {
      return '👏 上手に教えてくれました！';
    } else if (accuracy >= 60) {
      return '✨ 頑張りましたね！';
    } else {
      return '😊 また練習してね';
    }
  }

  void _resetSession() {
    setState(() {
      _currentQuestion = 0;
      _correctAnswers = 0;
      _coinsEarned = 0;
      _recognizedText = '';
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧑‍🏫 先生ごっこ'),
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingMd,
        children: [
          // 進捗表示
          _ProgressBar(
            current: _currentQuestion + 1,
            total: _questions.length,
          ),
          AppSpacing.verticalSpacerLg,

          // 出題カード
          _QuestionCard(question: question),
          AppSpacing.verticalSpacerLg,

          // 音声入力エリア
          _VoiceInputArea(
            isListening: _isListening,
            recognizedText: _recognizedText,
            onStartListening: _startListening,
            onStopListening: _stopListening,
            onSpeakWrong: () => _speakPhrase(question.wrongPhrase),
          ),
          AppSpacing.verticalSpacerLg,

          // 教える入力エリア
          _TeachingArea(
            onCorrect: _checkAnswer,
            recognizedText: _recognizedText,
          ),
          AppSpacing.verticalSpacerLg,

          // スコア表示
          _ScoreDisplay(
            correct: _correctAnswers,
            total: _questions.length,
          ),
        ],
      ),
    );
  }
}

/// 進捗バー
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '問題',
              style: AppTypography.labelLarge,
            ),
            Text(
              '$current / $total',
              style: AppTypography.labelLarge,
            ),
          ],
        ),
        AppSpacing.verticalSpacerXs,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }
}

/// 出題カード
class _QuestionCard extends StatelessWidget {
  final TeacherModeQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤖 AI の生徒が言った間違い：',
            style: AppTypography.labelLarge.copyWith(color: Colors.red),
          ),
          AppSpacing.verticalSpacerSm,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              border: Border.all(color: Colors.red.shade300),
            ),
            padding: AppSpacing.allPaddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${question.wrongPhrase}"',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.red,
                  ),
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  question.japaneseTranslation,
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            '✏️ 何が間違っていますか？',
            style: AppTypography.labelLarge,
          ),
          AppSpacing.verticalSpacerXs,
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ミスタイプ: ${question.mistakeType}',
                        style: AppTypography.bodySmall,
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        question.explanation,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 音声入力エリア
class _VoiceInputArea extends StatelessWidget {
  final bool isListening;
  final String recognizedText;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final VoidCallback onSpeakWrong;

  const _VoiceInputArea({
    required this.isListening,
    required this.recognizedText,
    required this.onStartListening,
    required this.onStopListening,
    required this.onSpeakWrong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.orange.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎤 聞く',
            style: AppTypography.labelLarge,
          ),
          AppSpacing.verticalSpacerSm,
          ElevatedButton(
            onPressed: onSpeakWrong,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
            ),
            child: const Text('間違いを聞く'),
          ),
          AppSpacing.verticalSpacerSm,
          ElevatedButton(
            onPressed: isListening ? onStopListening : onStartListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: isListening ? Colors.red : Colors.green,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
            ),
            child: Text(
              isListening ? '🛑 停止' : '🎤 聞く',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (recognizedText.isNotEmpty) ...[
            AppSpacing.verticalSpacerSm,
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('認識結果:', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    recognizedText,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 教える入力エリア
class _TeachingArea extends StatelessWidget {
  final VoidCallback onCorrect;
  final String recognizedText;

  const _TeachingArea({
    required this.onCorrect,
    required this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👩‍🏫 教える',
            style: AppTypography.labelLarge,
          ),
          AppSpacing.verticalSpacerSm,
          ElevatedButton(
            onPressed: recognizedText.isNotEmpty ? onCorrect : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
            ),
            child: Text(
              '✅ 正解を教える',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// スコア表示
class _ScoreDisplay extends StatelessWidget {
  final int correct;
  final int total;

  const _ScoreDisplay({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final accuracy = total > 0 ? (correct / total * 100).toInt() : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('正解数', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
              Text(
                '$correct / $total',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.grey[300],
          ),
          Column(
            children: [
              Text('正答率', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
              Text(
                '$accuracy%',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
