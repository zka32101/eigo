import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/providers/town_npc_location_provider.dart';

/// タウンマップNPC表示ウィジェット
class TownMapNPCWidget extends ConsumerStatefulWidget {
  /// マップの背景色
  final Color backgroundColor;

  /// マップの背景画像パス（オプション）
  final String? backgroundImagePath;

  /// NPC選択時のコールバック
  final Function(NPCLocation)? onNPCTapped;

  /// マップの高さ
  final double mapHeight;

  const TownMapNPCWidget({
    Key? key,
    this.backgroundColor = Colors.lightBlue,
    this.backgroundImagePath,
    this.onNPCTapped,
    this.mapHeight = 400,
  }) : super(key: key);

  @override
  ConsumerState<TownMapNPCWidget> createState() => _TownMapNPCWidgetState();
}

class _TownMapNPCWidgetState extends ConsumerState<TownMapNPCWidget> {
  late NPCCoordinate _playerPosition;
  NPCLocation? _selectedNPC;

  @override
  void initState() {
    super.initState();
    _playerPosition = NPCCoordinate(x: 0.5, y: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final townMapData = ref.watch(currentAreaNPCDataProvider);
    final interactableNPC = ref.watch(interactableNPCProvider);
    final nearbyNPCs = ref.watch(nearbyNPCsProvider);

    return Container(
      height: widget.mapHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // マップ背景
          if (widget.backgroundImagePath != null)
            Image.asset(
              widget.backgroundImagePath!,
              fit: BoxFit.cover,
            ),

          // NPCマーカー
          if (townMapData != null)
            ...townMapData.npcLocations.map((npc) {
              return Positioned(
                left: npc.coordinate.x * widget.mapHeight / 0.7,
                top: npc.coordinate.y * widget.mapHeight,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedNPC = npc);
                    widget.onNPCTapped?.call(npc);
                  },
                  child: NPCMapMarker(
                    npc: npc,
                    isSelected: _selectedNPC?.npcId == npc.npcId,
                    isInteractable: interactableNPC?.npcId == npc.npcId,
                  ),
                ),
              );
            }).toList(),

          // プレイヤーキャラクター
          Positioned(
            left: _playerPosition.x * widget.mapHeight / 0.7,
            top: _playerPosition.y * widget.mapHeight,
            child: const PlayerMarker(),
          ),

          // 操作パネル
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildControlPanel(context, nearbyNPCs, interactableNPC),
          ),
        ],
      ),
    );
  }

  /// 操作パネルを構築
  Widget _buildControlPanel(
    BuildContext context,
    List<NPCLocation> nearbyNPCs,
    NPCLocation? interactableNPC,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 近くのNPC表示
          if (nearbyNPCs.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '近くのNPC',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: nearbyNPCs
                      .take(3) // 最大3つまで表示
                      .map(
                        (npc) => Chip(
                          avatar: Text(npc.emoji),
                          label: Text(npc.name),
                          onDeleted:
                              null, // デコレーション用なのでdeleteボタンは不要
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

          if (interactableNPC != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNPCTapped?.call(interactableNPC);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(interactableNPC.emoji),
                    const SizedBox(width: 8),
                    Text(
                      '${interactableNPC.name}と会話',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// NPCマーカーウィジェット
class NPCMapMarker extends StatelessWidget {
  /// NPCロケーション情報
  final NPCLocation npc;

  /// 選択状態
  final bool isSelected;

  /// 相互作用可能状態
  final bool isInteractable;

  const NPCMapMarker({
    Key? key,
    required this.npc,
    this.isSelected = false,
    this.isInteractable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue
            : isInteractable
                ? Colors.green
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withAlpha(127),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            npc.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            npc.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (npc.currentState != 'idle')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                npc.currentState,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// プレイヤーマーカーウィジェット
class PlayerMarker extends StatelessWidget {
  const PlayerMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepOrange, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👤', style: TextStyle(fontSize: 20)),
          SizedBox(height: 2),
          Text(
            'You',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// NPCスタタスパネルウィジェット
class NPCStatusPanel extends StatelessWidget {
  /// NPCロケーション情報
  final NPCLocation npc;

  /// パネルを閉じる時のコールバック
  final VoidCallback? onClose;

  const NPCStatusPanel({
    Key? key,
    required this.npc,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(npc.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          npc.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          npc.profession,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const Divider(),

            // 状態表示
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Text('Status: '),
                  Chip(
                    label: Text(npc.currentState),
                    backgroundColor: _getStateColor(npc.currentState),
                  ),
                ],
              ),
            ),

            // 位置表示
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '位置: (${(npc.coordinate.x * 100).toStringAsFixed(1)}%, ${(npc.coordinate.y * 100).toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'idle':
        return Colors.grey;
      case 'moving':
        return Colors.blue;
      case 'talking':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
