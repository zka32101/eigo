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
import '../theme/app_theme.dart';
import '../widgets/speaking_score_ring.dart';

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
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stopListening();
    setState(() { _isListening = false; });
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
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: _questionTypeColor(_current.type),
                minHeight: 6,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // スキルバッジ
                      _SkillBadge(type: _current.type),
                      const SizedBox(height: 16),
                      // 問題カード
                      _QuestionCard(
                        question: _current,
                        onPlay: () => _tts.speak(_current.text),
                        onPlaySlow: () => _tts.speakSlow(_current.text),
                      ),
                      const SizedBox(height: 20),
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
                        _ChoiceArea(
                          question: _current,
                          answered: _answered,
                          selectedAnswer: _selectedAnswer,
                          onSelect: _onChoiceSelected,
                        ),
                      const SizedBox(height: 16),
                      // 解答後の解説パネル
                      if (_answered || _speakingDone)
                        _AnswerExplanationCard(
                          question: _current,
                          isCorrect: _current.type == QuestionType.speaking
                              ? _speakingScore >= 60
                              : _selectedAnswer == _current.correctAnswer,
                          onPlay: () => _tts.speak(_current.correctAnswer),
                        ),
                      const SizedBox(height: 16),
                      // 次へボタン
                      if (_answered || _speakingDone)
                        _NextButton(
                          isLast: _isLastQ,
                          score: _current.type == QuestionType.speaking ? _speakingScore : null,
                          onNext: _nextQ,
                          speech: _speech,
                          question: _current,
                        ),
                    ],
                  ),
                ),
              ),
              // スコア表示
              _ScoreBar(score: _score, correct: _correct, total: _qIndex + 1),
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

// ─── Widgets ────────────────────────────────────────────────────

class _SkillBadge extends StatelessWidget {
  final QuestionType type;
  const _SkillBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _questionTypeColor(type);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(76)),
        ),
        child: Text(
          _questionTypeLabel(type),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final Question question;
  final VoidCallback onPlay;
  final VoidCallback onPlaySlow;

  const _QuestionCard({required this.question, required this.onPlay, required this.onPlaySlow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPhonetics = ref.watch(settingsProvider).showPhonetics;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (question.imageEmoji != null)
              Text(question.imageEmoji!, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              question.text,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextDark),
              textAlign: TextAlign.center,
            ),
            if (showPhonetics && question.phonetic != null) ...[
              const SizedBox(height: 4),
              Text(
                question.phonetic!,
                style: const TextStyle(fontSize: 14, color: kTextMuted, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              question.textJa,
              style: const TextStyle(fontSize: 14, color: kTextMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.volume_up),
                  onPressed: onPlay,
                  style: IconButton.styleFrom(backgroundColor: kPrimaryColor),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.slow_motion_video, size: 16),
                  label: const Text('ゆっくり'),
                  onPressed: onPlaySlow,
                  style: OutlinedButton.styleFrom(foregroundColor: kPrimaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceArea extends StatelessWidget {
  final Question question;
  final bool answered;
  final String? selectedAnswer;
  final void Function(String) onSelect;

  const _ChoiceArea({
    required this.question,
    required this.answered,
    required this.selectedAnswer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.choices.map((choice) {
        final isSelected = selectedAnswer == choice;
        final isCorrect = choice == question.correctAnswer;

        Color bgColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = kTextDark;
        Widget? trailingIcon;

        if (answered) {
          if (isCorrect) {
            bgColor = kAccentGreen.withAlpha(26);
            borderColor = kAccentGreen;
            textColor = kAccentGreen;
            trailingIcon = const Icon(Icons.check_circle, color: kAccentGreen);
          } else if (isSelected) {
            bgColor = kAccentRed.withAlpha(26);
            borderColor = kAccentRed;
            textColor = kAccentRed;
            trailingIcon = const Icon(Icons.cancel, color: kAccentRed);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: answered ? null : () => onSelect(choice),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        choice,
                        style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ?trailingIcon,
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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

class _NextButton extends StatelessWidget {
  final bool isLast;
  final int? score;
  final VoidCallback onNext;
  final SpeechService speech;
  final Question question;

  const _NextButton({
    required this.isLast,
    required this.score,
    required this.onNext,
    required this.speech,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLast ? kAccentGreen : kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(isLast ? '結果を見る！🎉' : 'つぎへ →', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final int score;
  final int correct;
  final int total;
  const _ScoreBar({required this.score, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ScorePill('スコア', '$score点', kPrimaryColor),
          _ScorePill('正解', '$correct/$total', kAccentGreen),
        ],
      ),
    );
  }
}

// ─── Answer Explanation Card ─────────────────────────────────────

class _AnswerExplanationCard extends StatelessWidget {
  final Question question;
  final bool isCorrect;
  final VoidCallback onPlay;

  const _AnswerExplanationCard({
    required this.question,
    required this.isCorrect,
    required this.onPlay,
  });

  String _tipForType(QuestionType type) {
    switch (type) {
      case QuestionType.listening: return '👂 もう一度聞いて、正しい音を確認しよう';
      case QuestionType.speaking: return '🎤 口を大きく開けてゆっくり発音しよう';
      case QuestionType.reading: return '📖 文字と音を一緒に覚えよう';
      case QuestionType.writing: return '✏️ 英語のスペルを確認してみよう';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isCorrect
        ? kAccentGreen.withAlpha(20)
        : kAccentRed.withAlpha(15);
    final borderColor = isCorrect ? kAccentGreen : kAccentRed;
    final icon = isCorrect ? '🎉' : '💪';
    final message = isCorrect ? 'よくできました！' : 'おしい！もう一度確認しよう';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 結果ヘッダー
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? kAccentGreen : kAccentRed,
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // 正解
          const Row(
            children: [
              Expanded(
                child: Text(
                  '正解',
                  style: TextStyle(fontSize: 12, color: kTextMuted, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.correctAnswer,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    if (question.phonetic != null)
                      Text(
                        question.phonetic!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      question.textJa,
                      style: const TextStyle(fontSize: 13, color: kTextDark),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                onPressed: onPlay,
                tooltip: '発音を聞く',
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 学習ティップス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tipForType(question.type),
                    style: const TextStyle(fontSize: 12, color: kTextMuted),
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

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ScorePill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
      ],
    );
  }
}
