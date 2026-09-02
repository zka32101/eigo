import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/conversation_data.dart';
import '../providers/coin_provider.dart';
import '../providers/level_provider.dart';
import '../providers/progress_provider.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  ConversationScript? _selectedScript;
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    if (_selectedScript == null) {
      return _SelectionScreen(
        onSelect: (s) => setState(() { _selectedScript = s; _started = false; }),
      );
    }
    if (!_started) {
      return _IntroScreen(
        script: _selectedScript!,
        onStart: () => setState(() => _started = true),
        onBack: () => setState(() => _selectedScript = null),
      );
    }
    return _ConversationPlayScreen(
      script: _selectedScript!,
      onComplete: () => setState(() { _selectedScript = null; _started = false; }),
    );
  }
}

// ─── 選択画面 ──────────────────────────────────────────────────────────────

class _SelectionScreen extends StatelessWidget {
  final ValueChanged<ConversationScript> onSelect;
  const _SelectionScreen({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('💬 会話シミュレーション'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: AppSpacing.allPaddingMd,
        itemCount: 4 + allConversations.length,
        itemBuilder: (context, index) {
          // Static items (header, spacers, description)
          if (index == 0) {
            return Text('シナリオを選ぼう！',
              style: AppTypography.headlineSmall.copyWith(color: kTextDark));
          }
          if (index == 1) {
            return AppSpacing.verticalSpacerXs;
          }
          if (index == 2) {
            return Text('AIキャラクターと英語で会話練習しよう',
              style: AppTypography.bodySmall.copyWith(color: kTextMuted));
          }
          if (index == 3) {
            return AppSpacing.verticalSpacerSm;
          }

          // Dynamic conversation cards (index 4+)
          final conversationIndex = index - 4;
          final script = allConversations[conversationIndex];
          return _ScriptCard(script: script, onTap: () => onSelect(script));
        },
      ),
    );
  }
}

