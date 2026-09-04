/// ギルド/ファクション展開システム
/// ギルドホール、メンバー管理、ランクシステム、テリトリー制御

/// ギルドシステム
class GuildSystem {
  static final GuildSystem _instance = GuildSystem._internal();

  factory GuildSystem.getInstance() {
    return _instance;
  }

  GuildSystem._internal();

  // ギルドデータ: faction_id -> Guild
  final Map<String, Guild> _guilds = {};

  // プレイヤーのギルドメンバーシップ: player_id -> faction_id
  final Map<String, String> _playerFactionMemberships = {};

  // ギルドホール: faction_id -> GuildHall
  final Map<String, GuildHall> _guildHalls = {};

  /// システムを初期化
  void initialize() {
    _guilds.clear();
    _guildHalls.clear();
    _playerFactionMemberships.clear();
    _initializeAllGuilds();
  }

  /// すべてのギルドを初期化
  void _initializeAllGuilds() {
    // 魔法使いの塔ギルド
    _registerGuild(Guild(
      id: 'mage_tower',
      name: 'Mage Tower Collective',
      factionId: 'mage_tower',
      leader: 'morvan_003',
      description: 'The prestigious magical research organization',
      level: 1,
      treasury: 5000,
      memberCapacity: 50,
      members: ['aria_001', 'luna_002', 'morvan_003'],
      founded: DateTime.now(),
      bonusMultiplier: 1.0,
    ));

    _registerGuildHall(GuildHall(
      id: 'mage_tower_hall',
      factionId: 'mage_tower',
      name: 'Mage Tower Hall',
      level: 1,
      rooms: [
        GuildRoom(
          id: 'library',
          name: 'Arcane Library',
          type: GuildRoomType.library,
          level: 1,
          perks: ['spell_learning_bonus', 'research_speed_bonus'],
        ),
        GuildRoom(
          id: 'lounge',
          name: 'Mage Lounge',
          type: GuildRoomType.lounge,
          level: 1,
          perks: ['member_satisfaction', 'xp_bonus'],
        ),
        GuildRoom(
          id: 'vault',
          name: 'Secure Vault',
          type: GuildRoomType.vault,
          level: 1,
          perks: ['storage_increase', 'item_protection'],
        ),
      ],
      upgrades: [],
      treasury: 0,
    ));

    // 冒険者ギルド
    _registerGuild(Guild(
      id: 'adventurers_guild',
      name: 'Adventurers Guild',
      factionId: 'adventurers_guild',
      leader: 'kai_004',
      description: 'The legendary guild of brave adventurers',
      level: 2,
      treasury: 8000,
      memberCapacity: 60,
      members: ['kai_004', 'eloise_005', 'thorn_006'],
      founded: DateTime.now().subtract(Duration(days: 30)),
      bonusMultiplier: 1.1,
    ));

    _registerGuildHall(GuildHall(
      id: 'adventurers_hall',
      factionId: 'adventurers_guild',
      name: 'Adventurers Guild Hall',
      level: 2,
      rooms: [
        GuildRoom(
          id: 'training_ground',
          name: 'Combat Training Ground',
          type: GuildRoomType.training,
          level: 2,
          perks: ['combat_training_boost', 'strength_bonus'],
        ),
        GuildRoom(
          id: 'trophy_hall',
          name: 'Trophy Hall',
          type: GuildRoomType.trophy,
          level: 1,
          perks: ['morale_boost', 'reputation_display'],
        ),
        GuildRoom(
          id: 'barracks',
          name: 'Guild Barracks',
          type: GuildRoomType.barracks,
          level: 2,
          perks: ['member_bonuses', 'recovery_speed'],
        ),
        GuildRoom(
          id: 'vault',
          name: 'Treasure Vault',
          type: GuildRoomType.vault,
          level: 2,
          perks: ['storage_increase', 'item_protection'],
        ),
      ],
      upgrades: [],
      treasury: 500,
    ));

    // 商人の街ギルド
    _registerGuild(Guild(
      id: 'merchant_cartel',
      name: 'Merchant Cartel',
      factionId: 'merchant_cartel',
      leader: 'mae_008',
      description: 'The influential trade organization',
      level: 1,
      treasury: 10000,
      memberCapacity: 45,
      members: ['zephyr_007', 'mae_008', 'oliver_009', 'isabella_010'],
      founded: DateTime.now().subtract(Duration(days: 60)),
      bonusMultiplier: 1.2,
    ));

    _registerGuildHall(GuildHall(
      id: 'merchant_hall',
      factionId: 'merchant_cartel',
      name: 'Merchant Guild Exchange',
      level: 1,
      rooms: [
        GuildRoom(
          id: 'marketplace',
          name: 'Guild Marketplace',
          type: GuildRoomType.marketplace,
          level: 1,
          perks: ['trade_discount', 'pricing_bonus'],
        ),
        GuildRoom(
          id: 'counting_house',
          name: 'Counting House',
          type: GuildRoomType.counting,
          level: 1,
          perks: ['gold_bonus', 'investment_returns'],
        ),
        GuildRoom(
          id: 'lounge',
          name: 'Merchant Lounge',
          type: GuildRoomType.lounge,
          level: 1,
          perks: ['member_satisfaction', 'networking_bonus'],
        ),
      ],
      upgrades: [],
      treasury: 1000,
    ));

    // プレイヤーをテスト用に冒険者ギルドに配置
    _playerFactionMemberships['player_001'] = 'adventurers_guild';
  }

