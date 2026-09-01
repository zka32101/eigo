import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../models/stage.dart';
import '../providers/level_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../widgets/xp_bar.dart';
import '../widgets/result_screen_components.dart';

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
                ImprovedResultHeader(
                  isPassed: isPassed,
                  isExcellent: isExcellent,
                  accuracy: accuracy,
                  score: score,
                  xpGained: xpGained,
                ),
                AppSpacing.verticalSpacerMd,
                // XPバー（レベル進捗）
                if (xpGained > 0) XpBar(level: level),
                AppSpacing.verticalSpacerMd,
                ImprovedSkillResultCards(
                  speakingAvg: speakingAvg,
                  listeningAccuracy: listeningAccuracy,
                  duration: duration,
                ),
                AppSpacing.verticalSpacerLg,
                ImprovedContentBreakdown(stage: stage),
                if (newBadges.isNotEmpty) ...[
                  AppSpacing.verticalSpacerLg,
                  ImprovedNewBadgesCard(badges: newBadges),
                ],
                AppSpacing.verticalSpacerXxl,
                _ActionButtons(stage: stage, isPassed: isPassed),
                AppSpacing.verticalSpacerXxl,
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

// Old component classes removed (now using ImprovedXxx components from result_screen_components.dart)

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
