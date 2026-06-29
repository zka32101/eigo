import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../models/stage.dart';
import '../providers/level_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/xp_bar.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;
  const ResultScreen({super.key, required this.args});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confetti;
  bool _showLevelUp = false;
  int _levelUpTo = 0;

  Stage get stage => widget.args['stage'] as Stage;
  int get score => widget.args['score'] as int;
  int get correct => widget.args['correct'] as int;
  int get total => widget.args['total'] as int;
  int get speakingAvg => widget.args['speakingAvg'] as int;
  int get listeningAccuracy => widget.args['listeningAccuracy'] as int;
  Duration get duration => widget.args['duration'] as Duration;
  List<BadgeModel> get newBadges => (widget.args['newBadges'] as List<dynamic>? ?? []).cast<BadgeModel>();
  int get xpGained => widget.args['xpGained'] as int? ?? 0;

  double get accuracy => correct / total;
  bool get isPassed => accuracy >= 0.6;
  bool get isExcellent => accuracy >= 0.9;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (isPassed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _confetti.play();
      });
    }
    // レベルアップ通知を少し遅れて確認
    Future.delayed(const Duration(milliseconds: 800), _checkLevelUp);
  }

  void _checkLevelUp() {
    if (!mounted) return;
    final newLevel = ref.read(levelUpNotifier);
    if (newLevel != null) {
      final level = ref.read(levelProvider);
      setState(() {
        _showLevelUp = true;
        _levelUpTo = newLevel;
      });
      ref.read(levelUpNotifier.notifier).clear();
      // レベルアップ時にもコンフェッティ
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(levelProvider);

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: Text('${stage.emoji} ${stage.titleJa} - 結果'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ResultHeader(
                  isPassed: isPassed,
                  isExcellent: isExcellent,
                  accuracy: accuracy,
                  score: score,
                  xpGained: xpGained,
                ),
                const SizedBox(height: 12),
                // XPバー（レベル進捗）
                if (xpGained > 0) XpBar(level: level),
                const SizedBox(height: 12),
                _SkillResultCards(
                  speakingAvg: speakingAvg,
                  listeningAccuracy: listeningAccuracy,
                  duration: duration,
                ),
                const SizedBox(height: 16),
                _ContentPieChart(stage: stage),
                if (newBadges.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _NewBadgesCard(badges: newBadges),
                ],
                const SizedBox(height: 24),
                _ActionButtons(stage: stage, isPassed: isPassed),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // コンフェッティ
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [kPrimaryColor, kAccentGreen, kSpeakingColor, kAccentOrange],
            ),
          ),
          // レベルアップオーバーレイ
          if (_showLevelUp)
            LevelUpOverlay(
              newLevel: _levelUpTo,
              rankEmoji: level.rankEmoji,
              rank: level.rank,
              onDismiss: () => setState(() => _showLevelUp = false),
            ),
        ],
      ),
    );
  }
}

// ─── Result Header ──────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  final bool isPassed;
  final bool isExcellent;
  final double accuracy;
  final int score;
  final int xpGained;
  const _ResultHeader({
    required this.isPassed,
    required this.isExcellent,
    required this.accuracy,
    required this.score,
    this.xpGained = 0,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = isExcellent ? '🏆' : isPassed ? '⭐' : '💪';
    final message = isExcellent ? 'すばらしい！パーフェクトに近い！' : isPassed ? 'クリア！よくできました！' : 'もう少し！もう一度挑戦しよう！';
    final color = isPassed ? kAccentGreen : kAccentOrange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResultStat('スコア', '$score点', kPrimaryColor),
                _ResultStat('正解率', '${(accuracy * 100).round()}%', color),
                if (xpGained > 0)
                  _ResultStat('XP獲得', '+$xpGained', const Color(0xFFFFD700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14, color: kTextMuted)),
      ],
    );
  }
}

// ─── Skill Result Cards ─────────────────────────────────────────

class _SkillResultCards extends StatelessWidget {
  final int speakingAvg;
  final int listeningAccuracy;
  final Duration duration;
  const _SkillResultCards({
    required this.speakingAvg,
    required this.listeningAccuracy,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return Row(
      children: [
        Expanded(child: _SkillResultCard(icon: '👂', label: 'リスニング', value: '$listeningAccuracy%', color: kListeningColor)),
        const SizedBox(width: 8),
        Expanded(child: _SkillResultCard(icon: '🎤', label: 'スピーキング', value: '$speakingAvg点', color: kSpeakingColor)),
        const SizedBox(width: 8),
        Expanded(child: _SkillResultCard(icon: '⏱️', label: '時間', value: '$mins:${secs.toString().padLeft(2, '0')}', color: kAccentOrange)),
      ],
    );
  }
}

class _SkillResultCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _SkillResultCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ],
        ),
      ),
    );
  }
}

// ─── Content Pie Chart ──────────────────────────────────────────

class _ContentPieChart extends StatelessWidget {
  final Stage stage;
  const _ContentPieChart({required this.stage});

  @override
  Widget build(BuildContext context) {
    final total = stage.questions.length;
    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('このレッスンの内容', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          if (stage.listeningCount > 0)
                            PieChartSectionData(
                              value: stage.listeningCount.toDouble(),
                              color: kListeningColor,
                              title: '${(stage.listeningCount / total * 100).round()}%',
                              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              radius: 60,
                            ),
                          if (stage.speakingCount > 0)
                            PieChartSectionData(
                              value: stage.speakingCount.toDouble(),
                              color: kSpeakingColor,
                              title: '${(stage.speakingCount / total * 100).round()}%',
                              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              radius: 60,
                            ),
                          if (stage.readingCount > 0)
                            PieChartSectionData(
                              value: stage.readingCount.toDouble(),
                              color: kReadingColor,
                              title: '${(stage.readingCount / total * 100).round()}%',
                              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              radius: 60,
                            ),
                          if (stage.writingCount > 0)
                            PieChartSectionData(
                              value: stage.writingCount.toDouble(),
                              color: kWritingColor,
                              title: '${(stage.writingCount / total * 100).round()}%',
                              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              radius: 60,
                            ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Legend('👂 Listening', kListeningColor, stage.listeningCount),
                      _Legend('🎤 Speaking', kSpeakingColor, stage.speakingCount),
                      _Legend('📖 Reading', kReadingColor, stage.readingCount),
                      _Legend('✏️ Writing', kWritingColor, stage.writingCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _Legend(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: $count問', style: const TextStyle(fontSize: 12, color: kTextDark)),
        ],
      ),
    );
  }
}

// ─── New Badges Card ────────────────────────────────────────────

class _NewBadgesCard extends StatelessWidget {
  final List<BadgeModel> badges;
  const _NewBadgesCard({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF9E6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎉 新しいバッジ獲得！',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAccentOrange)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: badges.map((b) => Column(
                children: [
                  Text(b.emoji, style: const TextStyle(fontSize: 40)),
                  Text(b.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 80,
                    child: Text(b.description,
                        style: const TextStyle(fontSize: 10, color: kTextMuted),
                        textAlign: TextAlign.center),
                  ),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Buttons ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final Stage stage;
  final bool isPassed;
  const _ActionButtons({required this.stage, required this.isPassed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.style),
            label: const Text('単語カードで復習する'),
            onPressed: () => Navigator.of(context).pushNamed('/word-review', arguments: stage),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: kAccentGreen,
              side: const BorderSide(color: kAccentGreen),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('ステージ一覧へ'),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('もう一度'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/lesson', arguments: stage);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: kPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.mic),
            label: const Text('🎤 発音チェック'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/pronunciation-check', arguments: stage);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
    );
  }
}
