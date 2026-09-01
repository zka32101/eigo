/// ゲーム内アイテムモデル
class Item {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price; // コイン価格
  final ItemType type;
  final int effect; // 効果値（回復量、ブーストなど）
  final String? category; // カテゴリ（消費品、装備など）

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.type,
    required this.effect,
    this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      price: json['price'] as int,
      type: ItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ItemType.consumable,
      ),
      effect: json['effect'] as int? ?? 0,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'price': price,
    'type': type.name,
    'effect': effect,
    'category': category,
  };
}

/// アイテムタイプ
enum ItemType {
  consumable, // 消費品（ポーション、ブースト）
  equipment,  // 装備品（アバター、アクセサリ）
  collectible, // 収集品
  gift,       // ギフト
}

/// インベントリアイテム（個数情報付き）
class InventoryItem {
  final Item item;
  final int quantity;
  final DateTime acquiredAt;

  const InventoryItem({
    required this.item,
    required this.quantity,
    required this.acquiredAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      acquiredAt: DateTime.parse(json['acquiredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    'acquiredAt': acquiredAt.toIso8601String(),
  };

  InventoryItem copyWith({
    Item? item,
    int? quantity,
    DateTime? acquiredAt,
  }) {
    return InventoryItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      acquiredAt: acquiredAt ?? this.acquiredAt,
    );
  }
}

/// ショップアイテム（購入前）
class ShopItem {
  final Item item;
  final bool isPurchased;
  final bool isNew;

  const ShopItem({
    required this.item,
    this.isPurchased = false,
    this.isNew = false,
  });
}

/// あらかじめ定義されたアイテムカタログ
final List<Item> catalogItems = [
  Item(
    id: 'potion_health',
    name: 'HPポーション',
    description: '体力を50回復させます',
    emoji: '🧪',
    price: 50,
    type: ItemType.consumable,
    effect: 50,
    category: 'ポーション',
  ),
  Item(
    id: 'potion_focus',
    name: '集中力ポーション',
    description: 'スピーキング精度を+20%ブースト',
    emoji: '💫',
    price: 75,
    type: ItemType.consumable,
    effect: 20,
    category: 'ポーション',
  ),
  Item(
    id: 'boost_xp',
    name: 'XPブースト（24時間）',
    description: '24時間の間、獲得XPが1.5倍になります',
    emoji: '⚡',
    price: 150,
    type: ItemType.consumable,
    effect: 150,
    category: 'ブースト',
  ),
  Item(
    id: 'boost_coin',
    name: 'コインブースト（12時間）',
    description: '12時間の間、獲得コインが2倍になります',
    emoji: '🪙',
    price: 120,
    type: ItemType.consumable,
    effect: 120,
    category: 'ブースト',
  ),
  Item(
    id: 'accessory_crown',
    name: '王冠アクセサリ',
    description: 'キャラクターに装備できるアクセサリ',
    emoji: '👑',
    price: 300,
    type: ItemType.equipment,
    effect: 0,
    category: 'アクセサリ',
  ),
  Item(
    id: 'accessory_glasses',
    name: 'めがね',
    description: 'インテリ感を演出するアクセサリ',
    emoji: '👓',
    price: 200,
    type: ItemType.equipment,
    effect: 0,
    category: 'アクセサリ',
  ),
  Item(
    id: 'lucky_egg',
    name: 'ラッキーエッグ',
    description: 'レアアイテム。幸運をもたらします',
    emoji: '🥚',
    price: 500,
    type: ItemType.collectible,
    effect: 0,
    category: 'コレクション',
  ),
  Item(
    id: 'star_badge',
    name: 'スターバッジ',
    description: 'マイルストーン達成の証',
    emoji: '⭐',
    price: 250,
    type: ItemType.collectible,
    effect: 0,
    category: 'コレクション',
  ),
];
