import '../design_system/design_system.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/stage_data.dart';
import '../models/question.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
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
        backgroundColor: AppColors.speakingColor,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.allPaddingMd,
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 問題選択
            Text('問題を選ぼう',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.verticalSpacerXs,
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: speakingQuestions.length > 40 ? 40 : speakingQuestions.length,
                separatorBuilder: (_, __) => AppSpacing.horizontalSpacerXs,
                itemBuilder: (ctx, i) {
                  final q = speakingQuestions[i];
                  final selected = q.id == _selectedQuestion?.id;
                  return GestureDetector(
                    onTap: () => _selectQuestion(q),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.speakingColor :AppColors.textWhite,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                        border: Border.all(color: AppColors.speakingColor, width: selected ? 0 : 1),
                      ),
                      child: Text(
                        q.text,
                        style: AppTypography.bodySmall.copyWith(
                          color: selected ? Colors.white : AppColors.speakingColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            AppSpacing.verticalSpacerLg,

            if (_selectedQuestion != null) ...[
              // 問題カード
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color:AppColors.textWhite,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                  boxShadow: [BoxShadow(color: AppColors.textPrimary.withAlpha(15), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(_selectedQuestion!.imageEmoji ?? '🎤',
                      style: AppTypography.headlineLarge),
                    AppSpacing.verticalSpacerXs,
                    Text(_selectedQuestion!.text,
                      style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
                    if (_selectedQuestion!.phonetic != null) ...[
                      AppSpacing.verticalSpacerXs,
                      Text(_selectedQuestion!.phonetic!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                    ],
                    AppSpacing.verticalSpacerSm,
                    TextButton.icon(
                      onPressed: _speak,
                      icon: const Icon(Icons.volume_up, color: AppColors.primary),
                      label: const Text('手本を聞く', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpacerMd,

              // スコア比較
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      label: '🏆 自己ベスト',
                      score: _bestScore,
                      color: AppColors.accentOrange,
                      dimmed: _bestScore == 0,
                    ),
                  ),
                  AppSpacing.horizontalSpacerSm,
                  Expanded(
                    child: _ScoreCard(
                      label: '⚡ 今回',
                      score: _hasResult ? _currentScore : 0,
                      color: AppColors.speakingColor,
                      dimmed: !_hasResult,
                    ),
                  ),
                ],
              ),

              if (_hasResult && _bestScore > 0) ...[
                AppSpacing.verticalSpacerXs,
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: _currentScore >= _bestScore
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: Text(
                      _currentScore >= _bestScore
                          ? '🎉 新記録！'
                          : '📈 ベストまで ${_bestScore - _currentScore}点',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _currentScore >= _bestScore ? AppColors.accentGreen : AppColors.accentOrange,
                      ),
                    ),
                  ),
                ),
              ],

              AppSpacing.verticalSpacerMd,

              // 過去スコアグラフ
              if (_pastScores.length >= 2) ...[
                Text('過去の推移',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                AppSpacing.verticalSpacerXs,
                Container(
                  height: 120,
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color:AppColors.textWhite,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
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
                        color: AppColors.speakingColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.speakingColor.withAlpha(40),
                        ),
                      ),
                    ],
                  )),
                ),
                AppSpacing.verticalSpacerMd,
              ],

              if (_recognizedText.isNotEmpty && _hasResult) ...[
                Text('認識: "$_recognizedText"',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                AppSpacing.verticalSpacerSm,
              ],

              // 録音ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? AppColors.error : AppColors.speakingColor,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                  ),
                  onPressed: _isListening ? _stopAndScore : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, color: AppColors.textWhite),
                  label: Text(
                    _isListening ? '録音停止' : (_hasResult ? 'もう一度挑戦 🔄' : '話す 🎤'),
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
                  ),
                ),
              ),
            ],
            AppSpacing.verticalSpacerXl,
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
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: dimmed ? AppColors.textMuted.shade100 : color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: dimmed ? AppColors.textMuted.shade300 : color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: dimmed ? AppColors.textMuted : color, fontWeight: FontWeight.bold)),
          AppSpacing.verticalSpacerXs,
          Text(
            dimmed ? '--' : '$score',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: dimmed ? AppColors.textMuted : color),
          ),
          Text('点', style: AppTypography.bodySmall.copyWith(color: dimmed ? AppColors.textMuted : color)),
        ],
      ),
    );
  }
}
