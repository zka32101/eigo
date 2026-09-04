import 'package:flutter/material.dart';
import 'package:eigo/models/housing_system.dart';
import 'package:eigo/models/interior_design_system.dart';

/// ハウジングシステムのデモンストレーション
/// 家具配置、ルームカスタマイズ、デザインテーマ、ストレージ管理を展示
class HousingSystemExample extends StatefulWidget {
  const HousingSystemExample({Key? key}) : super(key: key);

  @override
  State<HousingSystemExample> createState() => _HousingSystemExampleState();
}

class _HousingSystemExampleState extends State<HousingSystemExample> {
  late HousingSystem _housingSystem;
  late InteriorDesignSystem _designSystem;
  late PlayerHouse _house;

  int _selectedTabIndex = 0;
  String _selectedRoomId = 'living_room';
  String? _selectedThemeId;

  @override
  void initState() {
    super.initState();
    _housingSystem = HousingSystem.getInstance();
    _designSystem = InteriorDesignSystem.getInstance();

    _housingSystem.initialize();
    _designSystem.initialize();

    _house = _housingSystem.getOrCreateHouse('player_001');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Housing System'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: Column(
        children: [
          // タブバー
          Container(
            color: Colors.brown.shade50,
            child: Row(
              children: [
                _buildTab(0, 'Rooms', Icons.home),
                _buildTab(1, 'Furniture', Icons.chair),
                _buildTab(2, 'Design Themes', Icons.palette),
                _buildTab(3, 'Storage', Icons.storage),
                _buildTab(4, 'Info', Icons.info),
              ],
            ),
          ),
          // コンテンツエリア
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildRoomsTab(),
                _buildFurnitureTab(),
                _buildDesignTab(),
                _buildStorageTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown : Colors.brown.shade50,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.brown : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ルームタブ
  Widget _buildRoomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rooms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...(_house.rooms.map((room) {
            return _buildRoomCard(room);
          })),
        ],
      ),
    );
  }

  /// ルームカードを構築
  Widget _buildRoomCard(Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedRoomId == room.id
              ? Colors.brown.shade700
              : Colors.brown.shade200,
          width: _selectedRoomId == room.id ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.width}×${room.height} units',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${room.decorations.length} items',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _selectedRoomId = room.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade700,
            ),
            child: const Text(
              'Decorate This Room',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 家具タブ
  Widget _buildFurnitureTab() {
    final furniture = _housingSystem.getAllFurnitures();
    final currentRoom = _house.rooms.firstWhere(
      (r) => r.id == _selectedRoomId,
      orElse: () => null as Room,
    );

    if (currentRoom == null) {
      return const Center(child: Text('Please select a room first'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Furniture for ${currentRoom.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current items: ${currentRoom.decorations.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...furniture.map((item) {
            return _buildFurnitureCard(item, currentRoom);
          }),
        ],
      ),
    );
  }

  /// 家具カードを構築
  Widget _buildFurnitureCard(FurnitureDefinition furniture, Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    furniture.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRarityColor(furniture.rarity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          furniture.getRarityText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${furniture.width}×${furniture.height}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite,
                          size: 14, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '+${furniture.happiness}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 14, color: Colors.yellow.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '${furniture.costGold}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            furniture.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final placed = _housingSystem.placeFurniture(
                'player_001',
                _selectedRoomId,
                furniture.id,
                0,
                0,
              );
              if (placed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${furniture.name} placed!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot place furniture in this room'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
            ),
            child: const Text(
              'Place Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// デザインテーマタブ
  Widget _buildDesignTab() {
    final themes = _designSystem.getAllThemes();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Design Themes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...themes.map((theme) {
            return _buildThemeCard(theme);
          }),
          const SizedBox(height: 16),
          Text(
            'Recommended Layouts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._buildLayoutCards(),
        ],
      ),
    );
  }

  /// テーマカードを構築
  Widget _buildThemeCard(DesignTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                theme.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${theme.happinessBonus} happiness',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            theme.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: theme.colorScheme
                .map((color) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// レイアウトカードを構築
  List<Widget> _buildLayoutCards() {
    final currentRoom = _house.rooms.firstWhere(
      (r) => r.id == _selectedRoomId,
      orElse: () => null as Room,
    );

    if (currentRoom == null) return [];

    final layouts = _designSystem.getLayoutsByRoomType(
      currentRoom.type.toString().split('.').last,
    );

    return layouts.map((layout) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  layout.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    layout.getDifficultyText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              layout.description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '~${layout.estimatedHappiness} happiness',
              style: TextStyle(
                fontSize: 11,
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// ストレージタブ
  Widget _buildStorageTab() {
    final totalCapacity = _house.getTotalStorageCapacity();
    final usedStorage = _house.getUsedStorage();
    final usage = (usedStorage / totalCapacity * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'House Storage',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$usedStorage / $totalCapacity slots'),
                    Text(
                      '$usage%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usedStorage / totalCapacity,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_house.storageItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No items in storage',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ..._house.storageItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.itemName),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '×${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              );
            }).toList(),
        ],
      ),
    );
  }

  /// 情報タブ
  Widget _buildInfoTab() {
    final info = _housingSystem.getHouseInfo('player_001');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'House Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'House Name',
            info.houseName,
            Icons.home,
            Colors.brown,
          ),
          _buildInfoCard(
            'Level',
            'Lv. ${info.level}',
            Icons.star,
            Colors.amber,
          ),
          _buildInfoCard(
            'Happiness',
            info.happiness.toString(),
            Icons.favorite,
            Colors.red,
          ),
          _buildInfoCard(
            'Furniture Count',
            info.totalFurniture.toString(),
            Icons.chair,
            Colors.orange,
          ),
          _buildInfoCard(
            'Rooms',
            info.rooms.toString(),
            Icons.meeting_room,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 情報カードを構築
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// レアリティから色を取得
  Color _getRarityColor(FurnitureRarity rarity) {
    switch (rarity) {
      case FurnitureRarity.common:
        return Colors.grey;
      case FurnitureRarity.uncommon:
        return Colors.green;
      case FurnitureRarity.rare:
        return Colors.blue;
      case FurnitureRarity.epic:
        return Colors.purple;
      case FurnitureRarity.legendary:
        return Colors.orange;
    }
  }
}
