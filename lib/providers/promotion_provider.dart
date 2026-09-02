import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/promotion_model.dart';
import '../services/logger_service.dart';

final promotionalCampaignsProvider =
    StateNotifierProvider<PromotionalCampaignsNotifier, List<PromotionalCampaign>>((ref) {
  return PromotionalCampaignsNotifier();
});

class PromotionalCampaignsNotifier extends StateNotifier<List<PromotionalCampaign>> {
  static const String _storageKey = 'eigo_kore_promotions';

  PromotionalCampaignsNotifier() : super(defaultPromotionalCampaigns) {
    _loadCampaigns();
  }

  /// キャンペーンをロード
  Future<void> _loadCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final campaigns = decoded
            .map((json) => PromotionalCampaign.fromJson(json as Map<String, dynamic>))
            .toList();
        state = campaigns;
      } catch (e) {
        LoggerService.error('Error loading promotional campaigns', tag: 'PromotionalCampaignsNotifier', exception: e);
        state = defaultPromotionalCampaigns;
      }
    }
  }

  /// キャンペーンを保存
  Future<void> _saveCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// キャンペーンを追加
  Future<void> addCampaign(PromotionalCampaign campaign) async {
    state = [...state, campaign];
    await _saveCampaigns();
  }

  /// キャンペーンを更新
  Future<void> updateCampaign(PromotionalCampaign campaign) async {
    final index = state.indexWhere((c) => c.id == campaign.id);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        campaign,
        ...state.sublist(index + 1),
      ];
      await _saveCampaigns();
    }
  }

  /// キャンペーンを削除
  Future<void> removeCampaign(String campaignId) async {
    state = state.where((c) => c.id != campaignId).toList();
    await _saveCampaigns();
  }

  /// キャンペーンを有効化
  Future<void> enableCampaign(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(isActive: true));
    }
  }

  /// キャンペーンを無効化
  Future<void> disableCampaign(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(isActive: false));
    }
  }

  /// キャンペーンをフィーチャー
  Future<void> featureCampaign(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(isFeatured: true));
    }
  }

  /// キャンペーンをアンフィーチャー
  Future<void> unfeatureCampaign(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(isFeatured: false));
    }
  }

  /// 表示回数をインクリメント
  Future<void> incrementViewCount(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(viewCount: campaign.viewCount + 1));
    }
  }

  /// クリック回数をインクリメント
  Future<void> incrementClickCount(String campaignId) async {
    final index = state.indexWhere((c) => c.id == campaignId);
    if (index >= 0) {
      final campaign = state[index];
      await updateCampaign(campaign.copyWith(clickCount: campaign.clickCount + 1));
    }
  }

  /// アクティブなキャンペーンを取得
  List<PromotionalCampaign> getActiveCampaigns() {
    return state.where((c) => c.isActive && !c.isExpired).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// フィーチャーキャンペーンを取得
  List<PromotionalCampaign> getFeaturedCampaigns() {
    return getActiveCampaigns().where((c) => c.isFeatured).toList();
  }

  /// カテゴリ別にキャンペーンを取得
  List<PromotionalCampaign> getCampaignsByCategory(String category) {
    return getActiveCampaigns().where((c) => c.category == category).toList();
  }
}

/// プロモーション相互作用を管理
final promotionInteractionProvider =
    StateNotifierProvider<PromotionInteractionNotifier, List<PromotionInteraction>>((ref) {
  return PromotionInteractionNotifier();
});

class PromotionInteractionNotifier extends StateNotifier<List<PromotionInteraction>> {
  static const String _storageKey = 'eigo_kore_promotion_interactions';

  PromotionInteractionNotifier() : super([]) {
    _loadInteractions();
  }

  /// 相互作用をロード
  Future<void> _loadInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final interactions = decoded
            .map((json) => PromotionInteraction.fromJson(json as Map<String, dynamic>))
            .toList();
        state = interactions;
      } catch (e) {
        LoggerService.error('Error loading promotion interactions', tag: 'PromotionInteractionNotifier', exception: e);
      }
    }
  }

  /// 相互作用を保存
  Future<void> _saveInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// 相互作用を記録
  Future<void> recordInteraction({
    required String campaignId,
    required String campaignTitle,
    required String interactionType,
    bool completedAction = false,
  }) async {
    state = [
      ...state,
      PromotionInteraction(
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        interactedAt: DateTime.now(),
        interactionType: interactionType,
        completedAction: completedAction,
      ),
    ];
    await _saveInteractions();
  }

  /// 特定のキャンペーンの相互作用を取得
  List<PromotionInteraction> getInteractionsForCampaign(String campaignId) {
    return state.where((i) => i.campaignId == campaignId).toList();
  }

  /// 相互作用の統計を取得
  Map<String, int> getInteractionStats() {
    final stats = <String, int>{};
    for (var interaction in state) {
      stats[interaction.interactionType] = (stats[interaction.interactionType] ?? 0) + 1;
    }
    return stats;
  }

  /// 相互作用をクリア
  Future<void> clear() async {
    state = [];
    await _saveInteractions();
  }
}

/// キャンペーンの統計情報
final campaignStatsProvider =
    Provider<CampaignStats>((ref) {
  final campaigns = ref.watch(promotionalCampaignsProvider);
  final activeCampaigns = campaigns.where((c) => c.isActive && !c.isExpired).length;
  final totalViews = campaigns.fold<int>(0, (sum, c) => sum + c.viewCount);
  final totalClicks = campaigns.fold<int>(0, (sum, c) => sum + c.clickCount);
  final avgCTR = campaigns.isEmpty
      ? 0.0
      : (campaigns.fold<double>(0, (sum, c) => sum + c.clickThroughRate) / campaigns.length);

  return CampaignStats(
    totalCampaigns: campaigns.length,
    activeCampaigns: activeCampaigns,
    totalViews: totalViews,
    totalClicks: totalClicks,
    averageCTR: avgCTR,
  );
});

class CampaignStats {
  final int totalCampaigns;
  final int activeCampaigns;
  final int totalViews;
  final int totalClicks;
  final double averageCTR;

  CampaignStats({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalViews,
    required this.totalClicks,
    required this.averageCTR,
  });
}
