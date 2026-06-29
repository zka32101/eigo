import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/question.dart';
import '../providers/coin_provider.dart';
import '../providers/progress_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
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
        foregroundColor: Colors.white,
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
              colors: const [Colors.pink, Colors.yellow, kPrimaryColor, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    final scored = _isChildTurn ? _childRoundScore > 0 : _parentRoundScore > 0;
    final currentPlayerLabel = _isChildTurn ? '👧 子ども' : '👨 おうちの人';
    final playerColor = _isChildTurn ? kPrimaryColor : const Color(0xFFE91E63);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // スコアボード
          Row(
            children: [
              Expanded(child: _PlayerScore(
                label: '👧 子ども',
                score: _childScore,
                color: kPrimaryColor,
                isActive: _isChildTurn,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text('第${_round + 1}問', style: const TextStyle(fontSize: 12, color: kTextMuted)),
                    const Text('VS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextDark)),
                    Text('全$_totalRounds問', style: const TextStyle(fontSize: 12, color: kTextMuted)),
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

          const SizedBox(height: 20),

          // 現在のプレイヤー表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: playerColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text('$currentPlayerLabel の番！',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),

          const SizedBox(height: 20),

          // 問題カード
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(_currentQuestion.imageEmoji ?? '🎤', style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                Text(_currentQuestion.text,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kTextDark)),
                if (_currentQuestion.phonetic != null) ...[
                  const SizedBox(height: 4),
                  Text(_currentQuestion.phonetic!, style: const TextStyle(fontSize: 14, color: kTextMuted)),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                  label: const Text('聞く', style: TextStyle(color: kPrimaryColor)),
                ),
                if (scored) ...[
                  const SizedBox(height: 16),
                  SpeakingScoreRing(
                    score: _isChildTurn ? _childRoundScore : _parentRoundScore,
                    size: 80,
                  ),
                  const SizedBox(height: 4),
                  Text('"$_recognizedText"', style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ] else if (_recognizedText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('"$_recognizedText"', style: const TextStyle(fontSize: 14, color: kTextDark)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ボタン
          if (scored)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: playerColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _confirmAndNext,
                child: Text(
                  _isChildTurn ? '次は おうちの人の番！' : (_round + 1 >= _totalRounds ? '結果を見る！🎉' : '次の問題へ！'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? kAccentRed : playerColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isListening ? _stopAndScore : _startListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                label: Text(
                  _isListening ? '録音停止' : '話す 🎤',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 32),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(draw ? '🤝' : childWins ? '👧' : '👨',
              style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 8),
            Text(
              draw ? '引き分け！' : (childWins ? '子どもの勝ち！' : 'おうちの人の勝ち！'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResultCard(label: '👧 子ども', score: _childScore, total: _totalRounds, color: kPrimaryColor),
                const SizedBox(width: 16),
                _ResultCard(label: '👨 おうちの人', score: _parentScore, total: _totalRounds, color: const Color(0xFFE91E63)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('チャレンジしてくれてありがとう！\n次はもっと上手くなろう！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: kTextMuted)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ホームに戻る',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isActive ? color.withAlpha(30) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isActive ? color : Colors.grey.shade200, width: isActive ? 2 : 1),
    ),
    child: Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$score', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text('点', style: TextStyle(fontSize: 11, color: color)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SpeakingScoreRing(score: avg, size: 72),
          const SizedBox(height: 4),
          Text('合計 $score点', style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
