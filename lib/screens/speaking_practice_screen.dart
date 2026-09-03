import '../design_system/design_system.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/question.dart';
import '../models/stage.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/speaking_history_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/speaking_score_ring.dart';

/// スピーキング集中練習モード
/// 選択したステージのスピーキング問題のみを繰り返し練習できる
class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  const SpeakingPracticeScreen({super.key});

  @override
  ConsumerState<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends ConsumerState<SpeakingPracticeScreen> {
  Stage? _selectedStage;
  final _tts = TtsService();
  final _speech = SpeechService();
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  List<Question> _questions = [];
  int _qIndex = 0;
  bool _isListening = false;
  String _recognizedText = '';
  int _speakingScore = 0;
  bool _answered = false;
  bool _practicing = false;
  final List<int> _scores = [];
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _speech.init();
  }

  void _startPractice(Stage stage) {
    final qs = stage.questions.where((q) => q.type == QuestionType.speaking).toList();
    setState(() {
      _selectedStage = stage;
      _questions = qs;
      _qIndex = 0;
      _scores.clear();
      _answered = false;
      _recognizedText = '';
      _speakingScore = 0;
      _practicing = true;
    });
    // 最初の問題を自動読み上げ
    if (qs.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _tts.speak(qs[0].text);
      });
    }
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    setState(() { _isListening = true; _recognizedText = ''; _answered = false; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() => _recognizedText = text);
        if (isFinal && text.isNotEmpty) {
          final s = _speech.calculatePronunciationScore(_questions[_qIndex].correctAnswer, text);
          setState(() { _speakingScore = s; _answered = true; _isListening = false; });
          _scores.add(s);
          if (s >= 85) _confetti.play();
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stopListening();
    setState(() => _isListening = false);
  }

  void _retry() {
    setState(() {
      _answered = false;
      _recognizedText = '';
      _speakingScore = 0;
      _retryCount++;
    });
    _tts.speak(_questions[_qIndex].text);
  }

  void _next() {
    if (_qIndex >= _questions.length - 1) {
      _finishPractice();
      return;
    }
    setState(() {
      _qIndex++;
      _answered = false;
      _recognizedText = '';
      _speakingScore = 0;
      _retryCount = 0;
    });
    _tts.speak(_questions[_qIndex].text);
  }

  Future<void> _finishPractice() async {
    final avg = _scores.isEmpty ? 0.0 : _scores.reduce((a, b) => a + b) / _scores.length;
    // 履歴に記録
    await ref.read(speakingHistoryProvider.notifier).addRecord(
      wordCount: _questions.where((q) => q.difficulty == DifficultyLevel.beginner).length,
      phraseCount: _questions.where((q) => q.difficulty == DifficultyLevel.intermediate).length,
      conversationCount: _questions.where((q) => q.difficulty == DifficultyLevel.advanced).length,
      avgScore: avg,
    );
    await ref.read(progressProvider.notifier).addSpeakingPractice(_questions.length);

    // XP 付与
    final xp = LevelNotifier.xpForSpeaking(_questions.length);
    final levelUps = await ref.read(levelProvider.notifier).addXp(xp);
    if (levelUps > 0) {
      ref.read(levelUpNotifier.notifier).notifyLevelUp(ref.read(levelProvider).level);
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _PracticeResultDialog(
          scores: List.from(_scores),
          questions: _questions,
          onRetry: () {
            Navigator.pop(ctx);
            _startPractice(_selectedStage!);
          },
          onBack: () {
            Navigator.pop(ctx);
            setState(() { _practicing = false; _selectedStage = null; });
          },
        ),
      );
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
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 スピーキング練習'),
        backgroundColor: AppColors.speakingColor,
      ),
      body: _practicing ? _buildPracticeView() : _buildStageSelectView(progress),
    );
  }

  Widget _buildStageSelectView(ProgressState progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.allPaddingMd,
          color: AppColors.speakingColor.withAlpha(20),
          child: Row(
            children: [
              const Text('🎤', style: TextStyle(fontSize: 28)),
              AppSpacing.horizontalSpacerXs,
              Expanded(
                child: Text(
                  'ステージを選んでスピーキングだけを集中練習しよう！',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.allPaddingMd,
            itemCount: allStages.length,
            itemBuilder: (_, i) {
              final stage = allStages[i];
              final isLocked = i > 0 && !progress.isCleared(allStages[i - 1].id);
              final isCleared = progress.isCleared(stage.id);
              final speakAvg = progress.stageSpeakingAvg[stage.id];

              return Card(
                margin: EdgeInsets.only(bottom: AppSpacing.xs),
                color: isLocked ? AppColors.bgLight :AppColors.textWhite,
                child: ListTile(
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isLocked ? AppColors.bgLight : AppColors.speakingColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(Icons.lock, color: AppColors.textMuted)
                          : Text(stage.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  title: Text(
                    '${stage.titleJa}（${stage.title}）',
                    style: AppTypography.labelLarge.copyWith(
                      color: isLocked ? Colors.grey : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.speakingColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                        ),
                        child: Text(
                          '🎤 ${stage.speakingCount}問',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.speakingColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      if (speakAvg != null) ...[
                        SizedBox(width: AppSpacing.xs),
                        Text('前回: ${speakAvg.round()}点',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ],
                  ),
                  trailing: isLocked ? null : Icon(
                    isCleared ? Icons.replay : Icons.play_arrow,
                    color: AppColors.speakingColor,
                  ),
                  onTap: isLocked ? null : () => _startPractice(stage),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeView() {
    final q = _questions[_qIndex];
    return Stack(
      children: [
        Column(
          children: [
            // ヘッダー
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              color: AppColors.speakingColor,
              child: Row(
                children: [
                  Text(
                    '${_selectedStage!.emoji} ${_selectedStage!.titleJa}',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
                  ),
                  const Spacer(),
                  Text(
                    '${_qIndex + 1} / ${_questions.length}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_qIndex + 1) / _questions.length,
              backgroundColor:AppColors.textMuted,
              color: AppColors.speakingColor,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.allPaddingLg,
                child: Column(
                  children: [
                    // 問題カード
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.speakingColor, Color(0xFFFF6B9D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                        ),
                        child: Column(
                          children: [
                            if (q.imageEmoji != null)
                              Text(q.imageEmoji!, style: const TextStyle(fontSize: 56)),
                            AppSpacing.verticalSpacerXs,
                            Text(
                              q.textJa.replaceAll('言ってみよう', '').replaceAll('英語で', '').trim(),
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
                            ),
                            AppSpacing.verticalSpacerXs,
                            Text(
                              q.text,
                              style: AppTypography.headlineLarge.copyWith(color: AppColors.textWhite),
                              textAlign: TextAlign.center,
                            ),
                            if (q.phonetic != null) ...[
                              AppSpacing.verticalSpacerXs,
                              Text(q.phonetic!, style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.6), fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.verticalSpacerMd,
                    // TTS ボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.volume_up),
                          label: const Text('聞く'),
                          onPressed: () => _tts.speak(q.text),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                        AppSpacing.horizontalSpacerXs,
                        OutlinedButton.icon(
                          icon: const Icon(Icons.slow_motion_video, size: 16),
                          label: const Text('ゆっくり'),
                          onPressed: () => _tts.speakSlow(q.text),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXl,
                    // マイクエリア
                    if (!_answered) ...[
                      GestureDetector(
                        onTap: _isListening ? _stopListening : _startListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? AppColors.speakingColor :AppColors.textMuted,
                            boxShadow: _isListening
                                ? [BoxShadow(color: AppColors.speakingColor.withAlpha(100), blurRadius: 24, spreadRadius: 6)]
                                : [],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color:AppColors.textWhite, size: 40,
                          ),
                        ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        _isListening ? '聞いています...' : 'タップして発音',
                        style: AppTypography.labelLarge.copyWith(
                          color: _isListening ? AppColors.speakingColor : AppColors.textMuted,
                        ),
                      ),
                      if (_recognizedText.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xs),
                          child: Text('"$_recognizedText"',
                              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                        ),
                    ] else ...[
                      SpeakingScoreRing(score: _speakingScore, size: 100),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        _speech.getFeedback(_speakingScore),
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSpacerLg,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.replay),
                              label: Text('もう一度${_retryCount > 0 ? " (${_retryCount + 1}回目)" : ""}'),
                              onPressed: _retry,
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.speakingColor),
                            ),
                          ),
                          AppSpacing.horizontalSpacerXs,
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(_qIndex >= _questions.length - 1 ? Icons.flag : Icons.arrow_forward),
                              label: Text(_qIndex >= _questions.length - 1 ? '完了' : 'つぎへ'),
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.speakingColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
            colors: const [AppColors.speakingColor, AppColors.primary, AppColors.accentGreen],
          ),
        ),
      ],
    );
  }
}

class _PracticeResultDialog extends StatelessWidget {
  final List<int> scores;
  final List<Question> questions;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _PracticeResultDialog({
    required this.scores,
    required this.questions,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final avg = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) ~/ scores.length;
    final best = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
    final perfect = scores.where((s) => s >= 85).length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
      contentPadding: EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(avg >= 80 ? '🎉' : avg >= 60 ? '😊' : '💪', style: const TextStyle(fontSize: 56)),
          AppSpacing.verticalSpacerXs,
          Text(
            avg >= 80 ? 'すばらしい練習でした！' : avg >= 60 ? 'よく頑張りました！' : 'もう一度挑戦しよう！',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat('平均', '$avg点', AppColors.speakingColor),
              _Stat('最高', '$best点', AppColors.accentGreen),
              _Stat('85点↑', '$perfect/${questions.length}問', AppColors.accentOrange),
            ],
          ),
          AppSpacing.verticalSpacerLg,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('もう一度'),
                ),
              ),
              AppSpacing.horizontalSpacerXs,
              Expanded(
                child: ElevatedButton(
                  onPressed: onBack,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.speakingColor),
                  child: const Text('ステージ選択'),
                ),
              ),
            ],
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
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12)),
    ],
  );
}
