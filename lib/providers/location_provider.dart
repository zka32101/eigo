import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/services/english_town_firebase_service.dart';

/// ロケーション一覧を管理するStateNotifier
class LocationsNotifier extends StateNotifier<List<Location>> {
  LocationsNotifier(this._firebaseService) : super([]) {
    _initializeLocations();
  }

  final EnglishTownFirebaseService _firebaseService;

  /// ロケーションを初期化
  Future<void> _initializeLocations() async {
    try {
      final locations = await _firebaseService.fetchLocations();
      state = locations;
    } catch (e) {
      print('Error initializing locations: $e');
      state = [];
    }
  }

  /// ロケーションをアンロック
  Future<void> visitLocation(String locationId) async {
    try {
      state = state.map((loc) {
        if (loc.id == locationId) {
          return loc.copyWith(
            unlockedAt: loc.unlockedAt ?? DateTime.now(),
          );
        }
        return loc;
      }).toList();
      await _firebaseService.saveLocations(state);
    } catch (e) {
      print('Error visiting location: $e');
    }
  }

  /// すべてのロケーションをアンロック（開発用）
  Future<void> unlockAllLocations() async {
    try {
      state = state.map((loc) {
        return loc.copyWith(
          unlockedAt: loc.unlockedAt ?? DateTime.now(),
        );
      }).toList();
      await _firebaseService.saveLocations(state);
    } catch (e) {
      print('Error unlocking all locations: $e');
    }
  }
}

/// ロケーション一覧プロバイダー
final locationsProvider =
    StateNotifierProvider<LocationsNotifier, List<Location>>((ref) {
  final firebaseService = ref.watch(englishTownFirebaseServiceProvider);
  return LocationsNotifier(firebaseService);
});

/// アンロック済みロケーションのみをフィルタリング
final unlockedLocationsProvider = Provider<List<Location>>((ref) {
  final locations = ref.watch(locationsProvider);
  return locations.where((loc) => loc.unlockedAt != null).toList();
});

/// 現在のプレイヤーロケーションを管理
class CurrentLocationNotifier extends StateNotifier<String?> {
  CurrentLocationNotifier() : super(null);

  void setCurrentLocation(String? locationId) {
    state = locationId;
  }
}

/// 現在のロケーションプロバイダー
final currentLocationProvider =
    StateNotifierProvider<CurrentLocationNotifier, String?>((ref) {
  return CurrentLocationNotifier();
});

/// IDでロケーション詳細を取得
final locationByIdProvider =
    Provider.family<Location?, String>((ref, locationId) {
  final locations = ref.watch(locationsProvider);
  try {
    return locations.firstWhere((loc) => loc.id == locationId);
  } catch (e) {
    return null;
  }
});

/// 特定のロケーションに存在するNPC一覧を取得
final npcsAtLocationProvider =
    Provider.family<List<NPC>, String>((ref, locationId) {
  final location = ref.watch(locationByIdProvider(locationId));
  if (location == null) return [];

  // Note: This would require an npcProvider in a full implementation
  // For now, return empty list - will be implemented with NPC service
  return [];
});

/// 2つのロケーション間の距離を計算
final locationDistanceProvider =
    Provider.family<double, (String, String)>((ref, locationIds) {
  final fromLoc = ref.watch(locationByIdProvider(locationIds.$1));
  final toLoc = ref.watch(locationByIdProvider(locationIds.$2));

  if (fromLoc == null || toLoc == null) return 0.0;

  // Parse positions like "x:100,y:200"
  final fromParts = fromLoc.position.split(',');
  final toParts = toLoc.position.split(',');

  double fromX = 0, fromY = 0, toX = 0, toY = 0;

  try {
    fromX = double.parse(fromParts[0].split(':')[1]);
    fromY = double.parse(fromParts[1].split(':')[1]);
    toX = double.parse(toParts[0].split(':')[1]);
    toY = double.parse(toParts[1].split(':')[1]);
  } catch (e) {
    return 0.0;
  }

  // Calculate Euclidean distance
  final dx = toX - fromX;
  final dy = toY - fromY;
  return (dx * dx + dy * dy).toDouble().sqrt();
});

/// 最初のアンロック済みロケーション（ハブロケーション）を取得
final hubLocationProvider = Provider<Location?>((ref) {
  final unlockedLocations = ref.watch(unlockedLocationsProvider);
  if (unlockedLocations.isEmpty) return null;
  return unlockedLocations.first;
});

/// ロケーション進捗（訪問、ロック状態）を更新するアクションプロバイダー
final updateLocationProgressProvider =
    Provider.family<Future<void>, (String, bool)>((ref, params) async {
  final locationId = params.$1;
  final isVisited = params.$2;

  if (isVisited) {
    final locationsNotifier = ref.read(locationsProvider.notifier);
    await locationsNotifier.visitLocation(locationId);
  }
});
