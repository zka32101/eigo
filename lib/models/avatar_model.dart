class AvatarIcon {
  final String id;
  final String emoji;
  final String name;
  final int price; // -1 = デフォルト無料
  final bool isDefault; // true = 最初から利用可

  AvatarIcon({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    required this.isDefault,
  });

  bool get isPurchasable => price > 0;
}

// 16個のアバターアイコン
final allAvatarIcons = [
  // デフォルト4つ (無料)
  AvatarIcon(
    id: 'avatar_1',
    emoji: '👧',
    name: 'ガール',
    price: -1,
    isDefault: true,
  ),
  AvatarIcon(
    id: 'avatar_2',
    emoji: '👦',
    name: 'ボーイ',
    price: -1,
    isDefault: true,
  ),
  AvatarIcon(
    id: 'avatar_3',
    emoji: '🧒',
    name: 'キッズ',
    price: -1,
    isDefault: true,
  ),
  AvatarIcon(
    id: 'avatar_4',
    emoji: '👶',
    name: 'ベビー',
    price: -1,
    isDefault: true,
  ),
  // ショップ購入12個
  AvatarIcon(
    id: 'avatar_5',
    emoji: '🎀',
    name: 'リボン',
    price: 100,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_6',
    emoji: '⚡',
    name: 'スター',
    price: 100,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_7',
    emoji: '🌟',
    name: 'シャイン',
    price: 100,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_8',
    emoji: '💫',
    name: 'スパークル',
    price: 100,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_9',
    emoji: '🦊',
    name: 'キツネ',
    price: 150,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_10',
    emoji: '🐰',
    name: 'ウサギ',
    price: 150,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_11',
    emoji: '🐼',
    name: 'パンダ',
    price: 150,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_12',
    emoji: '🦁',
    name: 'ライオン',
    price: 150,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_13',
    emoji: '🧚',
    name: 'フェアリー',
    price: 200,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_14',
    emoji: '🧙',
    name: 'ウィザード',
    price: 200,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_15',
    emoji: '🎭',
    name: 'アクター',
    price: 200,
    isDefault: false,
  ),
  AvatarIcon(
    id: 'avatar_16',
    emoji: '👑',
    name: 'ロイヤル',
    price: 250,
    isDefault: false,
  ),
];
