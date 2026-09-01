import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../providers/coin_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';
import '../widgets/speaking_score_ring.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  late ConfettiController _confetti;

  int _currentIndex = 0;
  bool _isListening = false;
  bool _isDone = false;
  String _recognizedText = '';
  int _score = 0;
  final List<int> _scores = [];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _speech.init();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    _speech.stopListening();
    super.dispose();
  }

  List<Question> get _questions => ref.read(dailyChallengeProvider).questions;
  Question? get _current => _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  Future<void> _speak() async {
    if (_current != null) await _tts.speak(_current!.text);
  }

  Future<void> _startListening() async {
    setState(() { _isListening = true; _recognizedText = ''; _score = 0; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal) _stopAndScore();
      },
    );
  }

  Future<void> _stopAndScore() async {
    await _speech.stopListening();
    if (_current == null) return;
    final s = _speech.calculatePronunciationScore(_current!.correctAnswer, _recognizedText);
    setState(() { _isListening = false; _score = s; });
  }

  void _next() {
    if (_current == null) return;
    _scores.add(_score);
    if (_currentIndex + 1 >= _questions.length) {
      _finish();
    } else {
      setState(() {
        _currentIndex++;
        _recognizedText = '';
        _score = 0;
      });
    }
  }

  Future<void> _finish() async {
    final avg = _scores.isEmpty ? 0 : _scores.reduce((a, b) => a + b) ~/ _scores.length;
    setState(() { _isDone = true; _score = avg; });
    _confetti.play();

    // 完了処理
    await ref.read(dailyChallengeProvider.notifier).markCompleted();
    final bonus = ref.read(dailyChallengeProvider).bonusCoins;
    ref.read(coinProvider.notifier).addCoins(bonus);
    await ref.read(levelProvider.notifier).addXp(50);
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(dailyChallengeProvider);

    if (challenge.isCompleted && !_isDone) {
      return _AlreadyDoneScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('⚡ デイリーチャレンジ'),
        backgroundColor: kAccentOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isDone ? _buildResult() : _buildChallenge(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [kAccentOrange, Colors.yellow, kPrimaryColor, Colors.pink],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    final q = _current;
    if (q == null) return const SizedBox.shrink();
    final total = _questions.length;

    return Padding(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        children: [
          // 進捗バー
          Row(
            children: List.generate(total, (i) => Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < _currentIndex
                      ? kAccentOrange
                      : i == _currentIndex
                          ? kAccentOrange.withAlpha(128)
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
          ),
          AppSpacing.verticalSpacerXs,
          Text('${_currentIndex + 1} / $total', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
          AppSpacing.verticalSpacerXl,

          // 問題カード
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge * 2),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(q.imageEmoji ?? '🎤', style: const TextStyle(fontSize: 72)),
                  AppSpacing.verticalSpacerSm,
                  Text(q.text,
                    style: AppTypography.headlineLarge.copyWith(color: kTextDark),
                    textAlign: TextAlign.center,
                  ),
                  if (q.phonetic != null) ...[
                    AppSpacing.verticalSpacerXs,
                    Text(q.phonetic!, style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  ],
                  AppSpacing.verticalSpacerXs,
                  TextButton.icon(
                    onPressed: _speak,
                    icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                    label: Text('聞く', style: AppTypography.labelLarge.copyWith(color: kPrimaryColor)),
                  ),
                  AppSpacing.verticalSpacerXl,
                  Text('⬇ 英語で言ってみよう！', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  AppSpacing.verticalSpacerSm,
                  // スコアリング
                  if (_score > 0) ...[
                    SpeakingScoreRing(score: _score, size: 80),
                    AppSpacing.verticalSpacerXs,
                    Text(_recognizedText, style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  ] else if (_recognizedText.isNotEmpty) ...[
                    Text(_recognizedText, style: AppTypography.labelLarge.copyWith(color: kTextDark)),
                  ],
                ],
              ),
            ),
          ),

          AppSpacing.verticalSpacerLg,

          // ボタン
          if (_score > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentOrange,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
                ),
                onPressed: _next,
                child: Text(
                  _currentIndex + 1 >= _questions.length ? '結果を見る 🎉' : '次へ →',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? kAccentRed : kSpeakingColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
                ),
                onPressed: _isListening ? _stopAndScore : _startListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                label: Text(
                  _isListening ? '録音停止' : '話す 🎤',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          AppSpacing.verticalSpacerSm,
        ],
      ),
    );
  }

  Widget _buildResult() {
    final avg = _scores.isEmpty ? 0 : _scores.reduce((a, b) => a + b) ~/ _scores.length;
    final grade = avg >= 90 ? 'S' : avg >= 75 ? 'A' : avg >= 60 ? 'B' : avg >= 40 ? 'C' : 'D';
    final bonus = ref.read(dailyChallengeProvider).bonusCoins;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            AppSpacing.verticalSpacerXs,
            Text('デイリーチャレンジ完了！', style: AppTypography.headlineMedium.copyWith(color: kTextDark)),
            AppSpacing.verticalSpacerXl,
            SpeakingScoreRing(score: avg, size: 120),
            AppSpacing.verticalSpacerXs,
            Text('グレード: $grade', style: AppTypography.headlineSmall.copyWith(color: kAccentOrange)),
            AppSpacing.verticalSpacerXl,
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                border: Border.all(color: kAccentOrange, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 28)),
                  AppSpacing.horizontalSpacerXs,
                  Text('+$bonus コイン獲得！',
                    style: AppTypography.labelLarge.copyWith(color: kAccentOrange)),
                ],
              ),
            ),
            AppSpacing.verticalSpacerXxl,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentOrange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ホームに戻る', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyDoneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 72)),
            AppSpacing.verticalSpacerSm,
            Text('今日のチャレンジは完了！',
              style: AppTypography.headlineSmall.copyWith(color: kTextDark)),
            AppSpacing.verticalSpacerXs,
            Text('明日またチャレンジしよう！',
              style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
            AppSpacing.verticalSpacerXxl,
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccentOrange),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('戻る', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
