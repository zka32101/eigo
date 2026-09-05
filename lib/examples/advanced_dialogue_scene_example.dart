import 'package:flutter/material.dart';
import 'package:eigo/widgets/animated_npc_character_widget.dart';
import 'package:eigo/widgets/animated_dialogue_box_widget.dart';
import 'package:eigo/widgets/dialogue_choice_button_widget.dart';
import 'package:eigo/widgets/npc_status_indicator_widget.dart';
import 'package:eigo/widgets/affection_change_indicator_widget.dart';
import 'package:eigo/widgets/screen_transition_widget.dart';
import 'package:eigo/services/npc_animation_service.dart';

/// 高度な対話シーンの実装例
/// リアルなゲーム内の対話シーンをシミュレートする複合ウィジェット統合
class AdvancedDialogueSceneExample extends StatefulWidget {
  const AdvancedDialogueSceneExample({Key? key}) : super(key: key);

  @override
  State<AdvancedDialogueSceneExample> createState() =>
      _AdvancedDialogueSceneExampleState();
}

class _AdvancedDialogueSceneExampleState
    extends State<AdvancedDialogueSceneExample> {
  late SceneController _sceneController;

  @override
  void initState() {
    super.initState();
    _sceneController = SceneController();
    _sceneController.startScene();
  }

  @override
  void dispose() {
    _sceneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高度な対話シーンの例'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: AnimatedBuilder(
        animation: _sceneController,
        builder: (context, child) {
          return Stack(
            children: [
              // 背景（ゲームシーン）
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade100,
                      Colors.green.shade100,
                    ],
                  ),
                ),
              ),

              // シーンコンテンツ
              ScreenTransitionWidget(
                isEntering: true,
                transitionType: TransitionType.fadeSlide,
                child: Column(
                  children: [
                    // NPCキャラクター表示（上部）
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AnimatedNPCCharacterWidget(
                          npcId: _sceneController.currentNpcId,
                          npcName: _sceneController.currentNpcName,
                          emotion: _sceneController.currentEmotion,
                          isAnimating: true,
                        ),
                      ),
                    ),

                    // ステータス表示（中部）
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: NPCStatusIndicatorWidget(
                        npcName: _sceneController.currentNpcName,
                        affection: _sceneController.affectionLevel,
                        affectionProgress:
                            _sceneController.affectionLevel / 100.0,
                        mood: _sceneController.moodText,
                        level: _sceneController.npcLevel,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 対話ボックス（下部）
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedDialogueBoxWidget(
                          npcName: _sceneController.currentNpcName,
                          dialogueText: _sceneController.currentDialogue,
                          emoticon: _sceneController.emoticon,
                          autoPlay: true,
                          onComplete: () {
                            // ダイアログ完了後、選択肢を表示
                            setState(() {
                              _sceneController.showChoices = true;
                            });
                          },
                        ),
                      ),
                    ),

                    // 選択肢（最下部）
                    if (_sceneController.showChoices)
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                for (int i = 0;
                                    i <
                                        _sceneController.currentChoices.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: DialogueChoiceButtonWidget(
                                        choiceText: _sceneController
                                            .currentChoices[i],
                                        choiceIndex: i,
                                        delay: Duration(
                                            milliseconds: i * 100),
                                        onSelected: () {
                                          _sceneController
                                              .selectChoice(i);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 親密度変化表示
              if (_sceneController.showAffectionChange)
                Positioned(
                  right: 50,
                  top: 100,
                  child: AffectionChangeIndicatorWidget(
                    affectionChange: _sceneController.lastAffectionChange,
                    npcName: _sceneController.currentNpcName,
                    position: const Offset(100, 150),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// シーンコントローラー：対話シーンの状態管理
class SceneController extends ChangeNotifier {
  // シーン状態
  String currentNpcId = 'aria_001';
  String currentNpcName = 'Aria';
  String emoticon = '✨';
  String currentDialogue = 'こんにちは！';
  NPCAnimationService.EmotionType currentEmotion =
      NPCAnimationService.EmotionType.happy;
  int affectionLevel = 50;
  int npcLevel = 5;
  bool showChoices = false;
  bool showAffectionChange = false;
  int lastAffectionChange = 0;

  List<String> currentChoices = [];

  // シーンデータ
  final List<DialogueNode> _dialogueNodes = [
    DialogueNode(
      id: 'greeting',
      npc: ('aria_001', 'Aria', '✨'),
      emotion: NPCAnimationService.EmotionType.happy,
      text: 'こんにちは！久しぶりだね。',
      choices: ['久しぶり！', '何か手伝えることは？'],
      affectionChanges: [5, 10],
    ),
    DialogueNode(
      id: 'quest_offer',
      npc: ('aria_001', 'Aria', '✨'),
      emotion: NPCAnimationService.EmotionType.excited,
      text: '実は、助けてほしいことがあるんだ。',
      choices: ['何か手伝おうか？', 'ごめん、今は時間がない'],
      affectionChanges: [15, -5],
    ),
    DialogueNode(
      id: 'quest_detail',
      npc: ('aria_001', 'Aria', '✨'),
      emotion: NPCAnimationService.EmotionType.thinking,
      text: 'この森の奥に、魔法の水晶があるんだ。それを取ってきてくれないかな？',
      choices: ['了解した', 'それは危ない'],
      affectionChanges: [20, 0],
    ),
    DialogueNode(
      id: 'quest_accepted',
      npc: ('aria_001', 'Aria', '✨'),
      emotion: NPCAnimationService.EmotionType.happy,
      text: 'ありがとう！君のことは本当に信頼している。',
      choices: ['頑張ってくるね', '報酬は？'],
      affectionChanges: [25, 5],
    ),
    DialogueNode(
      id: 'farewell',
      npc: ('aria_001', 'Aria', '✨'),
      emotion: NPCAnimationService.EmotionType.happy,
      text: 'また会おう！無事を祈ってる。',
      choices: [],
      affectionChanges: [],
    ),
  ];

  int _currentNodeIndex = 0;

  void startScene() {
    _loadNode(_dialogueNodes[_currentNodeIndex]);
  }

  void _loadNode(DialogueNode node) {
    currentNpcId = node.npc.$1;
    currentNpcName = node.npc.$2;
    emoticon = node.npc.$3;
    currentDialogue = node.text;
    currentEmotion = node.emotion;
    currentChoices = node.choices;
    showChoices = false;
    notifyListeners();
  }

  void selectChoice(int choiceIndex) {
    // 親密度の変更を反映
    lastAffectionChange =
        _dialogueNodes[_currentNodeIndex].affectionChanges[choiceIndex];
    affectionLevel = (affectionLevel + lastAffectionChange).clamp(0, 100);
    showAffectionChange = true;

    // 次のノードに進む
    if (_currentNodeIndex < _dialogueNodes.length - 1) {
      _currentNodeIndex++;
      Future.delayed(const Duration(milliseconds: 500), () {
        showAffectionChange = false;
        _loadNode(_dialogueNodes[_currentNodeIndex]);
      });
    }
  }

  String get moodText {
    if (affectionLevel >= 80) return 'very_happy';
    if (affectionLevel >= 60) return 'happy';
    if (affectionLevel >= 40) return 'neutral';
    if (affectionLevel >= 20) return 'sad';
    return 'angry';
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// 対話ノード：シーンの構造を定義
class DialogueNode {
  final String id;
  final (String, String, String) npc; // (id, name, emoticon)
  final NPCAnimationService.EmotionType emotion;
  final String text;
  final List<String> choices;
  final List<int> affectionChanges;

  DialogueNode({
    required this.id,
    required this.npc,
    required this.emotion,
    required this.text,
    required this.choices,
    required this.affectionChanges,
  });
}