class _ScriptCard extends StatelessWidget {
  final ConversationScript script;
  final VoidCallback onTap;
  const _ScriptCard({required this.script, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            children: [
              Text(script.emoji, style: AppTypography.headlineSmall.copyWith(fontSize: 40)),
              AppSpacing.horizontalSpacerSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(script.titleJa,
                      style: AppTypography.labelLarge.copyWith(color: kTextDark)),
                    AppSpacing.verticalSpacerXs,
                    Text(script.title, style: AppTypography.bodySmall.copyWith(color: kPrimaryColor)),
                    AppSpacing.verticalSpacerXs,
                    Text(script.situation, style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: kTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── イントロ画面 ───────────────────────────────────────────────────────────

class _IntroScreen extends StatelessWidget {
  final ConversationScript script;
  final VoidCallback onStart;
  final VoidCallback onBack;
  const _IntroScreen({required this.script, required this.onStart, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text(script.titleJa),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: onBack),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(script.emoji, style: AppTypography.headlineLarge),
              AppSpacing.verticalSpacerSm,
              Text(script.titleJa,
                style: AppTypography.headlineMedium.copyWith(color: kTextDark)),
              AppSpacing.verticalSpacerXs,
              Container(
                padding: AppSpacing.allPaddingMd,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                ),
                child: Text(script.situation,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: kPrimaryDark)),
              ),
              AppSpacing.verticalSpacerXs,
              Text('全${script.turns.length}ターン', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
              AppSpacing.verticalSpacerXxl,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
                ),
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text('スタート！',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 会話プレイ画面 ─────────────────────────────────────────────────────────

class _ConversationPlayScreen extends ConsumerStatefulWidget {
  final ConversationScript script;
  final VoidCallback onComplete;
  const _ConversationPlayScreen({required this.script, required this.onComplete});

  @override
  ConsumerState<_ConversationPlayScreen> createState() => _ConversationPlayScreenState();
}

class _ConversationPlayScreenState extends ConsumerState<_ConversationPlayScreen> {
  final _tts = TtsService();
  final _speech = SpeechService();
  final _scrollController = ScrollController();
  late ConfettiController _confetti;

  int _turnIndex = 0;
  bool _isAiSpeaking = false;
  bool _isListening = false;
  bool _isCompleted = false;
  String _recognizedText = '';
  final List<_ChatBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _speech.init();
    _processNextTurn();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    _speech.stopListening();
    _scrollController.dispose();
    super.dispose();
  }

  ConversationTurn get _currentTurn => widget.script.turns[_turnIndex];

  Future<void> _processNextTurn() async {
    if (_turnIndex >= widget.script.turns.length) {
      _complete();
      return;
    }
    final turn = _currentTurn;
    if (turn.speaker == 'ai') {
      setState(() { _isAiSpeaking = true; });
      _addBubble(isAi: true, text: turn.text, textJa: turn.textJa);
      await _tts.speak(turn.text);
      setState(() { _isAiSpeaking = false; });
      _turnIndex++;
      await Future.delayed(const Duration(milliseconds: 500));
      _processNextTurn();
    }
    // user ターンは自動では進めない（ボタン押下待ち）
    setState(() {});
  }

  void _addBubble({required bool isAi, required String text, required String textJa, String? userInput}) {
    setState(() {
      _bubbles.add(_ChatBubble(isAi: isAi, text: text, textJa: textJa, userInput: userInput));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startListening() async {
    setState(() { _isListening = true; _recognizedText = ''; });
    await _speech.startListening(
      onResult: (text, isFinal) {
        setState(() { _recognizedText = text; });
        if (isFinal) _stopAndSubmit();
      },
    );
  }

  Future<void> _stopAndSubmit() async {
    await _speech.stopListening();
    setState(() { _isListening = false; });
    // ユーザー発言をバブルに追加
    _addBubble(isAi: false, text: _currentTurn.text, textJa: _currentTurn.textJa, userInput: _recognizedText);
    _turnIndex++;
    await Future.delayed(const Duration(milliseconds: 600));
    _processNextTurn();
  }

  void _skipUserTurn() {
    _addBubble(isAi: false, text: _currentTurn.text, textJa: _currentTurn.textJa, userInput: _currentTurn.hint ?? _currentTurn.text);
    _turnIndex++;
    Future.delayed(const Duration(milliseconds: 400), _processNextTurn);
  }

  Future<void> _complete() async {
    setState(() { _isCompleted = true; });
    _confetti.play();
    ref.read(coinProvider.notifier).addCoins(20);
    await ref.read(levelProvider.notifier).addXp(40);
  }

  @override
  Widget build(BuildContext context) {
    final isUserTurn = !_isCompleted &&
        _turnIndex < widget.script.turns.length &&
        _currentTurn.speaker == 'user';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text('${widget.script.emoji} ${widget.script.titleJa}'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 進捗インジケーター
              LinearProgressIndicator(
                value: _turnIndex / widget.script.turns.length,
                backgroundColor: Colors.white,
                color: kPrimaryColor,
                minHeight: 4,
              ),

              // チャット表示エリア
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: AppSpacing.allPaddingMd,
                  itemCount: _bubbles.length + (_isAiSpeaking ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _bubbles.length) {
                      // AI 入力中インジケーター
                      return _TypingBubble();
                    }
                    return _bubbles[i];
                  },
                ),
              ),

              // ユーザー入力エリア
              if (_isCompleted)
                _buildCompletedBar()
              else if (isUserTurn)
                _buildUserInputBar()
              else
                AppSpacing.verticalSpacerXs,
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              colors: const [kPrimaryColor, Colors.yellow, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInputBar() {
    final turn = _currentTurn;
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🎙️ あなたの番！', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: kSpeakingColor)),
              const Spacer(),
              if (turn.hint != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: Text('ヒント: ${turn.hint}',
                    style: AppTypography.bodySmall.copyWith(color: kPrimaryColor, fontSize: 11)),
                ),
            ],
          ),
          AppSpacing.verticalSpacerXs,
          Text(turn.textJa, style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
          if (_recognizedText.isNotEmpty) ...[
            AppSpacing.verticalSpacerXs,
            Text('"$_recognizedText"', style: AppTypography.bodySmall.copyWith(color: kTextDark, fontStyle: FontStyle.italic)),
          ],
          AppSpacing.verticalSpacerXs,
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? kAccentRed : kSpeakingColor,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                  ),
                  onPressed: _isListening ? _stopAndSubmit : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 18),
                  label: Text(_isListening ? '停止' : '話す',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              AppSpacing.horizontalSpacerXs,
              TextButton(
                onPressed: _skipUserTurn,
                child: Text('スキップ', style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          Text('🎉 会話完了！ +20コイン', style: AppTypography.labelLarge.copyWith(color: kAccentGreen)),
          AppSpacing.verticalSpacerXs,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
            ),
            onPressed: widget.onComplete,
            child: Text('シナリオ選択に戻る', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── チャットバブル ─────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final bool isAi;
  final String text;
  final String textJa;
  final String? userInput;
  const _ChatBubble({required this.isAi, required this.text, required this.textJa, this.userInput});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            CircleAvatar(backgroundColor: kPrimaryColor, radius: 18, child: const Text('🤖', style: TextStyle(fontSize: 16))),
            AppSpacing.horizontalSpacerXs,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.white : kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.borderRadiusLarge),
                      topRight: Radius.circular(AppSizes.borderRadiusLarge),
                      bottomLeft: Radius.circular(isAi ? 4 : AppSizes.borderRadiusLarge),
                      bottomRight: Radius.circular(isAi ? AppSizes.borderRadiusLarge : 4),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAi ? text : (userInput ?? text),
                        style: AppTypography.bodySmall.copyWith(
                          color: isAi ? kTextDark : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        textJa,
                        style: AppTypography.bodySmall.copyWith(
                          color: isAi ? kTextMuted : Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isAi) ...[
            AppSpacing.horizontalSpacerXs,
            CircleAvatar(backgroundColor: kSpeakingColor, radius: 18, child: const Text('😊', style: TextStyle(fontSize: 16))),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: kPrimaryColor, radius: 18, child: const Text('🤖', style: TextStyle(fontSize: 16))),
          AppSpacing.horizontalSpacerXs,
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: const Text('…', style: TextStyle(fontSize: 18, color: kTextMuted, letterSpacing: 4)),
          ),
        ],
      ),
    );
  }
}
