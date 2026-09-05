import 'package:flutter/material.dart';
import 'package:eigo/widgets/animated_dialogue_box_widget.dart';
import 'package:eigo/widgets/animated_button_widget.dart';
import 'package:eigo/widgets/animated_npc_character_widget.dart';
import 'package:eigo/widgets/npc_status_indicator_widget.dart';
import 'package:eigo/widgets/screen_transition_widget.dart';
import 'package:eigo/widgets/dialogue_choice_button_widget.dart';
import 'package:eigo/widgets/affection_change_indicator_widget.dart';
import 'package:eigo/services/npc_animation_service.dart';

/// アニメーション付きUI統合例
/// Phase 16 Part 15で実装したすべてのUIウィジェットの使用例
class AnimatedUIExample extends StatefulWidget {
  const AnimatedUIExample({Key? key}) : super(key: key);

  @override
  State<AnimatedUIExample> createState() => _AnimatedUIExampleState();
}

class _AnimatedUIExampleState extends State<AnimatedUIExample> {
  int _currentStep = 0;
  int _selectedChoice = -1;
  int _affectionLevel = 50;
  NPCAnimationService.EmotionType _npcEmotion =
      NPCAnimationService.EmotionType.happy;

  final List<String> _dialogueSteps = [
    'こんにちは！私はAriaです。',
    'あなたに会えてとても嬉しいです。',
    'ここで何ができるのか説明しましょう。',
  ];

  final List<String> _choices = [
    'スキルを学びたい',
    'クエストを受け入れたい',
    'ただ話がしたい',
    'さようなら',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アニメーション付きUI統合例'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ステップインジケーター
              _buildStepIndicator(),
              const SizedBox(height: 24),

              // 現在のステップに応じたUIを表示
              if (_currentStep == 0) _buildCharacterDisplay(),
              if (_currentStep == 1) _buildDialogueDisplay(),
              if (_currentStep == 2) _buildChoiceDisplay(),
              if (_currentStep == 3) _buildStatusDisplay(),
              if (_currentStep == 4) _buildNavigationExample(),

              const SizedBox(height: 24),

              // ナビゲーションボタン
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// ステップインジケーター
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 5; i++)
            _buildStepBadge(i, i == _currentStep),
        ],
      ),
    );
  }

  Widget _buildStepBadge(int index, bool isActive) {
    final labels = [
      'キャラ',
      'ダイアログ',
      '選択肢',
      'ステータス',
      'トランジション',
    ];

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Tooltip(
          message: labels[index],
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// キャラクター表示
  Widget _buildCharacterDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステップ 1: NPCキャラクター表示',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Center(
          child: AnimatedNPCCharacterWidget(
            npcId: 'aria_001',
            npcName: 'Aria',
            emoticon: '✨',
            emotion: _npcEmotion,
          ),
        ),
        const SizedBox(height: 16),
        // 感情変更ボタン
        _buildEmotionButtons(),
      ],
    );
  }

  Widget _buildEmotionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final emotion in NPCAnimationService.EmotionType.values)
          AnimatedButtonWidget(
            label: emotion.toString().split('.').last,
            onPressed: () {
              setState(() => _npcEmotion = emotion);
            },
            width: 80,
            height: 40,
          ),
      ],
    );
  }

  /// ダイアログ表示
  Widget _buildDialogueDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステップ 2: アニメーション付きダイアログ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Center(
          child: AnimatedDialogueBoxWidget(
            npcName: 'Aria',
            dialogueText: _dialogueSteps[_currentStep % _dialogueSteps.length],
            emoticon: '✨',
            autoPlay: true,
            onComplete: () {
              // ダイアログアニメーション完了時の処理
            },
          ),
        ),
      ],
    );
  }

  /// 選択肢表示
  Widget _buildChoiceDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステップ 3: ダイアログ選択肢',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              for (int i = 0; i < _choices.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 300,
                    child: DialogueChoiceButtonWidget(
                      choiceText: _choices[i],
                      choiceIndex: i,
                      delay: Duration(milliseconds: i * 100),
                      onSelected: () {
                        setState(() {
                          _selectedChoice = i;
                          // 選択に応じて親密度を変更
                          if (i == 0) {
                            _affectionLevel = (_affectionLevel + 10).clamp(0, 100);
                          } else if (i == 3) {
                            _affectionLevel = (_affectionLevel - 5).clamp(0, 100);
                          }
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_selectedChoice >= 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                '選択: ${_choices[_selectedChoice]}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  /// ステータス表示
  Widget _buildStatusDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステップ 4: NPCステータス表示',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              NPCStatusIndicatorWidget(
                npcName: 'Aria',
                affection: _affectionLevel,
                affectionProgress: _affectionLevel / 100.0,
                mood: _getMoodFromEmotion(_npcEmotion),
                level: 5,
              ),
              const SizedBox(height: 16),
              // 親密度変更ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedButtonWidget(
                    label: '親密度 -10',
                    onPressed: () {
                      setState(() {
                        _affectionLevel = (_affectionLevel - 10).clamp(0, 100);
                      });
                    },
                    width: 120,
                  ),
                  const SizedBox(width: 16),
                  AnimatedButtonWidget(
                    label: '親密度 +10',
                    onPressed: () {
                      setState(() {
                        _affectionLevel = (_affectionLevel + 10).clamp(0, 100);
                      });
                    },
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// トランジション例
  Widget _buildNavigationExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステップ 5: スクリーントランジション',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ScreenTransitionWidget(
          isEntering: true,
          transitionType: TransitionType.fadeSlide,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'トランジションアニメーション',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'このコンテンツはフェード＋スライドアニメーションで表示されています。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ナビゲーションボタン
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedButtonWidget(
          label: '← 前へ',
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
                _selectedChoice = -1;
              });
            }
          },
          enabled: _currentStep > 0,
          width: 100,
        ),
        Text(
          'ステップ ${_currentStep + 1} / 5',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AnimatedButtonWidget(
          label: '次へ →',
          onPressed: () {
            if (_currentStep < 4) {
              setState(() {
                _currentStep++;
                _selectedChoice = -1;
              });
            }
          },
          enabled: _currentStep < 4,
          width: 100,
        ),
      ],
    );
  }

  String _getMoodFromEmotion(NPCAnimationService.EmotionType emotion) {
    switch (emotion) {
      case NPCAnimationService.EmotionType.happy:
      case NPCAnimationService.EmotionType.excited:
        return 'happy';
      case NPCAnimationService.EmotionType.sad:
        return 'sad';
      case NPCAnimationService.EmotionType.angry:
        return 'angry';
      case NPCAnimationService.EmotionType.surprised:
        return 'surprised';
      case NPCAnimationService.EmotionType.confused:
        return 'confused';
      case NPCAnimationService.EmotionType.thinking:
        return 'thinking';
      default:
        return 'neutral';
    }
  }
}
