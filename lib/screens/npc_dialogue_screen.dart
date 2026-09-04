import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_behavior_service.dart';
import 'package:eigo/services/npc_event_service.dart';
import 'package:eigo/providers/npc_dialogue_provider.dart';
import 'package:eigo/providers/npc_behavior_provider.dart';
import 'package:eigo/widgets/dialogue_option_widget.dart';
import 'package:eigo/widgets/npc_mood_indicator.dart';

/// NPC との対話スクリーン
class NPCDialogueScreen extends ConsumerStatefulWidget {
  final String npcId;
  final String npcName;
  final String npcAvatarPath;

  const NPCDialogueScreen({
    required this.npcId,
    required this.npcName,
    required this.npcAvatarPath,
  });

  @override
  ConsumerState<NPCDialogueScreen> createState() => _NPCDialogueScreenState();
}

class _NPCDialogueScreenState extends ConsumerState<NPCDialogueScreen> {
  late NPCDialogueService _dialogueService;
  late NPCBehaviorService _behaviorService;
  late NPCEventService _eventService;

  @override
  void initState() {
    super.initState();
    _dialogueService = NPCDialogueService.getInstance();
    _behaviorService = NPCBehaviorService.getInstance();
    _eventService = NPCEventService.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    // 現在の対話セッション
    final sessionAsync = ref.watch(dialogueSessionProvider(widget.npcId));

    // NPC の行動状態
    final behaviorAsync =
        ref.watch(npcBehaviorStateProvider(widget.npcId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.npcName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: sessionAsync.when(
        data: (session) => behaviorAsync.when(
          data: (behavior) => _buildDialogueContent(
            context,
            session,
            behavior,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err'),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildDialogueContent(
    BuildContext context,
    DialogueSession session,
    NPCBehaviorState behavior,
  ) {
    return Column(
      children: [
        // NPC 情報ヘッダー
        _buildNPCHeader(behavior),

        // 対話コンテンツ
        Expanded(
          child: session.isActive
              ? _buildActiveDialogue(context, session, behavior)
              : _buildInactiveDialogue(context),
        ),

        // 対話オプション
        if (session.isActive)
          _buildDialogueOptions(context, session, behavior),
      ],
    );
  }

  Widget _buildNPCHeader(NPCBehaviorState behavior) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // NPC アバター
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(widget.npcAvatarPath),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 16),

          // NPC 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.npcName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // ムード指標
                NPCMoodIndicator(mood: behavior.currentMood),
                const SizedBox(height: 8),

                // 親密度表示
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Affection: ${behavior.currentAffection}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDialogue(
    BuildContext context,
    DialogueSession session,
    NPCBehaviorState behavior,
  ) {
    final currentNode = session.currentNode;
    if (currentNode == null) {
      return const Center(
        child: Text('No dialogue node found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NPC テキスト表示
          _buildNPCDialogueBox(currentNode, behavior),
          const SizedBox(height: 24),

          // 前の選択肢の結果表示
          if (session.selectedOptions.isNotEmpty)
            _buildPreviousInteraction(session),
        ],
      ),
    );
  }

  Widget _buildNPCDialogueBox(
    DialogueNode node,
    NPCBehaviorState behavior,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 絵文字とテキスト
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node.emoticon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    node.emoticon!,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              Expanded(
                child: Text(
                  node.npcText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousInteraction(DialogueSession session) {
    final lastSelected = session.selectedOptions.last;
    final affectionChange = lastSelected.affectionChange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: affectionChange > 0
            ? Colors.green.withOpacity(0.1)
            : affectionChange < 0
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            affectionChange > 0
                ? Icons.trending_up
                : affectionChange < 0
                    ? Icons.trending_down
                    : Icons.remove,
            color: affectionChange > 0
                ? Colors.green
                : affectionChange < 0
                    ? Colors.red
                    : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your choice: "${lastSelected.text}"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (affectionChange != 0)
            Text(
              '${affectionChange > 0 ? '+' : ''}$affectionChange',
              style: TextStyle(
                fontSize: 12,
                color: affectionChange > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInactiveDialogue(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No active dialogue',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final notifier = ref.read(dialogueSessionProvider(widget.npcId).notifier);
              _startDialogue(notifier);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start Conversation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueOptions(
    BuildContext context,
    DialogueSession session,
    NPCBehaviorState behavior,
  ) {
    final currentNode = session.currentNode;
    if (currentNode == null || currentNode.options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final notifier =
                  ref.read(dialogueSessionProvider(widget.npcId).notifier);
              _endDialogue(notifier);
              Navigator.pop(context);
            },
            child: const Text('End Conversation'),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'How do you respond?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...currentNode.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DialogueOptionWidget(
                option: option,
                onSelected: () {
                  final notifier = ref.read(
                    dialogueSessionProvider(widget.npcId).notifier,
                  );
                  _selectOption(notifier, option, behavior);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _startDialogue(DialogueSessionNotifier notifier) {
    notifier.startDialogue(widget.npcId);
  }

  void _selectOption(
    DialogueSessionNotifier notifier,
    DialogueOption option,
    NPCBehaviorState behavior,
  ) {
    notifier.selectOption(option);

    // イベントトリガーの確認
    if (option.eventId != null) {
      final event = _eventService.getEvent(option.eventId!);
      if (event != null) {
        _eventService.processEvent(event.eventId);
        _showEventNotification(event);
      }
    }

    // 少し遅延してから次の対話ノードに進む
    Future.delayed(const Duration(milliseconds: 500), () {
      notifier.continueDialogue();
    });
  }

  void _endDialogue(DialogueSessionNotifier notifier) {
    notifier.endDialogue();
  }

  void _showEventNotification(NPCEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (event.reward != null && event.reward!.affectionBonus > 0)
                    Text(
                      '+${event.reward!.affectionBonus} affection',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
