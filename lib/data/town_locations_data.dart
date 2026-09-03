import 'package:eigo/models/english_town_model.dart';

/// タウンロケーション初期化データ
class TownLocationsData {
  /// 全ロケーションリストを取得
  static List<Location> getAllLocations() {
    return [
      Location(
        id: 'school',
        name: 'School',
        emoji: '🏫',
        description: 'Learn classroom and educational phrases. Meet Miss Sarah and interact with other students.',
        position: 'x:100,y:150',
        npcIds: ['npc_sarah', 'npc_student1', 'npc_student2'],
        sceneIds: ['scene_school_1', 'scene_school_2', 'scene_school_3'],
        backgroundImage: 'assets/locations/school_bg.png',
        surroundingArea: 'Educational District',
        difficultyLevel: 1,
        unlockedAt: DateTime.now(),
      ),
      Location(
        id: 'cafe',
        name: 'Café',
        emoji: '☕',
        description: 'Practice ordering drinks and small talk. Chat with Tom the friendly barista.',
        position: 'x:250,y:150',
        npcIds: ['npc_tom', 'npc_customer1'],
        sceneIds: ['scene_cafe_1', 'scene_cafe_2', 'scene_cafe_3'],
        backgroundImage: 'assets/locations/cafe_bg.png',
        surroundingArea: 'Downtown',
        difficultyLevel: 1,
        unlockedAt: DateTime.now(),
      ),
      Location(
        id: 'library',
        name: 'Library',
        emoji: '📚',
        description: 'Learn academic and research-related phrases. Chat with Emily the librarian.',
        position: 'x:100,y:300',
        npcIds: ['npc_emily', 'npc_reader1'],
        sceneIds: ['scene_library_1', 'scene_library_2', 'scene_library_3'],
        backgroundImage: 'assets/locations/library_bg.png',
        surroundingArea: 'Knowledge Zone',
        difficultyLevel: 2,
        unlockedAt: DateTime.now().add(const Duration(hours: 2)),
      ),
      Location(
        id: 'shop',
        name: 'Shop',
        emoji: '🛍️',
        description: 'Practice shopping and transaction phrases. Negotiate prices with Mr. Chen.',
        position: 'x:250,y:300',
        npcIds: ['npc_chen', 'npc_customer2'],
        sceneIds: ['scene_shop_1', 'scene_shop_2', 'scene_shop_3'],
        backgroundImage: 'assets/locations/shop_bg.png',
        surroundingArea: 'Shopping District',
        difficultyLevel: 2,
        unlockedAt: DateTime.now().add(const Duration(hours: 3)),
      ),
      Location(
        id: 'restaurant',
        name: 'Restaurant',
        emoji: '🍽️',
        description: 'Practice dining and food-related conversations. Explore cuisine with Marco.',
        position: 'x:400,y:200',
        npcIds: ['npc_marco', 'npc_diner1'],
        sceneIds: ['scene_restaurant_1', 'scene_restaurant_2', 'scene_restaurant_3'],
        backgroundImage: 'assets/locations/restaurant_bg.png',
        surroundingArea: 'Culinary Zone',
        difficultyLevel: 2,
        unlockedAt: DateTime.now().add(const Duration(hours: 4)),
      ),
      Location(
        id: 'park',
        name: 'Park',
        emoji: '🌳',
        description: 'Learn outdoor and activity phrases. Join Lisa for a jog or outdoor chat.',
        position: 'x:150,y:450',
        npcIds: ['npc_lisa', 'npc_jogger1'],
        sceneIds: ['scene_park_1', 'scene_park_2', 'scene_park_3'],
        backgroundImage: 'assets/locations/park_bg.png',
        surroundingArea: 'Recreation Area',
        difficultyLevel: 3,
        unlockedAt: DateTime.now().add(const Duration(hours: 5)),
      ),
      Location(
        id: 'station',
        name: 'Bus Station',
        emoji: '🚏',
        description: 'Learn transportation and travel phrases. Get directions from David.',
        position: 'x:350,y:450',
        npcIds: ['npc_david', 'npc_traveler1'],
        sceneIds: ['scene_station_1', 'scene_station_2', 'scene_station_3'],
        backgroundImage: 'assets/locations/station_bg.png',
        surroundingArea: 'Transit Hub',
        difficultyLevel: 3,
        unlockedAt: DateTime.now().add(const Duration(hours: 6)),
      ),
      Location(
        id: 'museum',
        name: 'Museum',
        emoji: '🏛️',
        description: 'Learn history and cultural phrases. Explore exhibits with Dr. Wilson.',
        position: 'x:250,y:500',
        npcIds: ['npc_wilson', 'npc_visitor1'],
        sceneIds: ['scene_museum_1', 'scene_museum_2', 'scene_museum_3'],
        backgroundImage: 'assets/locations/museum_bg.png',
        surroundingArea: 'Cultural District',
        difficultyLevel: 4,
        unlockedAt: DateTime.now().add(const Duration(hours: 8)),
      ),
    ];
  }

  /// 特定のロケーションを取得
  static Location? getLocationById(String locationId) {
    try {
      return getAllLocations().firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  /// ロケーションをアンロック状態に基づいてフィルタリング
  static List<Location> getUnlockedLocations() {
    return getAllLocations().where((loc) => loc.unlockedAt != null).toList();
  }

  /// 難易度別にロケーションを取得
  static List<Location> getLocationsByDifficulty(int difficulty) {
    return getAllLocations()
        .where((loc) => loc.difficultyLevel == difficulty)
        .toList();
  }

  /// ロケーション統計
  static Map<String, dynamic> getLocationStats() {
    final locations = getAllLocations();
    return {
      'totalLocations': locations.length,
      'totalNPCs': locations.fold<int>(
        0,
        (sum, loc) => sum + loc.npcIds.length,
      ),
      'totalScenes': locations.fold<int>(
        0,
        (sum, loc) => sum + loc.sceneIds.length,
      ),
      'averageDifficulty':
          locations.fold<int>(0, (sum, loc) => sum + loc.difficultyLevel) /
              locations.length,
    };
  }
}
