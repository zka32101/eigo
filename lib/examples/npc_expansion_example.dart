import 'package:flutter/material.dart';
import 'package:eigo/models/npc_registry.dart';
import 'package:eigo/data/dialogue_trees.dart';
import 'package:eigo/widgets/animated_npc_character_widget.dart';
import 'package:eigo/widgets/animated_dialogue_box_widget.dart';
import 'package:eigo/widgets/dialogue_choice_button_widget.dart';
import 'package:eigo/widgets/npc_status_indicator_widget.dart';
import 'package:eigo/services/npc_animation_service.dart';

/// NPC拡張システムの実装例
/// 10個のNPCを展示し、それぞれの対話ツリーとクエストシステムを示す
class NPCExpansionExample extends StatefulWidget {
  const NPCExpansionExample({Key? key}) : super(key: key);

  @override
  State<NPCExpansionExample> createState() => _NPCExpansionExampleState();
}

class _NPCExpansionExampleState extends State<NPCExpansionExample> {
  late NPCRegistry _npcRegistry;
  late DialogueTrees _dialogueTrees;

  String _selectedNpcId = 'aria_001';
  String _currentNodeId = 'greeting';
  int _currentAffection = 50;

  @override
  void initState() {
    super.initState();
    _npcRegistry = NPCRegistry.getInstance();
    _dialogueTrees = DialogueTrees.getInstance();

    // システムを初期化
    _npcRegistry.initializeAllNPCs();
    _dialogueTrees.initializeAllTrees();

    // 初期NPCの親密度を設定
    final npc = _npcRegistry.getNPC(_selectedNpcId);
    if (npc != null) {
      _currentAffection = npc.baseAffection;
    }
  }

  void _selectNPC(String npcId) {
    setState(() {
      _selectedNpcId = npcId;
      _currentNodeId = 'greeting';
      final npc = _npcRegistry.getNPC(npcId);
      if (npc != null) {
        _currentAffection = npc.baseAffection;
      }
    });
  }

  void _selectChoice(int choiceIndex) {
    final dialogueTree = _dialogueTrees.getDialogueTree(_selectedNpcId);
    final currentNode = dialogueTree?.nodes[_currentNodeId];

    if (currentNode != null && choiceIndex < currentNode.choices.length) {
      final choice = currentNode.choices[choiceIndex];

      setState(() {
        _currentAffection =
            (_currentAffection + choice.affectionChange).clamp(0, 100);
        _currentNodeId = choice.nextNodeId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPC拡張システムデモ'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Row(
        children: [
          // 左：NPCリスト
          _buildNPCList(),

          // 右：対話シーン
          Expanded(
            flex: 2,
            child: _buildDialogueScene(),
          ),
        ],
      ),
    );
  }

  /// NPCリストウィジェット
  Widget _buildNPCList() {
    final npcs = _npcRegistry.getAllNPCs();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.amber.shade200),
              ),
            ),
            child: Text(
              'NPCキャラクター',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: npcs.length,
              itemBuilder: (context, index) {
                final npc = npcs[index];
                final isSelected = npc.id == _selectedNpcId;

                return Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.amber.shade100 : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      npc.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.amber.shade900 : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      npc.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Text(
                      npc.emoticon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () => _selectNPC(npc.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 対話シーンウィジェット
  Widget _buildDialogueScene() {
    final npc = _npcRegistry.getNPC(_selectedNpcId);
    final dialogueTree = _dialogueTrees.getDialogueTree(_selectedNpcId);
    final currentNode = dialogueTree?.nodes[_currentNodeId];

    if (npc == null || currentNode == null) {
      return const Center(child: Text('NPC情報が見つかりません'));
    }

    // NPCの感情を決定
    final emotion = _getEmotionFromAffection(_currentAffection);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // NPC情報ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      npc.getDisplayName(),
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '地域: ${npc.region}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lv. ${npc.level}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Affection: $_currentAffection/100',
                      style: TextStyle(
                        color: _getAffectionColor(_currentAffection),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // NPCキャラクター表示
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    npc.emoticon,
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '感情: ${_getEmotionText(emotion)}',
                    style: TextStyle(
                      color: _getEmotionColor(emotion),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 対話ボックス
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: Text(
              currentNode.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),

          const SizedBox(height: 16),

          // 選択肢
          if (currentNode.choices.isNotEmpty)
            ...currentNode.choices.asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: DialogueChoiceButtonWidget(
                    choiceText: choice.text,
                    choiceIndex: index,
                    onSelected: () => _selectChoice(index),
                  ),
                ),
              );
            }),

          // 対話終了メッセージ
          if (currentNode.choices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () => _selectNPC(_selectedNpcId),
                child: const Text(
                  '対話を終了',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 親密度から感情を取得
  NPCAnimationService.EmotionType _getEmotionFromAffection(int affection) {
    if (affection >= 80) return NPCAnimationService.EmotionType.happy;
    if (affection >= 60) return NPCAnimationService.EmotionType.happy;
    if (affection >= 40) return NPCAnimationService.EmotionType.neutral;
    if (affection >= 20) return NPCAnimationService.EmotionType.sad;
    return NPCAnimationService.EmotionType.angry;
  }

  /// 感情の説明文を取得
  String _getEmotionText(NPCAnimationService.EmotionType emotion) {
    switch (emotion) {
      case NPCAnimationService.EmotionType.happy:
        return '嬉しい 😊';
      case NPCAnimationService.EmotionType.sad:
        return '悲しい 😢';
      case NPCAnimationService.EmotionType.angry:
        return '怒っている 😠';
      case NPCAnimationService.EmotionType.surprised:
        return '驚いている 😮';
      case NPCAnimationService.EmotionType.excited:
        return '興奮している 🤩';
      default:
        return '普通 😐';
    }
  }

  /// 感情の色を取得
  Color _getEmotionColor(NPCAnimationService.EmotionType emotion) {
    switch (emotion) {
      case NPCAnimationService.EmotionType.happy:
        return Colors.green;
      case NPCAnimationService.EmotionType.sad:
        return Colors.blue;
      case NPCAnimationService.EmotionType.angry:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 親密度の色を取得
  Color _getAffectionColor(int affection) {
    if (affection >= 80) return Colors.red;
    if (affection >= 60) return Colors.orange;
    if (affection >= 40) return Colors.amber;
    return Colors.grey;
  }
}
