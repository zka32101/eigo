import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ad_model.dart';

final adPlacementsProvider = StateNotifierProvider<AdPlacementsNotifier, List<AdPlacement>>((ref) {
  return AdPlacementsNotifier();
});

class AdPlacementsNotifier extends StateNotifier<List<AdPlacement>> {
  static const String _storageKey = 'eigo_kore_ad_placements';

  AdPlacementsNotifier() : super(defaultAdPlacements) {
    _loadPlacements();
  }

  /// 広告配置をロード
  Future<void> _loadPlacements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items =
            decoded.map((json) => AdPlacement.fromJson(json as Map<String, dynamic>)).toList();
        state = items;
      } catch (e) {
        print('Error loading ad placements: $e');
        state = defaultAdPlacements;
      }
    }
  }

  /// 広告配置を保存
  Future<void> _savePlacements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// 広告を有効化
  Future<void> enableAd(String adId) async {
    final index = state.indexWhere((ad) => ad.id == adId);
    if (index >= 0) {
      final ad = state[index];
      state = [
        ...state.sublist(0, index),
        AdPlacement(
          id: ad.id,
          adUnitId: ad.adUnitId,
          placement: ad.placement,
          adType: ad.adType,
          isActive: true,
        ),
        ...state.sublist(index + 1),
      ];
      await _savePlacements();
    }
  }

  /// 広告を無効化
  Future<void> disableAd(String adId) async {
    final index = state.indexWhere((ad) => ad.id == adId);
    if (index >= 0) {
      final ad = state[index];
      state = [
        ...state.sublist(0, index),
        AdPlacement(
          id: ad.id,
          adUnitId: ad.adUnitId,
          placement: ad.placement,
          adType: ad.adType,
          isActive: false,
        ),
        ...state.sublist(index + 1),
      ];
      await _savePlacements();
    }
  }

  /// 特定の配置アクティブな広告を取得
  List<AdPlacement> getActiveAdsByPlacement(String placement) {
    return state.where((ad) => ad.placement == placement && ad.isActive).toList();
  }

  /// 広告タイプで取得
  List<AdPlacement> getAdsByType(String adType) {
    return state.where((ad) => ad.adType == adType && ad.isActive).toList();
  }
}

/// 広告表示制限を管理
final adLimitsProvider =
    StateNotifierProvider<AdLimitsNotifier, AdLimits>((ref) {
  return AdLimitsNotifier();
});

class AdLimitsNotifier extends StateNotifier<AdLimits> {
  static const String _storageKey = 'eigo_kore_ad_limits';

  AdLimitsNotifier() : super(const AdLimits()) {
    _loadLimits();
  }

  /// 制限をロード
  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = AdLimits.fromJson(json);
      } catch (e) {
        print('Error loading ad limits: $e');
      }
    }
  }

  /// 制限を保存
  Future<void> _saveLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 制限を更新
  Future<void> updateLimits(AdLimits limits) async {
    state = limits;
    await _saveLimits();
  }
}

/// 広告表示履歴を管理
final adHistoryProvider =
    StateNotifierProvider<AdHistoryNotifier, List<AdViewRecord>>((ref) {
  return AdHistoryNotifier();
});

class AdHistoryNotifier extends StateNotifier<List<AdViewRecord>> {
  static const String _storageKey = 'eigo_kore_ad_history';

  AdHistoryNotifier() : super([]) {
    _loadHistory();
  }

  /// 履歴をロード
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items =
            decoded.map((json) => AdViewRecord.fromJson(json as Map<String, dynamic>)).toList();
        state = items;
      } catch (e) {
        print('Error loading ad history: $e');
      }
    }
  }

  /// 履歴を保存
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// 広告表示を記録
  Future<void> recordAdView(
    String adUnitId, {
    bool wasRewarded = false,
    AdReward? reward,
  }) async {
    state = [
      ...state,
      AdViewRecord(
        adUnitId: adUnitId,
        viewedAt: DateTime.now(),
        wasRewarded: wasRewarded,
        reward: reward,
      ),
    ];
    await _saveHistory();
  }

  /// 本日の広告表示回数を取得
  int getTodayAdCount() {
    final today = DateTime.now();
    return state.where((record) {
      return record.viewedAt.year == today.year &&
          record.viewedAt.month == today.month &&
          record.viewedAt.day == today.day;
    }).length;
  }

  /// 特定の配置の本日の表示回数
  int getTodayCountForPlacement(String placement, List<AdPlacement> placements) {
    final adUnitIds = placements
        .where((ad) => ad.placement == placement)
        .map((ad) => ad.adUnitId)
        .toSet();

    final today = DateTime.now();
    return state.where((record) {
      return adUnitIds.contains(record.adUnitId) &&
          record.viewedAt.year == today.year &&
          record.viewedAt.month == today.month &&
          record.viewedAt.day == today.day;
    }).length;
  }

  /// 履歴をクリア
  Future<void> clear() async {
    state = [];
    await _saveHistory();
  }
}

/// 広告が表示可能かチェック
final canShowAdProvider =
    Provider.family<bool, String>((ref, placement) {
  final limits = ref.watch(adLimitsProvider);
  final historyNotifier = ref.read(adHistoryProvider.notifier);
  final placements = ref.watch(adPlacementsProvider);

  // この配置にアクティブな広告があるか
  final hasActiveAds =
      placements.any((ad) => ad.placement == placement && ad.isActive);
  if (!hasActiveAds) return false;

  // 1日の最大数に達していないか
  if (historyNotifier.getTodayAdCount() >= limits.maxDailyAds) return false;

  // この配置の最大表示回数に達していないか
  if (historyNotifier.getTodayCountForPlacement(placement, placements) >=
      limits.maxAdsPerPlacement) return false;

  return true;
});

/// 報酬広告の報酬を取得
final rewardedAdRewardProvider =
    Provider.family<AdReward?, String>((ref, rewardType) {
  return rewardedAdRewards[rewardType];
});
