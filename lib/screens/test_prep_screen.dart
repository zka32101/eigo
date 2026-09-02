import '../design_system/design_system.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../providers/level_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weakness_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/speaking_score_ring.dart';

/// テスト対策モード: 弱点問題を集めた特別レッスン
class TestPrepScreen extends ConsumerStatefulWidget {
  const TestPrepScreen({super.key});

  @override
  ConsumerState<TestPrepScreen> createState() => _TestPrepScreenState();
}

class _TestPrepScreenState extends ConsumerState<TestPrepScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  List<Question> _questions = [];
  int _qIndex = 0;
  int _score = 0;
  int _correct = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _isListening = false;
  String _recognizedText = '';
  int _speakingScore = 0;
  bool _speakingDone = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _speech.init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestions());
  }

  void _loadQuestions() {
    final weakness = ref.read(weaknessProvider);
    final weakQ = weakness.weakQuestionsAcrossAllStages;
    if (weakQ.isEmpty) {
      setState(() { _questions = weakQ; _started = true; });
    } else {
      setState(() { _questions = weakQ.take(15).toList(); _started = true; });
    }
    if (_questions.isNotEmpty && _questions[0].type == QuestionType.listening) {
      _autoPlay();
    }
  }

  Future<void> _autoPlay() async {
    final settings = ref.read(settingsProvider);
    if (!settings.autoPlayListening) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted && _qIndex < _questions.length && _questions[_qIndex].type == QuestionType.listening) {
      await _tts.speak(_questions[_qIndex].text);
    }
  }

  Question get _current => _questions[_qIndex];
  bool get _isLast => _qIndex >= _questions.length - 1;

  void _onChoiceSelected(String choice) {
    if (_answered) return;
    final isCorrect = choice == _current.correctAnswer;
    if (isCorrect) { _score += _current.points; _correct++; _confetti.play(); }
    setState(() { _answered = true; _selectedAnswer = choice; });
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    setState(() { _isListening = true; _recognizedText = ''; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal && text.isNotEmpty) {
          final s = _speech.calculatePronunciationScore(_current.correctAnswer, text);
          setState(() { _speakingScore = s; _speakingDone = true; _isListening = false; });
          if (s >= 60) { _score += _current.points; _correct++; }
          if (s >= 85) _confetti.play();
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stopListening();
    setState(() => _isListening = false);
  }

  void _next() {
    if (_isLast) { _finish(); return; }
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
    final accuracy = _questions.isEmpty ? 0.0 : _correct / _questions.length;

    // XP 付与
    final xp = LevelNotifier.xpForTestPrep(correct: _correct, total: _questions.length);
    final levelUps = await ref.read(levelProvider.notifier).addXp(xp);
    if (levelUps > 0) {
      ref.read(levelUpNotifier.notifier).notifyLevelUp(ref.read(levelProvider).level);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/test-prep-result', arguments: {
      'score': _score,
      'correct': _correct,
      'total': _questions.length,
      'accuracy': accuracy,
    });
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
    if (!_started) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('🎯 テスト対策'), backgroundColor: AppColors.primary),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              AppSpacing.verticalSpacerMd,
              Text('弱点問題がありません！', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpacerXs,
              Text('全問題を正確に解けています。\nすごい！', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              AppSpacing.verticalSpacerXl,
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.error,
        title: const Text('🎯 テスト対策モード'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '${_qIndex + 1} / ${_questions.length}',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (_qIndex + 1) / _questions.length,
                backgroundColor:AppColors.textMuted,
                color: AppColors.error,
                minHeight: 6,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.allPaddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 弱点バッジ
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 6),
                        margin: EdgeInsets.only(bottom: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                          border: Border.all(color: AppColors.error.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⚠️', style: TextStyle(fontSize: 14)),
                            AppSpacing.horizontalSpacerXs,
                            Text(
                              '弱点問題 - ${_typeLabel(_current.type)}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // 問題カード
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              if (_current.imageEmoji != null)
                                Text(_current.imageEmoji!, style: const TextStyle(fontSize: 60)),
                              AppSpacing.verticalSpacerXs,
                              Text(
                                _current.text,
                                style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              if (_current.phonetic != null) ...[
                                AppSpacing.verticalSpacerXs,
                                Text(_current.phonetic!,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                              ],
                              AppSpacing.verticalSpacerXs,
                              Text(_current.textJa,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                  textAlign: TextAlign.center),
                              AppSpacing.verticalSpacerXs,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton.filled(
                                    icon: const Icon(Icons.volume_up),
                                    onPressed: () => _tts.speak(_current.text),
                                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                                  ),
                                  AppSpacing.horizontalSpacerXs,
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.slow_motion_video, size: 16),
                                    label: const Text('ゆっくり'),
                                    onPressed: () => _tts.speakSlow(_current.text),
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.verticalSpacerLg,
                      // 回答エリア
                      if (_current.type == QuestionType.speaking)
                        _buildSpeakingArea()
                      else
                        _buildChoiceArea(),
                      AppSpacing.verticalSpacerLg,
                      if (_answered || _speakingDone)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLast ? AppColors.accentGreen : AppColors.error,
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                            ),
                            child: Text(_isLast ? '結果を見る！🎉' : 'つぎへ →',
                                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // スコアバー
              Container(
                color:AppColors.textWhite,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('$_score', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                      Text('スコア', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
                    ]),
                    Column(children: [
                      Text('$_correct/${_qIndex + 1}', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                      Text('正解', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
                    ]),
                  ],
                ),
              ),
            ],
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

  Widget _buildChoiceArea() {
    return Column(
      children: _current.choices.map((choice) {
        final isSelected = _selectedAnswer == choice;
        final isCorrect = choice == _current.correctAnswer;
        Color bg = AppColors.textWhite;
        Color border = AppColors.bgLight;
        Color text = AppColors.textPrimary;
        Widget? icon;
        if (_answered) {
          if (isCorrect) { bg = AppColors.accentGreen.withAlpha(26); border = AppColors.accentGreen; text = AppColors.accentGreen; icon = const Icon(Icons.check_circle, color: AppColors.accentGreen); }
          else if (isSelected) { bg = AppColors.error.withAlpha(26); border = AppColors.error; text = AppColors.error; icon = const Icon(Icons.cancel, color: AppColors.error); }
        }
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xs),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              onTap: _answered ? null : () => _onChoiceSelected(choice),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: border, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(choice, style: AppTypography.labelLarge.copyWith(color: text))),
                    if (icon != null) icon,
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpeakingArea() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: _speakingDone
            ? Column(
                children: [
                  SpeakingScoreRing(score: _speakingScore, size: 100),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    _speech.getFeedback(_speakingScore),
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (_recognizedText.isNotEmpty) ...[
                    AppSpacing.verticalSpacerXs,
                    Text('あなた: "$_recognizedText"', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                    Text('正解: "${_current.correctAnswer}"',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.bold)),
                  ],
                ],
              )
            : Column(
                children: [
                  Text('マイクに向かって発音してみよう！',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  AppSpacing.verticalSpacerLg,
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? AppColors.speakingColor : AppColors.error,
                        boxShadow: _isListening
                            ? [BoxShadow(color: AppColors.speakingColor.withAlpha(100), blurRadius: 20, spreadRadius: 5)]
                            : [],
                      ),
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: AppColors.textWhite, size: 36),
                    ),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    _isListening ? '聞いています...' : 'タップして話す',
                    style: AppTypography.labelLarge.copyWith(
                      color: _isListening ? AppColors.speakingColor : AppColors.textMuted,
                    ),
                  ),
                  if (_recognizedText.isNotEmpty) ...[
                    AppSpacing.verticalSpacerXs,
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                      child: Text('"$_recognizedText"',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary), textAlign: TextAlign.center),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

String _typeLabel(QuestionType t) {
  switch (t) {
    case QuestionType.listening: return '👂 リスニング';
    case QuestionType.speaking: return '🎤 スピーキング';
    case QuestionType.reading: return '📖 リーディング';
    case QuestionType.writing: return '✏️ ライティング';
  }
}
