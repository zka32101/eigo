/// インテリアデザインシステム
/// デザインテーマ、配置戦略、レイアウト最適化

/// インテリアデザインシステム
class InteriorDesignSystem {
  static final InteriorDesignSystem _instance =
      InteriorDesignSystem._internal();

  factory InteriorDesignSystem.getInstance() {
    return _instance;
  }

  InteriorDesignSystem._internal();

  // デザインテーマ: theme_id -> DesignTheme
  final Map<String, DesignTheme> _designThemes = {};

  // 推奨レイアウト: layout_id -> RoomLayout
  final Map<String, RoomLayout> _recommendedLayouts = {};

  /// システムを初期化
  void initialize() {
    _designThemes.clear();
    _recommendedLayouts.clear();
    _initializeThemes();
    _initializeLayouts();
  }

  /// すべてのデザインテーマを初期化
  void _initializeThemes() {
    // モダンテーマ
    _registerTheme(DesignTheme(
      id: 'modern',
      name: 'Modern',
      description: 'Sleek and minimalist design with clean lines',
      colorScheme: ['#FFFFFF', '#000000', '#808080'],
      recommendedFurniture: [
        'sofa_leather',
        'bookshelf',
        'painting_sunset',
      ],
      happinessBonus: 20,
      aesthetic: DesignAesthetic.modern,
    ));

    // クラシックテーマ
    _registerTheme(DesignTheme(
      id: 'classic',
      name: 'Classic',
      description: 'Traditional elegance with ornate details',
      colorScheme: ['#8B4513', '#D2691E', '#A0522D'],
      recommendedFurniture: [
        'fireplace',
        'chandelier_crystal',
        'dining_table',
      ],
      happinessBonus: 25,
      aesthetic: DesignAesthetic.classic,
    ));

    // ナチュラルテーマ
    _registerTheme(DesignTheme(
      id: 'natural',
      name: 'Natural',
      description: 'Nature-inspired with plants and wood elements',
      colorScheme: ['#90EE90', '#228B22', '#8B7355'],
      recommendedFurniture: [
        'plant_potted',
        'bookshelf',
        'wooden_chairs',
      ],
      happinessBonus: 22,
      aesthetic: DesignAesthetic.natural,
    ));

    // ラグジュアリーテーマ
    _registerTheme(DesignTheme(
      id: 'luxury',
      name: 'Luxury',
      description: 'Opulent design with premium materials',
      colorScheme: ['#FFD700', '#C0C0C0', '#8B0000'],
      recommendedFurniture: [
        'bed_king',
        'chandelier_crystal',
        'fireplace',
      ],
      happinessBonus: 35,
      aesthetic: DesignAesthetic.luxury,
    ));

    // コージーテーマ
    _registerTheme(DesignTheme(
      id: 'cozy',
      name: 'Cozy',
      description: 'Warm and comfortable for relaxation',
      colorScheme: ['#FF6347', '#DC143C', '#8B0000'],
      recommendedFurniture: [
        'sofa_leather',
        'fireplace',
        'plant_potted',
      ],
      happinessBonus: 30,
      aesthetic: DesignAesthetic.cozy,
    ));
  }

  /// 推奨レイアウトを初期化
  void _initializeLayouts() {
    // シンプルリビングルームレイアウト
    _registerLayout(RoomLayout(
      id: 'living_simple',
      name: 'Simple Living Room',
      roomType: 'living_room',
      description: 'Basic furniture arrangement for comfort',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'sofa_leather',
          x: 2,
          y: 2,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'bookshelf',
          x: 7,
          y: 2,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'plant_potted',
          x: 7,
          y: 6,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.easy,
      requiredSpace: 30,
      estimatedHappiness: 35,
    ));

    // エレガントリビングルームレイアウト
    _registerLayout(RoomLayout(
      id: 'living_elegant',
      name: 'Elegant Living Room',
      roomType: 'living_room',
      description: 'Sophisticated arrangement with fireplace',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'fireplace',
          x: 0,
          y: 0,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'sofa_leather',
          x: 3,
          y: 2,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'bookshelf',
          x: 7,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'painting_sunset',
          x: 1,
          y: 5,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'chandelier_crystal',
          x: 4,
          y: 0,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.medium,
      requiredSpace: 50,
      estimatedHappiness: 80,
    ));

    // コンパクトベッドルームレイアウト
    _registerLayout(RoomLayout(
      id: 'bedroom_compact',
      name: 'Compact Bedroom',
      roomType: 'bedroom',
      description: 'Space-efficient bedroom arrangement',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'bed_king',
          x: 1,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'wardrobe',
          x: 5,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'plant_potted',
          x: 6,
          y: 5,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.easy,
      requiredSpace: 24,
      estimatedHappiness: 50,
    ));

    // ラグジュアリーベッドルームレイアウト
    _registerLayout(RoomLayout(
      id: 'bedroom_luxury',
      name: 'Luxury Bedroom',
      roomType: 'bedroom',
      description: 'Premium bedroom with elegant furnishings',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'bed_king',
          x: 1,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'wardrobe',
          x: 5,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'chandelier_crystal',
          x: 3,
          y: 0,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'painting_sunset',
          x: 1,
          y: 5,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.medium,
      requiredSpace: 35,
      estimatedHappiness: 90,
    ));

    // シンプルキッチンレイアウト
    _registerLayout(RoomLayout(
      id: 'kitchen_simple',
      name: 'Simple Kitchen',
      roomType: 'kitchen',
      description: 'Basic cooking space',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'stove',
          x: 1,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'dining_table',
          x: 4,
          y: 2,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.easy,
      requiredSpace: 18,
      estimatedHappiness: 35,
    ));

    // アップスケールキッチンレイアウト
    _registerLayout(RoomLayout(
      id: 'kitchen_upscale',
      name: 'Upscale Kitchen',
      roomType: 'kitchen',
      description: 'Premium cooking and dining space',
      furniturePositions: [
        FurniturePosition(
          furnitureId: 'stove',
          x: 0,
          y: 0,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'dining_table',
          x: 3,
          y: 1,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'chandelier_crystal',
          x: 4,
          y: 0,
          rotation: 0,
        ),
        FurniturePosition(
          furnitureId: 'plant_potted',
          x: 6,
          y: 4,
          rotation: 0,
        ),
      ],
      difficulty: LayoutDifficulty.medium,
      requiredSpace: 30,
      estimatedHappiness: 70,
    ));
  }

