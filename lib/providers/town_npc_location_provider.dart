import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/services/town_npc_location_service.dart';
import 'package:eigo/providers/english_town_provider.dart';

/// NPC位置管理サービスプロバイダー
final townNPCLocationServiceProvider =
    Provider<TownNPCLocationService>((ref) {
  return TownNPCLocationService.getInstance();
});

/// エリア別NPCロケーションデータプロバイダー
final townMapNPCDataProvider = StateNotifierProvider.family<
    TownMapNPCDataNotifier,
    TownMapNPCData?,
    String>((ref, areaId) {
  final service = ref.watch(townNPCLocationServiceProvider);
  final npcsAsync = ref.watch(npcsProvider);

  return TownMapNPCDataNotifier(
    service: service,
    npcsAsync: npcsAsync,
    areaId: areaId,
  );
});

/// NPCロケーションデータ管理Notifier
class TownMapNPCDataNotifier extends StateNotifier<TownMapNPCData?> {
  final TownNPCLocationService _service;
  final AsyncValue<List<NPC>> _npcsAsync;
  final String _areaId;

  TownMapNPCDataNotifier({
    required TownNPCLocationService service,
    required AsyncValue<List<NPC>> npcsAsync,
    required String areaId,
  })  : _service = service,
        _npcsAsync = npcsAsync,
        _areaId = areaId,
        super(null) {
    _initialize();
  }

  /// 初期化
  void _initialize() {
    _npcsAsync.when(
      data: (npcs) {
        final npcsInArea = npcs.where((npc) => npc.areaId == _areaId).toList();
        if (npcsInArea.isNotEmpty) {
          state = _service.initializeNPCLocations(_areaId, npcsInArea);
        }
      },
      error: (_, __) => state = null,
      loading: () => state = null,
    );
  }

  /// NPCを移動
  void moveNPC(String npcId, NPCCoordinate newCoordinate) {
    if (state == null) return;

    final updatedLocations = state!.npcLocations.map((npc) {
      if (npc.npcId == npcId) {
        return _service.moveNPC(npc, newCoordinate);
      }
      return npc;
    }).toList();

    state = _service.updateTownMapNPCData(state!, updatedLocations);
  }

  /// NPCの状態を更新
  void updateNPCState(String npcId, String newState) {
    if (state == null) return;

    final updatedLocations = state!.npcLocations.map((npc) {
      if (npc.npcId == npcId) {
        return _service.updateNPCState(npc, newState);
      }
      return npc;
    }).toList();

    state = _service.updateTownMapNPCData(state!, updatedLocations);
  }

  /// 指定座標に最も近いNPCを取得
  NPCLocation? getNearestNPC(NPCCoordinate playerCoordinate,
      {double proximityThreshold = 0.15}) {
    if (state == null) return null;
    return _service.getNearestNPC(
      state!.npcLocations,
      playerCoordinate,
      proximityThreshold,
    );
  }

  /// プレイヤーの範囲内にいるNPCを取得
  List<NPCLocation> getNPCsInRange(NPCCoordinate playerCoordinate,
      {double rangeRadius = 0.25}) {
    if (state == null) return [];
    return _service.getNPCsInRange(
      state!.npcLocations,
      playerCoordinate,
      rangeRadius,
    );
  }

  /// NPCのリセット
  void reset() {
    _initialize();
  }
}

/// 現在選択されているエリアのNPCロケーション
final currentAreaNPCDataProvider =
    Provider<TownMapNPCData?>((ref) {
  final selectedAreaId = ref.watch(selectedAreaIdProvider);
  if (selectedAreaId == null) return null;
  return ref.watch(townMapNPCDataProvider(selectedAreaId));
});

/// 選択されているエリアID（ヘルパープロバイダー）
final selectedAreaIdProvider = StateProvider<String?>((ref) {
  return null;
});

/// プレイヤーの現在位置
final playerCoordinateProvider = StateProvider<NPCCoordinate>((ref) {
  return NPCCoordinate(x: 0.5, y: 0.5); // デフォルト中央
});

/// プレイヤーの近くのNPCリスト
final nearbyNPCsProvider = Provider<List<NPCLocation>>((ref) {
  final townMapData = ref.watch(currentAreaNPCDataProvider);
  final playerPos = ref.watch(playerCoordinateProvider);

  if (townMapData == null) return [];

  return townMapData.npcLocations
      .where((npc) {
        final distance = _calculateDistance(playerPos, npc.coordinate);
        return distance <= 0.25; // 25%の範囲
      })
      .toList()
    ..sort((a, b) {
      final distA = _calculateDistance(playerPos, a.coordinate);
      final distB = _calculateDistance(playerPos, b.coordinate);
      return distA.compareTo(distB);
    });
});

/// プレイヤーが接近可能なNPC
final interactableNPCProvider = Provider<NPCLocation?>((ref) {
  final townMapData = ref.watch(currentAreaNPCDataProvider);
  final playerPos = ref.watch(playerCoordinateProvider);

  if (townMapData == null) return null;

  for (final npc in townMapData.npcLocations) {
    final distance = _calculateDistance(playerPos, npc.coordinate);
    if (distance <= 0.1) {
      // 10%以内は相互作用可能
      return npc;
    }
  }

  return null;
});

/// NPC相互作用イベントストリーム
final npcInteractionEventProvider =
    StreamProvider<NPCInteractionEvent?>((ref) async* {
  // デフォルトはnullを発行
  yield null;
});

/// 距離計算ヘルパー関数
double _calculateDistance(NPCCoordinate a, NPCCoordinate b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return (dx * dx + dy * dy).toDouble().sqrt();
}