  /// ギルドを登録
  void _registerGuild(Guild guild) {
    _guilds[guild.id] = guild;
  }

  /// ギルドホールを登録
  void _registerGuildHall(GuildHall hall) {
    _guildHalls[hall.id] = hall;
  }

  /// ギルドを取得
  Guild? getGuild(String guildId) {
    return _guilds[guildId];
  }

  /// ギルドホールを取得
  GuildHall? getGuildHall(String factionId) {
    return _guildHalls.values.firstWhere(
      (h) => h.factionId == factionId,
      orElse: () => GuildHall(
        id: '',
        factionId: '',
        name: '',
        level: 0,
        rooms: [],
        upgrades: [],
        treasury: 0,
      ),
    );
  }

  /// すべてのギルドを取得
  List<Guild> getAllGuilds() {
    return _guilds.values.toList();
  }

  /// プレイヤーが属するギルドを取得
  Guild? getPlayerGuild(String playerId) {
    final factionId = _playerFactionMemberships[playerId];
    if (factionId == null) return null;
    return _guilds[factionId];
  }

  /// プレイヤーをギルドに参加させる
  bool joinGuild(String playerId, String guildId) {
    final guild = _guilds[guildId];
    if (guild == null) return false;

    // メンバー数の制限をチェック
    if (guild.members.length >= guild.memberCapacity) {
      return false;
    }

    // 既にメンバーの場合はスキップ
    if (guild.members.contains(playerId)) {
      return false;
    }

    guild.members.add(playerId);
    _playerFactionMemberships[playerId] = guild.factionId;
    return true;
  }

  /// プレイヤーをギルドから脱退させる
  bool leaveGuild(String playerId) {
    final factionId = _playerFactionMemberships[playerId];
    if (factionId == null) return false;

    final guild = _guilds[factionId];
    if (guild == null) return false;

    guild.members.remove(playerId);
    _playerFactionMemberships.remove(playerId);
    return true;
  }

  /// ギルドメンバーを取得
  List<String> getGuildMembers(String guildId) {
    return _guilds[guildId]?.members ?? [];
  }

  /// ギルドを昇進させる
  bool promoteGuild(String guildId) {
    final guild = _guilds[guildId];
    if (guild == null) return false;

    // レベルアップの要件: メンバー数とトレジャリー
    final membersRequired = 5 + (guild.level * 2);
    final treasureRequired = 1000 * guild.level;

    if (guild.members.length < membersRequired ||
        guild.treasury < treasureRequired) {
      return false;
    }

    guild.level++;
    guild.treasury -= treasureRequired;
    guild.memberCapacity += 10;

    // ギルドホールもアップグレード
    final hall = _guildHalls.values.firstWhere(
      (h) => h.factionId == guild.factionId,
      orElse: () => GuildHall(
        id: '',
        factionId: '',
        name: '',
        level: 0,
        rooms: [],
        upgrades: [],
        treasury: 0,
      ),
    );

    if (hall.id.isNotEmpty) {
      hall.level++;
    }

    return true;
  }

  /// ギルドにゴールドを寄付
  bool donateToGuild(String playerId, int amount) {
    final guild = getPlayerGuild(playerId);
    if (guild == null || amount <= 0) return false;

    guild.treasury += amount;
    return true;
  }

  /// ギルドトレジャリーからゴールドを引き出す
  bool withdrawFromGuild(String guildId, int amount) {
    final guild = _guilds[guildId];
    if (guild == null || amount <= 0 || guild.treasury < amount) {
      return false;
    }

    guild.treasury -= amount;
    return true;
  }

