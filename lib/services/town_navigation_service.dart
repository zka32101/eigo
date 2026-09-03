import 'package:eigo/models/english_town_model.dart';

/// タウンナビゲーションサービス（シングルトンパターン）
/// ロケーション間の移動と遷移アニメーションを管理
class TownNavigationService {
  static final TownNavigationService _instance =
      TownNavigationService._internal();

  factory TownNavigationService() {
    return _instance;
  }

  TownNavigationService._internal();

  /// 現在のロケーションID
  String? _currentLocationId;

  /// 訪問したロケーションの履歴
  final List<String> _navigationHistory = [];

  /// ロケーション一覧（キャッシュ用）
  List<Location> _cachedLocations = [];

  /// シングルトンインスタンスを取得
  static TownNavigationService getInstance() {
    return _instance;
  }

  /// ロケーションキャッシュを更新
  void updateLocationsCache(List<Location> locations) {
    _cachedLocations = locations;
  }

  /// 特定のロケーションに移動できるか検証
  bool canAccessLocation(String locationId) {
    final location = _cachedLocations.firstWhere(
      (loc) => loc.id == locationId,
      orElse: () => Location(
        id: '',
        name: '',
        emoji: '',
        description: '',
        position: '',
        npcIds: [],
        sceneIds: [],
        backgroundImage: '',
        difficultyLevel: 0,
      ),
    );

    if (location.id.isEmpty) return false;

    // ロケーションがアンロック済みかチェック
    return location.unlockedAt != null;
  }

  /// ロケーションに移動
  Future<bool> navigateToLocation(String locationId) async {
    // アクセス可能か検証
    if (!canAccessLocation(locationId)) {
      print('Cannot access location: $locationId');
      return false;
    }

    try {
      // 現在のロケーションを更新
      if (_currentLocationId != null) {
        _navigationHistory.add(_currentLocationId!);
      }
      _currentLocationId = locationId;

      print('Navigated to location: $locationId');
      return true;
    } catch (e) {
      print('Error navigating to location: $e');
      return false;
    }
  }

  /// ハブロケーションに戻る
  Future<void> returnToHub() async {
    // 最初にアンロック済みのロケーションに戻す
    final hubLocation = _cachedLocations.where((loc) {
      return loc.unlockedAt != null;
    }).first;

    if (hubLocation.id.isNotEmpty) {
      await navigateToLocation(hubLocation.id);
    }
  }

  /// 前のロケーションに戻る
  Future<void> navigateBack() async {
    if (_navigationHistory.isNotEmpty) {
      final previousLocationId = _navigationHistory.removeLast();
      _currentLocationId = previousLocationId;
      print('Navigated back to: $previousLocationId');
    }
  }

  /// 2つのロケーション間のナビゲーションパスを取得
  /// （将来の拡張用：最短経路アルゴリズム）
  List<String> getNavigationPath(String fromId, String toId) {
    // 簡易実装：直接移動
    return [fromId, toId];
  }

  /// 2つのロケーション間の距離を計算
  double calculateDistance(Location from, Location to) {
    try {
      // Parse positions like "x:100,y:200"
      final fromParts = from.position.split(',');
      final toParts = to.position.split(',');

      final fromX = double.parse(fromParts[0].split(':')[1]);
      final fromY = double.parse(fromParts[1].split(':')[1]);
      final toX = double.parse(toParts[0].split(':')[1]);
      final toY = double.parse(toParts[1].split(':')[1]);

      final dx = toX - fromX;
      final dy = toY - fromY;
      return (dx * dx + dy * dy).toDouble().sqrt();
    } catch (e) {
      print('Error calculating distance: $e');
      return 0.0;
    }
  }

  /// ナビゲーション履歴をクリア
  void clearHistory() {
    _navigationHistory.clear();
  }

  /// 現在のロケーションを取得
  String? getCurrentLocationId() {
    return _currentLocationId;
  }

  /// ナビゲーション履歴を取得
  List<String> getNavigationHistory() {
    return List.unmodifiable(_navigationHistory);
  }

  /// 訪問したロケーション数を取得
  int getVisitedLocationCount() {
    return _navigationHistory.length + (_currentLocationId != null ? 1 : 0);
  }
}
