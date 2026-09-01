import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/stage.dart';
import '../providers/badge_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/speaking_history_provider.dart';
import '../providers/weakness_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/pronunciation_pet_integration_service.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../widgets/speaking_score_ring.dart';
import '../widgets/lesson_screen_components.dart';
import '../providers/user_profile_provider.dart';
import '../models/pronunciation_result.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final Stage stage;
  const LessonScreen({super.key, required this.stage});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  int _qIndex = 0;
  int _score = 0;
  int _correct = 0;
  final List<int> _speakingScores = [];
  // 弱点記録用
  final List<({String id, QuestionType type, bool correct, int speakingScore})> _answerLog = [];
  bool _answered = false;
  String? _selectedAnswer;
  bool _isListening = false;
  String _recognizedText = '';
  int _speakingScore = 0;
  bool _speakingDone = false;
  final _startTime = DateTime.now();

  Question get _current => widget.stage.questions[_qIndex];
  bool get _isLastQ => _qIndex >= widget.stage.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_current.type == QuestionType.listening) _autoPlay();
    });
  }

  Future<void> _initSpeech() async {
    await _speech.init();
  }

  Future<void> _autoPlay() async {
    final settings = ref.read(settingsProvider);
    if (!settings.autoPlayListening) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted && _current.type == QuestionType.listening && settings.ttsEnabled) {
      await _tts.speak(_current.text, rate: settings.ttsSpeed);
    }
  }

  void _nextQ() {
    if (_isLastQ) {
      _finish();
      return;
    }
    setState(() {
      _qIndex++;
      _answered = false;
      _selectedAnswer = null;
      _isListening = false;
      _recognizedText = '';
      _speakingScore = 0;
      _speakingDone = false;
    });
    if (_current.type == QuestionType.listening) _autoPlay();
  }

  Future<void> _finish() async {
    final speakAvg = _speakingScores.isEmpty
        ? 0.0
        : _speakingScores.reduce((a, b) => a + b) / _speakingScores.length;

    final progress = ref.read(progressProvider.notifier);
    final coinsEarned = await progress.completeStage(widget.stage.id, _score, speakAvg);
    await ref.read(coinProvider.notifier).addCoins(coinsEarned);

    final speakingQs = widget.stage.questions.where((q) => q.type == QuestionType.speaking).toList();
    final wordCount = speakingQs.where((q) => q.difficulty == DifficultyLevel.beginner).length;
    final phraseCount = speakingQs.where((q) => q.difficulty == DifficultyLevel.intermediate).length;
    final convCount = speakingQs.where((q) => q.difficulty == DifficultyLevel.advanced).length;

    await progress.addSpeakingPractice(
      widget.stage.speakingCount,
      isConversation: convCount > 0,
    );

    // 弱点データを一括記録
    if (_answerLog.isNotEmpty) {
      await ref.read(weaknessProvider.notifier).recordBatch(_answerLog);
    }

    // 日次スピーキング履歴を記録
    await ref.read(speakingHistoryProvider.notifier).addRecord(
      wordCount: wordCount,
      phraseCount: phraseCount,
      conversationCount: convCount,
      avgScore: speakAvg,
    );

    final maxScore = widget.stage.questions.fold(0, (sum, q) => sum + q.points);
    final listeningQs = widget.stage.questions.where((q) => q.type == QuestionType.listening).toList();
    final listeningCorrect = listeningQs.isEmpty ? 0.0 : _correct / listeningQs.length;

    final badges = ref.read(badgeProvider.notifier);
    final newBadges = await badges.checkAndAward(
      ref.read(progressProvider),
      lessonScore: _score,
      lessonTotal: maxScore,
      speakingAvgScore: speakAvg,
      listeningAccuracy: listeningCorrect,
    );

    // XP 付与
    final isFirstClear = !ref.read(progressProvider).clearedStages.contains(widget.stage.id);
    final xpGained = LevelNotifier.xpForLesson(correct: _correct, total: widget.stage.questions.length, isFirstClear: isFirstClear);
    final xpFromBadges = newBadges.length * LevelNotifier.xpForBadge();
    final xpFromSpeaking = LevelNotifier.xpForSpeaking(_speakingScores.length);
    final totalXp = xpGained + xpFromBadges + xpFromSpeaking;
    final levelUps = await ref.read(levelProvider.notifier).addXp(totalXp);
    if (levelUps > 0) {
      ref.read(levelUpNotifier.notifier).notifyLevelUp(ref.read(levelProvider).level);
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/result', arguments: {
        'stage': widget.stage,
        'score': _score,
        'correct': _correct,
        'total': widget.stage.questions.length,
        'speakingAvg': speakAvg.round(),
        'listeningAccuracy': (listeningCorrect * 100).round(),
        'duration': DateTime.now().difference(_startTime),
        'newBadges': newBadges,
        'xpGained': totalXp,
      });
    }
  }

  void _onChoiceSelected(String choice) {
    if (_answered) return;
    final isCorrect = choice == _current.correctAnswer;
    if (isCorrect) {
      _score += _current.points;
      _correct++;
      _confetti.play();
    }
    // 弱点記録
    _answerLog.add((id: _current.id, type: _current.type, correct: isCorrect, speakingScore: 0));
    setState(() {
      _answered = true;
      _selectedAnswer = choice;
    });
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    setState(() { _isListening = true; _recognizedText = ''; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal && text.isNotEmpty) {
          final s = _speech.calculatePronunciationScore(_current.correctAnswer, text);
          setState(() {
            _speakingScore = s;
            _speakingDone = true;
            _isListening = false;
          });
          if (s >= 60) { _score += _current.points; _correct++; }
          _speakingScores.add(s);
          if (s >= 85) _confetti.play();
          // 弱点記録
          _answerLog.add((id: _current.id, type: _current.type, correct: s >= 60, speakingScore: s));

          // ペット育成統合：発音スコア → ペットフィード
          _feedPetFromScore(s, text);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stopListening();
    setState(() { _isListening = false; });
  }

  /// 発音スコアをペット育成に反映
  Future<void> _feedPetFromScore(int pronouncingScore, String recognizedText) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null || pronouncingScore < 60) return;

    try {
      // PronunciationResult を構築（0-1 スケール）
      final accuracy = pronouncingScore / 100.0;
      final result = PronunciationResult(
        word: _current.correctAnswer,
        userPronunciation: recognizedText,
        accuracy: accuracy,
        feedback: '',
        isPassed: accuracy >= 0.7,
      );

      // 統合サービスでペット更新・コイン加算・XP付与
      final feedbackResult = await ref
          .read(pronunciationPetIntegrationProvider)
          .processResult(
            pronunciationResult: result,
            userId: userId,
          );

      // ユーザーへフィードバック表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedbackResult.generateFeedback()),
            duration: const Duration(seconds: 2),
            backgroundColor: feedbackResult.coinsEarned > 0 ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Pet feeding error: $e');
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    _speech.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.stage.questions;
    final progress = (_qIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('${widget.stage.emoji} ${widget.stage.titleJa}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_qIndex + 1} / ${questions.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // プログレスバー
              ImprovedProgressBar(
                progress: progress,
                questionType: _current.type,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // スキルバッジ
                      ImprovedSkillBadge(type: _current.type),
                      AppSpacing.verticalSpacerMd,
                      // 問題カード
                      ImprovedQuestionCard(
                        question: _current,
                        onPlay: () => _tts.speak(_current.text),
                        onPlaySlow: () => _tts.speakSlow(_current.text),
                      ),
                      AppSpacing.verticalSpacerLg,
                      // 回答エリア
                      if (_current.type == QuestionType.speaking)
                        _SpeakingArea(
                          question: _current,
                          isListening: _isListening,
                          recognizedText: _recognizedText,
                          speakingScore: _speakingScore,
                          speakingDone: _speakingDone,
                          onStart: _startListening,
                          onStop: _stopListening,
                          onPlay: () => _tts.speak(_current.text),
                        )
                      else
                        ImprovedChoiceArea(
                          question: _current,
                          answered: _answered,
                          selectedAnswer: _selectedAnswer,
                          onSelect: _onChoiceSelected,
                        ),
                      AppSpacing.verticalSpacerMd,
                      // 解答後の解説パネル
                      if (_answered || _speakingDone)
                        ImprovedAnswerExplanation(
                          question: _current,
                          isCorrect: _current.type == QuestionType.speaking
                              ? _speakingScore >= 60
                              : _selectedAnswer == _current.correctAnswer,
                          onPlayCorrect: () => _tts.speak(_current.correctAnswer),
                        ),
                      AppSpacing.verticalSpacerMd,
                      // 次へボタン
                      if (_answered || _speakingDone)
                        ImprovedNextButton(
                          isLast: _isLastQ,
                          score: _current.type == QuestionType.speaking ? _speakingScore : null,
                          onNext: _nextQ,
                        ),
                    ],
                  ),
                ),
              ),
              // スコア表示
              ImprovedScoreBar(score: _score, correct: _correct, total: _qIndex + 1),
            ],
          ),
          // コンフェッティ
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [kPrimaryColor, kAccentGreen, kAccentOrange, kSpeakingColor],
            ),
          ),
        ],
      ),
    );
  }
}