  /// ギルドホールにルームを追加
  bool addRoomToHall(String factionId, GuildRoom room) {
    final hall = _guildHalls.values.firstWhere(
      (h) => h.factionId == factionId,
      orElse: () => GuildHall(
        id: '',
        factionId: '',
        name: '',
        level: 0,
        rooms: [],
        upgrades: [],
        treasury: 0,
      ),
    );

    if (hall.id.isEmpty) return false;
    if (hall.rooms.length >= 3 + hall.level) return false;

    hall.rooms.add(room);
    return true;
  }

  /// ギルドホールのルームをアップグレード
  bool upgradeRoom(String factionId, String roomId, int cost) {
    final hall = _guildHalls.values.firstWhere(
      (h) => h.factionId == factionId,
      orElse: () => GuildHall(
        id: '',
        factionId: '',
        name: '',
        level: 0,
        rooms: [],
        upgrades: [],
        treasury: 0,
      ),
    );

    if (hall.id.isEmpty || hall.treasury < cost) return false;

    final room = hall.rooms.cast<GuildRoom?>().firstWhere(
      (r) => r?.id == roomId,
      orElse: () => null,
    );

    if (room == null) return false;

    room.level++;
    hall.treasury -= cost;

    return true;
  }

  /// ギルドボーナス乗数を計算
  double getGuildBonusMultiplier(String playerId) {
    final guild = getPlayerGuild(playerId);
    return guild?.bonusMultiplier ?? 1.0;
  }

  /// ギルドの総メンバー数を取得
  int getGuildMemberCount(String guildId) {
    return _guilds[guildId]?.members.length ?? 0;
  }

  /// ギルドのメンバー容量を取得
  int getGuildMemberCapacity(String guildId) {
    return _guilds[guildId]?.memberCapacity ?? 0;
  }
}

/// ギルド定義
class Guild {
  final String id;
  final String name;
  final String factionId;
  final String leader;
  final String description;
  int level;
  int treasury;
  int memberCapacity;
  final List<String> members;
  final DateTime founded;
  double bonusMultiplier;

  Guild({
    required this.id,
    required this.name,
    required this.factionId,
    required this.leader,
    required this.description,
    required this.level,
    required this.treasury,
    required this.memberCapacity,
    required this.members,
    required this.founded,
    required this.bonusMultiplier,
  });

  /// ギルドの年齢を日数で取得
  int getAgeInDays() {
    return DateTime.now().difference(founded).inDays;
  }

  /// ギルドがリーダーシップ変更可能か確認
  bool canChangeLeadership() {
    return level >= 2;
  }
}

/// ギルドホール
class GuildHall {
  final String id;
  final String factionId;
  final String name;
  int level;
  final List<GuildRoom> rooms;
  final List<String> upgrades;
  int treasury;

  GuildHall({
    required this.id,
    required this.factionId,
    required this.name,
    required this.level,
    required this.rooms,
    required this.upgrades,
    required this.treasury,
  });

  /// ホールの最大ルーム数を計算
  int getMaxRooms() {
    return 3 + level;
  }

  /// ホールの容量を取得
  double getCapacityPercentage() {
    return rooms.length / getMaxRooms();
  }

  /// ホールの総レベルを計算
  int getTotalLevel() {
    int total = level;
    for (final room in rooms) {
      total += room.level;
    }
    return total;
  }
}

/// ギルドルーム
class GuildRoom {
  final String id;
  final String name;
  final GuildRoomType type;
  int level;
  final List<String> perks;

  GuildRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.perks,
  });

  /// ルームの説明を取得
  String getDescription() {
    switch (type) {
      case GuildRoomType.library:
        return 'Increases spell learning and research speed';
      case GuildRoomType.training:
        return 'Boosts combat training effectiveness';
      case GuildRoomType.lounge:
        return 'Improves member satisfaction and camaraderie';
      case GuildRoomType.vault:
        return 'Increases storage capacity and item security';
      case GuildRoomType.trophy:
        return 'Displays guild achievements and boosts morale';
      case GuildRoomType.barracks:
        return 'Provides recovery benefits and member bonuses';
      case GuildRoomType.marketplace:
        return 'Enables trading and commerce benefits';
      case GuildRoomType.counting:
        return 'Manages finances and investment returns';
    }
  }
}

/// ギルドルームタイプ
enum GuildRoomType {
  library,      // 図書館 - 魔法研究
  training,     // 訓練場 - 戦闘トレーニング
  lounge,       // ラウンジ - メンバー満足度
  vault,        // 金庫室 - ストレージ増加
  trophy,       // トロフィーホール - 達成表示
  barracks,     // 兵舎 - メンバーボーナス
  marketplace,  // マーケットプレイス - 取引
  counting,     // 会計室 - 金銭管理
}

/// ギルドランク
enum GuildRank {
  member,       // メンバー
  officer,      // オフィサー
  treasurer,    // 財務担当者
  leader,       // リーダー
}
