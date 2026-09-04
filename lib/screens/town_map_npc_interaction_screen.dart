import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/providers/town_npc_location_provider.dart';
import 'package:eigo/widgets/town_map_npc_widget.dart';
import 'package:eigo/screens/npc_dialogue_screen.dart';

/// タウンマップNPC相互作用スクリーン
class TownMapNPCInteractionScreen extends ConsumerStatefulWidget {
  /// エリア情報
  final TownArea area;

  /// このエリアのNPCリスト
  final List<NPC> npcsInArea;

  const TownMapNPCInteractionScreen({
    Key? key,
    required this.area,
    required this.npcsInArea,
  }) : super(key: key);

  @override
  ConsumerState<TownMapNPCInteractionScreen> createState() =>
      _TownMapNPCInteractionScreenState();
}

class _TownMapNPCInteractionScreenState
    extends ConsumerState<TownMapNPCInteractionScreen> {
  NPCLocation? _selectedNPC;
  NPCLocation? _interactingNPC;

  @override
  void initState() {
    super.initState();
    // エリアIDをセット
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(selectedAreaIdProvider.notifier)
          .state = widget.area.areaId;
    });
  }

  @override
  void dispose() {
    ref.read(selectedAreaIdProvider.notifier).state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final townMapData = ref.watch(currentAreaNPCDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.japaneseName),
        subtitle: Text(widget.area.englishName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // エリア説明
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.area.backgroundTile,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.area.japaneseName,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Lv ${widget.area.difficultyLevel}',
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.area.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // タウンマップ
            Text(
              'タウンマップ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TownMapNPCWidget(
              mapHeight: 300,
              onNPCTapped: _handleNPCTapped,
            ),
            const SizedBox(height: 20),

            // 選択されたNPCの詳細情報
            if (_selectedNPC != null) ...[
              Text(
                'NPC詳細',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              NPCStatusPanel(
                npc: _selectedNPC!,
                onClose: () {
                  setState(() => _selectedNPC = null);
                },
              ),
              const SizedBox(height: 20),

              // 会話ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startDialogue(_selectedNPC!),
                  icon: const Icon(Icons.chat),
                  label: Text(
                    '${_selectedNPC!.name}と会話を始める',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ] else if (townMapData != null && townMapData.npcLocations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'このエリアにはNPCがいません',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'マップ上のNPCをタップして選択してください',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // NPCリスト
            Text(
              'このエリアのNPC一覧',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (widget.npcsInArea.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.npcsInArea.length,
                itemBuilder: (context, index) {
                  final npc = widget.npcsInArea[index];
                  return NPCListItem(
                    npc: npc,
                    onTap: () => _selectNPCFromList(npc),
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'NPC情報がありません',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// NPCをタップしたときの処理
  void _handleNPCTapped(NPCLocation npc) {
    setState(() => _selectedNPC = npc);
  }

  /// リストからNPCを選択したときの処理
  void _selectNPCFromList(NPC npc) {
    final townMapData = ref.read(currentAreaNPCDataProvider);
    if (townMapData == null) return;

    final npcLocation = townMapData.npcLocations.firstWhere(
      (loc) => loc.npcId == npc.npcId,
      orElse: () => NPCLocation(
        npcId: npc.npcId,
        name: npc.name,
        emoji: npc.emoji,
        areaId: npc.areaId,
        coordinate: NPCCoordinate.fromPositionString(npc.position),
        isMovable: true,
        profession: npc.profession,
        lastUpdatedAt: DateTime.now(),
      ),
    );

    setState(() => _selectedNPC = npcLocation);
  }

  /// ダイアログを開始
  void _startDialogue(NPCLocation npcLocation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NPCDialogueModalScreen(
          npcLocation: npcLocation,
          onDialogueComplete: (result) {
            // ダイアログ完了後の処理
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('スコア: ${result.score}/100'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// NPCリストアイテムウィジェット
class NPCListItem extends StatelessWidget {
  /// NPC情報
  final NPC npc;

  /// タップ時のコールバック
  final VoidCallback? onTap;

  const NPCListItem({
    Key? key,
    required this.npc,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          npc.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(npc.name),
        subtitle: Text(npc.profession),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}

/// ダイアログ結果を受け取るコールバック
typedef DialogueCompleteCallback = void Function(DialogueResult);

/// ダイアログ結果
class DialogueResult {
  /// スコア（0-100）
  final int score;

  /// XP獲得量
  final int xpEarned;

  /// コイン獲得量
  final int coinsEarned;

  /// フィードバック
  final String feedback;

  DialogueResult({
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
    required this.feedback,
  });
}

/// NPC ダイアログモーダルスクリーン
class NPCDialogueModalScreen extends StatelessWidget {
  /// NPC位置情報
  final NPCLocation npcLocation;

  /// ダイアログ完了時のコールバック
  final DialogueCompleteCallback? onDialogueComplete;

  const NPCDialogueModalScreen({
    Key? key,
    required this.npcLocation,
    this.onDialogueComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NPCDialogueModalスクリーンに遷移
    return Scaffold(
      appBar: AppBar(
        title: Text(npcLocation.name),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NPC表示
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      npcLocation.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      npcLocation.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      npcLocation.profession,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // メッセージ
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'ダイアログシステムは Phase 16 Part 2 & 3 で実装されました',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'これはプレビュー画面です。実際のダイアログUIは統合スクリーンを参照してください。',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onDialogueComplete?.call(
                      DialogueResult(
                        score: 85,
                        xpEarned: 100,
                        coinsEarned: 50,
                        feedback: 'Great conversation!',
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('ダイアログを完了'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
