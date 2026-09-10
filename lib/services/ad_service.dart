import 'dart:io' show Platform;

import '../models/ad_model.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// AdMobを初期化（Stub - no-op）
  Future<void> initialize() async {
    _isInitialized = true;
    print('AdService stub initialized (AdMob integration disabled)');
  }

  /// Stub methods to prevent build errors
  void createBannerAd(String adUnitId, {dynamic size}) {}
  void loadInterstitialAd(String adUnitId) {}
  void loadRewardedAd(String adUnitId) {}
  void showInterstitialAd(String adUnitId) {}
  void showRewardedAd(String adUnitId) {}
}
