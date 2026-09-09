import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../data/multiplayer_question_pool.dart';
import '../design_system/design_system.dart';
import '../models/question.dart';
import '../providers/coin_provider.dart';
import '../services/eigo_matchmaking_service.dart';

/// リアルタイム対戦（マルチプレイ）の対戦本編画面。
///
/// [matchId] から両プレイヤーで共通の問題セット（[MultiplayerQuestionPool]、
/// matchId をシードにして両者同じ問題順になる）を生成し、4択のリスニング・
/// リーディング問題に回答する。スコアは [watchMatchProvider] 経由で
/// リアルタイム同期される。
class MultiplayerQuizScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String userId;

  const MultiplayerQuizScreen({super.key, required this.matchId, required this.userId});

  @override
  ConsumerState<MultiplayerQuizScreen> createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends ConsumerState<MultiplayerQuizScreen> {
  late final List<Question> _questions;
  int _currentIndex = 0;
  int _myScore = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _completedLocally = false;
  bool _ratingUpdateTriggered = false;

  @override
  void initState() {
    super.initState();
    _questions = MultiplayerQuestionPool.draw(count: 10, seed: widget.matchId.hashCode);
  }

  Future<void> _answer(String choice) async {
    if (_answered || _questions.isEmpty) return;

    final question = _questions[_currentIndex];
    final isCorrect = choice == question.correctAnswer;

    setState(() {
      _selectedAnswer = choice;
      _answered = true;
      if (isCorrect) _myScore += 1;
    });

    final match = ref.read(watchMatchProvider(widget.matchId)).valueOrNull;
    final scores = Map<String, int>.from(match?.scores ?? {});
    scores[widget.userId] = _myScore;

    final isLastQuestion = _currentIndex >= _questions.length - 1;

    await ref.read(currentMatchProvider.notifier).updateMatchState(
          matchId: widget.matchId,
          scores: scores,
          shouldComplete: isLastQuestion,
        );

    if (isLastQuestion && match != null && !match.isFinished) {
      _completedLocally = true;
      await _maybeUpdateRating(match, myFinalScore: _myScore);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (isLastQuestion) {
        setState(() {}); // 結果表示（match ストリームの isFinished を待つ）
      } else {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      }
    });
  }

  /// 自分がマッチを完了状態にした場合のみ、レーティングを更新する
  /// （両者が同時に完了しても二重更新しないための簡易ガード）。
  Future<void> _maybeUpdateRating(MatchState match, {required int myFinalScore}) async {
    if (_ratingUpdateTriggered) return;
    _ratingUpdateTriggered = true;

    final opponentId = match.opponentOf(widget.userId);
    if (opponentId == null) return;

    final opponentScore = match.scoreFor(opponentId);
    final isDraw = myFinalScore == opponentScore;
    final winnerId = myFinalScore >= opponentScore ? widget.userId : opponentId;
    final loserId = winnerId == widget.userId ? opponentId : widget.userId;

    try {
      await EigoMatchmakingService().updateRatingAfterMatch(
        winnerId: winnerId,
        loserId: loserId,
        isDraw: isDraw,
      );
    } catch (_) {
      // レーティング更新に失敗してもゲーム体験は継続する
    }

    if (!isDraw && winnerId == widget.userId) {
      await ref.read(coinProvider.notifier).addCoins(30);
    } else if (isDraw) {
      await ref.read(coinProvider.notifier).addCoins(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(watchMatchProvider(widget.matchId));

    return matchAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(child: Text('エラーが発生しました: $err')),
      ),
      data: (match) {
        if (match == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('対戦')),
            body: const Center(child: Text('対戦が見つかりません')),
          );
        }
        return _buildScreen(context, match);
      },
    );
  }

  Widget _buildScreen(BuildContext context, MatchState match) {
    final opponentId = match.opponentOf(widget.userId);
    final myScore = match.scoreFor(widget.userId);
    final opponentScore = opponentId == null ? 0 : match.scoreFor(opponentId);
    final isFinished = match.isFinished || (_completedLocally && _answered);

    return Scaffold(
      appBar: AppBar(title: const Text('⚔️ 対戦クイズ'), elevation: 0),
      body: Column(
        children: [
          _buildScoreBoard(myScore: myScore, opponentScore: opponentScore),
          AppSpacing.verticalSpacerMd,
          Expanded(
            child: isFinished
                ? _buildResultView(context, myScore: myScore, opponentScore: opponentScore)
                : _buildQuizView(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard({required int myScore, required int opponentScore}) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreCard(label: 'あなた', score: myScore, background: Colors.white),
          Column(
            children: [
              const Text('VS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpacerSm,
              Text(
                '$myScore - $opponentScore',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          _buildScoreCard(label: '相手', score: opponentScore, background: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildScoreCard({required String label, required int score, required Color background}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          AppSpacing.verticalSpacerSm,
          Text('$score/${_questions.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    if (_questions.isEmpty) {
      return const Center(child: Text('問題が見つかりません'));
    }

    final question = _questions[_currentIndex];

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '問題 ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
          AppSpacing.verticalSpacerSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 4,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          AppSpacing.verticalSpacerLg,
          if (question.imageEmoji != null)
            Center(child: Text(question.imageEmoji!, style: const TextStyle(fontSize: 48))),
          AppSpacing.verticalSpacerMd,
          Text(
            question.text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (question.phonetic != null) ...[
            AppSpacing.verticalSpacerSm,
            Text(
              question.phonetic!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
          AppSpacing.verticalSpacerLg,
          Text(question.textJa, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          AppSpacing.verticalSpacerMd,
          ...question.choices.map((choice) => _buildChoice(question, choice)),
        ],
      ),
    );
  }

  Widget _buildChoice(Question question, String choice) {
    final isSelected = _selectedAnswer == choice;
    final isCorrect = choice == question.correctAnswer;
    final showResult = _answered;

    Color background = Colors.white;
    Color border = Colors.grey.shade300;

    if (showResult) {
      if (isCorrect) {
        background = Colors.green.shade100;
        border = Colors.green;
      } else if (isSelected) {
        background = Colors.red.shade100;
        border = Colors.red;
      }
    } else if (isSelected) {
      background = AppColors.primary.withOpacity(0.1);
      border = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _answered ? null : () => _answer(choice),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(child: Text(choice, style: const TextStyle(fontSize: 16))),
              if (showResult && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
              if (showResult && isSelected && !isCorrect) const Icon(Icons.close, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, {required int myScore, required int opponentScore}) {
    final isWin = myScore > opponentScore;
    final isDraw = myScore == opponentScore;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isDraw ? '🤝 引き分け' : (isWin ? '🎉 勝利！' : '🏁 終了'),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isDraw ? Colors.orange : (isWin ? Colors.green : Colors.orange),
            ),
          ),
          AppSpacing.verticalSpacerLg,
          Text('$myScore - $opponentScore', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          AppSpacing.verticalSpacerXl,
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('対戦相手を探す画面に戻る'),
          ),
        ],
      ),
    );
  }
}