  /// テーマを登録
  void _registerTheme(DesignTheme theme) {
    _designThemes[theme.id] = theme;
  }

  /// レイアウトを登録
  void _registerLayout(RoomLayout layout) {
    _recommendedLayouts[layout.id] = layout;
  }

  /// デザインテーマを取得
  DesignTheme? getTheme(String themeId) {
    return _designThemes[themeId];
  }

  /// すべてのテーマを取得
  List<DesignTheme> getAllThemes() {
    return _designThemes.values.toList();
  }

  /// ルームレイアウトを取得
  RoomLayout? getLayout(String layoutId) {
    return _recommendedLayouts[layoutId];
  }

  /// ルームタイプ別のレイアウトを取得
  List<RoomLayout> getLayoutsByRoomType(String roomType) {
    return _recommendedLayouts.values
        .where((l) => l.roomType == roomType)
        .toList();
  }

  /// 難易度別のレイアウトを取得
  List<RoomLayout> getLayoutsByDifficulty(LayoutDifficulty difficulty) {
    return _recommendedLayouts.values
        .where((l) => l.difficulty == difficulty)
        .toList();
  }

  /// レイアウト適用可能かチェック
  bool canApplyLayout(RoomLayout layout, int roomWidth, int roomHeight) {
    return layout.requiredSpace <= (roomWidth * roomHeight);
  }

  /// テーマの互換性を計算
  double calculateThemeCompatibility(
    List<String> appliedFurniture,
    DesignTheme theme,
  ) {
    int matches = 0;
    for (final furniture in appliedFurniture) {
      if (theme.recommendedFurniture.contains(furniture)) {
        matches++;
      }
    }

    if (appliedFurniture.isEmpty) return 0.0;
    return matches / appliedFurniture.length;
  }
}

/// デザインテーマ
class DesignTheme {
  final String id;
  final String name;
  final String description;
  final List<String> colorScheme; // HEXカラー
  final List<String> recommendedFurniture; // 推奨家具ID
  final int happinessBonus;
  final DesignAesthetic aesthetic;

  DesignTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.colorScheme,
    required this.recommendedFurniture,
    required this.happinessBonus,
    required this.aesthetic,
  });
}

/// デザイン美学
enum DesignAesthetic {
  modern,
  classic,
  natural,
  luxury,
  cozy,
  industrial,
  bohemian,
}

/// 推奨ルームレイアウト
class RoomLayout {
  final String id;
  final String name;
  final String roomType;
  final String description;
  final List<FurniturePosition> furniturePositions;
  final LayoutDifficulty difficulty;
  final int requiredSpace;
  final int estimatedHappiness;

  RoomLayout({
    required this.id,
    required this.name,
    required this.roomType,
    required this.description,
    required this.furniturePositions,
    required this.difficulty,
    required this.requiredSpace,
    required this.estimatedHappiness,
  });

  /// 難易度を文字列で表示
  String getDifficultyText() {
    switch (difficulty) {
      case LayoutDifficulty.easy:
        return 'Easy';
      case LayoutDifficulty.medium:
        return 'Medium';
      case LayoutDifficulty.hard:
        return 'Hard';
    }
  }
}

/// レイアウト難易度
enum LayoutDifficulty {
  easy,
  medium,
  hard,
}

/// 家具位置
class FurniturePosition {
  final String furnitureId;
  final int x;
  final int y;
  final int rotation;

  FurniturePosition({
    required this.furnitureId,
    required this.x,
    required this.y,
    required this.rotation,
  });
}
