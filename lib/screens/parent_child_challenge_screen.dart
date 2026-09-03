import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/question.dart';
import '../providers/coin_provider.dart';
import '../providers/progress_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../design_system/design_system.dart';
import '../widgets/speaking_score_ring.dart';

class ParentChildChallengeScreen extends ConsumerStatefulWidget {
  const ParentChildChallengeScreen({super.key});

  @override
  ConsumerState<ParentChildChallengeScreen> createState() =>
      _ParentChildChallengeScreenState();
}

class _ParentChildChallengeScreenState
    extends ConsumerState<ParentChildChallengeScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  late ConfettiController _confetti;

  // ゲームの状態
  int _round = 0;          // 0-based
  static const _totalRounds = 5;
  bool _isChildTurn = true; // true = 子ども, false = 親
  bool _isListening = false;
  bool _isFinished = false;

  String _recognizedText = '';
  int _childScore = 0;
  int _parentScore = 0;
  int _childRoundScore = 0;
  int _parentRoundScore = 0;

  List<Question> _questions = [];
  late Question _currentQuestion;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _speech.init();
    _setupQuestions();
  }

  void _setupQuestions() {
    final all = allStages.expand((s) => s.questions)
        .where((q) => q.type == QuestionType.speaking)
        .toList();
    // ランダムに5問選択（インデックスベース）
    final step = all.length ~/ _totalRounds;
    _questions = List.generate(_totalRounds, (i) => all[(i * step + 3) % all.length]);
    _currentQuestion = _questions[0];
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    _speech.stopListening();
    super.dispose();
  }

  Future<void> _speak() async => _tts.speak(_currentQuestion.text);

  Future<void> _startListening() async {
    setState(() { _isListening = true; _recognizedText = ''; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal) _stopAndScore();
      },
    );
  }

  Future<void> _stopAndScore() async {
    await _speech.stopListening();
    final score = _speech.calculatePronunciationScore(_currentQuestion.correctAnswer, _recognizedText);
    setState(() {
      _isListening = false;
      if (_isChildTurn) {
        _childRoundScore = score;
      } else {
        _parentRoundScore = score;
      }
    });
  }

  void _confirmAndNext() {
    if (_isChildTurn) {
      // 子どもが終わったら親の番
      setState(() {
        _isChildTurn = false;
        _recognizedText = '';
      });
    } else {
      // 両方終わったのでラウンド結果を集計
      setState(() {
        _childScore += _childRoundScore;
        _parentScore += _parentRoundScore;
        _childRoundScore = 0;
        _parentRoundScore = 0;
        _round++;
        _isChildTurn = true;
        _recognizedText = '';
      });
      if (_round >= _totalRounds) {
        _finish();
      } else {
        _currentQuestion = _questions[_round];
      }
    }
  }

  void _finish() {
    setState(() { _isFinished = true; });
    _confetti.play();
    // コイン付与（両者に）
    final bonus = (_childScore + _parentScore) ~/ (_totalRounds * 2);
    ref.read(coinProvider.notifier).addCoins(bonus ~/ 5 + 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('👨‍👩‍👧 親子チャレンジ'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isFinished ? _buildResult() : _buildGame(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [AppColors.accentPink, AppColors.accentOrange, AppColors.primary, AppColors.accentOrange],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    final scored = _isChildTurn ? _childRoundScore > 0 : _parentRoundScore > 0;
    final currentPlayerLabel = _isChildTurn ? '👧 子ども' : '👨 おうちの人';
    final playerColor = _isChildTurn ? AppColors.primary : const Color(0xFFE91E63);

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        children: [
          // スコアボード
          Row(
            children: [
              Expanded(child: _PlayerScore(
                label: '👧 子ども',
                score: _childScore,
                color: AppColors.primary,
                isActive: _isChildTurn,
              )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  children: [
                    Text('第${_round + 1}問', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                    Text('VS', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                    Text('全$_totalRounds問', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Expanded(child: _PlayerScore(
                label: '👨 おうちの人',
                score: _parentScore,
                color: const Color(0xFFE91E63),
                isActive: !_isChildTurn,
              )),
            ],
          ),

          AppSpacing.verticalSpacerLg,

          // 現在のプレイヤー表示
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: playerColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Text('$currentPlayerLabel の番！',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
          ),

          AppSpacing.verticalSpacerLg,

          // 問題カード
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              boxShadow: [BoxShadow(color: AppColors.textPrimary.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(_currentQuestion.imageEmoji ?? '🎤', style: AppTypography.headlineLarge),
                AppSpacing.verticalSpacerXs,
                Text(_currentQuestion.text,
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
                if (_currentQuestion.phonetic != null) ...[
                  AppSpacing.verticalSpacerXs,
                  Text(_currentQuestion.phonetic!, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
                AppSpacing.verticalSpacerSm,
                TextButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                  label: const Text('聞く', style: TextStyle(color: AppColors.primary)),
                ),
                if (scored) ...[
                  AppSpacing.verticalSpacerMd,
                  SpeakingScoreRing(
                    score: _isChildTurn ? _childRoundScore : _parentRoundScore,
                    size: 80,
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text('"$_recognizedText"', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ] else if (_recognizedText.isNotEmpty) ...[
                  AppSpacing.verticalSpacerXs,
                  Text('"$_recognizedText"', style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
                ],
              ],
            ),
          ),

          AppSpacing.verticalSpacerLg,

          // ボタン
          if (scored)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: playerColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                ),
                onPressed: _confirmAndNext,
                child: Text(
                  _isChildTurn ? '次は おうちの人の番！' : (_round + 1 >= _totalRounds ? '結果を見る！🎉' : '次の問題へ！'),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? AppColors.error : playerColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                ),
                onPressed: _isListening ? _stopAndScore : _startListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic, color: AppColors.textWhite),
                label: Text(
                  _isListening ? '録音停止' : '話す 🎤',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
                ),
              ),
            ),
          AppSpacing.verticalSpacerXl,
        ],
      ),
    );
  }

  Widget _buildResult() {
    final childAvg = _childScore ~/ _totalRounds;
    final parentAvg = _parentScore ~/ _totalRounds;
    final childWins = childAvg > parentAvg;
    final draw = childAvg == parentAvg;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(draw ? '🤝' : childWins ? '👧' : '👨',
              style: AppTypography.headlineLarge),
            AppSpacing.verticalSpacerXs,
            Text(
              draw ? '引き分け！' : (childWins ? '子どもの勝ち！' : 'おうちの人の勝ち！'),
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            AppSpacing.verticalSpacerLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResultCard(label: '👧 子ども', score: _childScore, total: _totalRounds, color: AppColors.primary),
                AppSpacing.horizontalSpacerMd,
                _ResultCard(label: '👨 おうちの人', score: _parentScore, total: _totalRounds, color: const Color(0xFFE91E63)),
              ],
            ),
            AppSpacing.verticalSpacerLg,
            Text('チャレンジしてくれてありがとう！\n次はもっと上手くなろう！',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
            AppSpacing.verticalSpacerLg,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ホームに戻る',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isActive;
  const _PlayerScore({required this.label, required this.score, required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.xs),
    decoration: BoxDecoration(
      color: isActive ? color.withAlpha(30) : AppColors.textWhite,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      border: Border.all(color: isActive ? color : AppColors.bgLight, width: isActive ? 2 : 1),
    ),
    child: Column(
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        AppSpacing.verticalSpacerXs,
        Text('$score', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text('点', style: AppTypography.bodySmall.copyWith(color: color)),
      ],
    ),
  );
}

class _ResultCard extends StatelessWidget {
  final String label;
  final int score;
  final int total;
  final Color color;
  const _ResultCard({required this.label, required this.score, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final avg = total > 0 ? score ~/ total : 0;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
          AppSpacing.verticalSpacerXs,
          SpeakingScoreRing(score: avg, size: 72),
          AppSpacing.verticalSpacerXs,
          Text('合計 $score点', style: AppTypography.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
