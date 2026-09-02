import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/item_model.dart';
import '../services/logger_service.dart';

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  static const String _storageKey = 'eigo_kore_inventory';

  InventoryNotifier() : super([]) {
    _loadInventory();
  }

  /// インベントリをロード
  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items = decoded
            .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
            .toList();
        state = items;
      } catch (e) {
        LoggerService.error('Error loading inventory', tag: 'InventoryNotifier', exception: e);
      }
    }
  }

  /// インベントリを保存
  Future<void> _saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// アイテムを追加または数量を増やす
  Future<void> addItem(Item item, {int quantity = 1}) async {
    final existingIndex = state.indexWhere((inv) => inv.item.id == item.id);

    if (existingIndex >= 0) {
      // 既存アイテムの数量を増やす
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(quantity: existing.quantity + quantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // 新しいアイテムを追加
      state = [
        ...state,
        InventoryItem(
          item: item,
          quantity: quantity,
          acquiredAt: DateTime.now(),
        ),
      ];
    }
    await _saveInventory();
  }

  /// アイテムを使用（数量を減らす）
  Future<bool> useItem(String itemId, {int quantity = 1}) async {
    final existingIndex = state.indexWhere((inv) => inv.item.id == itemId);

    if (existingIndex < 0) {
      return false; // アイテムが見つからない
    }

    final existing = state[existingIndex];
    if (existing.quantity < quantity) {
      return false; // 数量不足
    }

    final newQuantity = existing.quantity - quantity;
    if (newQuantity == 0) {
      // 数量がゼロになったらアイテムを削除
      state = [
        ...state.sublist(0, existingIndex),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // 数量を更新
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(quantity: newQuantity),
        ...state.sublist(existingIndex + 1),
      ];
    }
    await _saveInventory();
    return true;
  }

  /// アイテムの数量を取得
  int getItemQuantity(String itemId) {
    try {
      return state.firstWhere((inv) => inv.item.id == itemId).quantity;
    } catch (e) {
      return 0;
    }
  }

  /// アイテムを保有しているか確認
  bool hasItem(String itemId) {
    return getItemQuantity(itemId) > 0;
  }

  /// インベントリをクリア（テスト用）
  Future<void> clear() async {
    state = [];
    await _saveInventory();
  }

  /// 特定カテゴリのアイテムを取得
  List<InventoryItem> getItemsByCategory(String category) {
    return state.where((inv) => inv.item.category == category).toList();
  }

  /// タイプごとのアイテムを取得
  List<InventoryItem> getItemsByType(ItemType type) {
    return state.where((inv) => inv.item.type == type).toList();
  }
}

/// インベントリの統計情報
final inventoryStatsProvider = Provider<InventoryStats>((ref) {
  final inventory = ref.watch(inventoryProvider);
  return InventoryStats(
    totalItems: inventory.fold<int>(0, (sum, item) => sum + item.quantity),
    uniqueItems: inventory.length,
    consumables: inventory.where((i) => i.item.type == ItemType.consumable).length,
    equipment: inventory.where((i) => i.item.type == ItemType.equipment).length,
    collectibles: inventory.where((i) => i.item.type == ItemType.collectible).length,
  );
});

class InventoryStats {
  final int totalItems;
  final int uniqueItems;
  final int consumables;
  final int equipment;
  final int collectibles;

  InventoryStats({
    required this.totalItems,
    required this.uniqueItems,
    required this.consumables,
    required this.equipment,
    required this.collectibles,
  });
}
