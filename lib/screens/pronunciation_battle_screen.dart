import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/stage_data.dart';
import '../models/question.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/speaking_score_ring.dart';

class PronunciationBattleScreen extends ConsumerStatefulWidget {
  const PronunciationBattleScreen({super.key});

  @override
  ConsumerState<PronunciationBattleScreen> createState() =>
      _PronunciationBattleScreenState();
}

class _PronunciationBattleScreenState
    extends ConsumerState<PronunciationBattleScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  late ConfettiController _confetti;

  Question? _selectedQuestion;
  bool _isListening = false;
  String _recognizedText = '';
  int _currentScore = 0;
  bool _hasResult = false;

  // 問題ごとの過去スコア（SharedPrefsから）
  List<int> _pastScores = [];
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _speech.init();
    final speakers = allStages.expand((s) => s.questions)
        .where((q) => q.type == QuestionType.speaking)
        .toList();
    if (speakers.isNotEmpty) {
      _selectedQuestion = speakers.first;
      _loadScores();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    _speech.stopListening();
    super.dispose();
  }

  Future<void> _loadScores() async {
    if (_selectedQuestion == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'pb_${_selectedQuestion!.id}';
    final raw = prefs.getStringList(key) ?? [];
    final scores = raw.map((s) => int.tryParse(s) ?? 0).toList();
    setState(() {
      _pastScores = scores.reversed.take(10).toList().reversed.toList();
      _bestScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
    });
  }

  Future<void> _saveScore(int score) async {
    if (_selectedQuestion == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'pb_${_selectedQuestion!.id}';
    final raw = prefs.getStringList(key) ?? [];
    raw.add(score.toString());
    // 最大30件保持
    final trimmed = raw.length > 30 ? raw.sublist(raw.length - 30) : raw;
    await prefs.setStringList(key, trimmed);
  }

  Future<void> _speak() async {
    if (_selectedQuestion != null) await _tts.speak(_selectedQuestion!.text);
  }

  Future<void> _startListening() async {
    setState(() { _isListening = true; _recognizedText = ''; _hasResult = false; _currentScore = 0; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal) _stopAndScore();
      },
    );
  }

  Future<void> _stopAndScore() async {
    await _speech.stopListening();
    if (_selectedQuestion == null) return;
    final s = _speech.calculatePronunciationScore(_selectedQuestion!.correctAnswer, _recognizedText);
    await _saveScore(s);
    await _loadScores();
    setState(() { _isListening = false; _currentScore = s; _hasResult = true; });
    if (s >= 85) _confetti.play();
  }

  void _selectQuestion(Question q) {
    setState(() {
      _selectedQuestion = q;
      _hasResult = false;
      _currentScore = 0;
      _recognizedText = '';
      _pastScores = [];
      _bestScore = 0;
    });
    _loadScores();
  }

  @override
  Widget build(BuildContext context) {
    final speakingQuestions = allStages
        .expand((s) => s.questions)
        .where((q) => q.type == QuestionType.speaking)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: const Text('🎤 発音バトル'),
        backgroundColor: kSpeakingColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 問題選択
            const Text('問題を選ぼう',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: speakingQuestions.length > 40 ? 40 : speakingQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final q = speakingQuestions[i];
                  final selected = q.id == _selectedQuestion?.id;
                  return GestureDetector(
                    onTap: () => _selectQuestion(q),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? kSpeakingColor : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: kSpeakingColor, width: selected ? 0 : 1),
                      ),
                      child: Text(
                        q.text,
                        style: TextStyle(
                          color: selected ? Colors.white : kSpeakingColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            if (_selectedQuestion != null) ...[
              // 問題カード
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(_selectedQuestion!.imageEmoji ?? '🎤',
                      style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text(_selectedQuestion!.text,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark)),
                    if (_selectedQuestion!.phonetic != null) ...[
                      const SizedBox(height: 4),
                      Text(_selectedQuestion!.phonetic!,
                        style: const TextStyle(fontSize: 14, color: kTextMuted)),
                    ],
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _speak,
                      icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                      label: const Text('手本を聞く', style: TextStyle(color: kPrimaryColor)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // スコア比較
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      label: '🏆 自己ベスト',
                      score: _bestScore,
                      color: kAccentOrange,
                      dimmed: _bestScore == 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      label: '⚡ 今回',
                      score: _hasResult ? _currentScore : 0,
                      color: kSpeakingColor,
                      dimmed: !_hasResult,
                    ),
                  ),
                ],
              ),

              if (_hasResult && _bestScore > 0) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentScore >= _bestScore
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentScore >= _bestScore
                          ? '🎉 新記録！'
                          : '📈 ベストまで ${_bestScore - _currentScore}点',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _currentScore >= _bestScore ? kAccentGreen : kAccentOrange,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 過去スコアグラフ
              if (_pastScores.length >= 2) ...[
                const Text('過去の推移',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LineChart(LineChartData(
                    minY: 0, maxY: 100,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _pastScores.asMap().entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: kSpeakingColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: kSpeakingColor.withAlpha(40),
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 16),
              ],

              if (_recognizedText.isNotEmpty && _hasResult) ...[
                Text('認識: "$_recognizedText"',
                  style: const TextStyle(fontSize: 13, color: kTextMuted, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
              ],

              // 録音ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? kAccentRed : kSpeakingColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isListening ? _stopAndScore : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                  label: Text(
                    _isListening ? '録音停止' : (_hasResult ? 'もう一度挑戦 🔄' : '話す 🎤'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool dimmed;
  const _ScoreCard({required this.label, required this.score, required this.color, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dimmed ? Colors.grey.shade100 : color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dimmed ? Colors.grey.shade300 : color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: dimmed ? Colors.grey : color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            dimmed ? '--' : '$score',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: dimmed ? Colors.grey : color),
          ),
          Text('点', style: TextStyle(fontSize: 12, color: dimmed ? Colors.grey : color)),
        ],
      ),
    );
  }
}