Color _questionTypeColor(QuestionType t) {
  switch (t) {
    case QuestionType.listening: return kListeningColor;
    case QuestionType.speaking: return kSpeakingColor;
    case QuestionType.reading: return kReadingColor;
    case QuestionType.writing: return kWritingColor;
  }
}

String _questionTypeLabel(QuestionType t) {
  switch (t) {
    case QuestionType.listening: return '👂 Listening';
    case QuestionType.speaking: return '🎤 Speaking';
    case QuestionType.reading: return '📖 Reading';
    case QuestionType.writing: return '✏️ Writing';
  }
}

// ─── Old component definitions removed (now using ImprovedXxx components from lesson_screen_components.dart) ───

class _SpeakingArea extends StatelessWidget {
  final Question question;
  final bool isListening;
  final String recognizedText;
  final int speakingScore;
  final bool speakingDone;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPlay;

  const _SpeakingArea({
    required this.question,
    required this.isListening,
    required this.recognizedText,
    required this.speakingScore,
    required this.speakingDone,
    required this.onStart,
    required this.onStop,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!speakingDone) ...[
              const Text(
                'マイクに向かって発音してみよう！',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: isListening ? onStop : onStart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening ? kSpeakingColor : kPrimaryColor,
                    boxShadow: isListening
                        ? [BoxShadow(color: kSpeakingColor.withAlpha(102), blurRadius: 20, spreadRadius: 5)]
                        : [],
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isListening ? '聞いています...' : 'タップして話す',
                style: TextStyle(
                  color: isListening ? kSpeakingColor : kTextMuted,
                  fontWeight: isListening ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (recognizedText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kBgLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"$recognizedText"',
                    style: const TextStyle(fontSize: 16, color: kTextDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ] else ...[
              // スコア表示
              _SpeakingScoreWidget(score: speakingScore, recognized: recognizedText, expected: question.correctAnswer),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeakingScoreWidget extends StatelessWidget {
  final int score;
  final String recognized;
  final String expected;
  final SpeechService _speech = SpeechService();

  _SpeakingScoreWidget({required this.score, required this.recognized, required this.expected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SpeakingScoreRing(score: score, size: 100),
        const SizedBox(height: 12),
        Text(
          _speech.getFeedback(score),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (recognized.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'あなた: "$recognized"',
            style: const TextStyle(fontSize: 14, color: kTextMuted),
          ),
          Text(
            '正解: "$expected"',
            style: const TextStyle(fontSize: 14, color: kAccentGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
