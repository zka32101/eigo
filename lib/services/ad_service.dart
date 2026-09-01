import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/ad_model.dart';

/// Google Mobile Ads Service
/// AdMobの初期化と広告の読み込み・表示を管理
class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  bool _isInitialized = false;
  final Map<String, BannerAd> _bannerAds = {};
  final Map<String, InterstitialAd?> _interstitialAds = {};
  final Map<String, RewardedAd?> _rewardedAds = {};

  bool get isInitialized => _isInitialized;

  /// AdMobを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdService initialized successfully');
    } catch (e) {
      print('AdService initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// バナー広告を作成
  BannerAd createBannerAd(
    String adUnitId, {
    required AdSize size,
    VoidCallback? onAdLoaded,
    FullScreenAdLoadErrorListener? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Banner ad loaded: $adUnitId');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          onAdFailedToLoad?.call(ad, error);
          ad.dispose();
        },
      ),
    );
  }

  /// インタースティシャル広告を読み込み
  Future<void> loadInterstitialAd(
    String adUnitId, {
    VoidCallback? onAdLoaded,
    FullScreenAdLoadErrorListener? onAdFailedToLoad,
  }) async {
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAds[adUnitId] = ad;
          print('Interstitial ad loaded: $adUnitId');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAds[adUnitId] = null;
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// インタースティシャル広告を表示
  Future<void> showInterstitialAd(String adUnitId) async {
    final ad = _interstitialAds[adUnitId];
    if (ad != null) {
      try {
        await ad.show();
        _interstitialAds[adUnitId] = null; // 表示後は削除
      } catch (e) {
        print('Failed to show interstitial ad: $e');
      }
    }
  }

  /// リワード広告を読み込み
  Future<void> loadRewardedAd(
    String adUnitId, {
    VoidCallback? onAdLoaded,
    FullScreenAdLoadErrorListener? onAdFailedToLoad,
  }) async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAds[adUnitId] = ad;
          print('Rewarded ad loaded: $adUnitId');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          _rewardedAds[adUnitId] = null;
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// リワード広告を表示
  Future<bool> showRewardedAd(
    String adUnitId, {
    OnUserEarnedRewardListener? onUserEarnedReward,
  }) async {
    final ad = _rewardedAds[adUnitId];
    if (ad != null) {
      try {
        await ad.show(onUserEarnedReward: onUserEarnedReward);
        _rewardedAds[adUnitId] = null; // 表示後は削除
        return true;
      } catch (e) {
        print('Failed to show rewarded ad: $e');
        return false;
      }
    }
    return false;
  }

  /// バナー広告を取得
  BannerAd? getBannerAd(String adUnitId) {
    return _bannerAds[adUnitId];
  }

  /// バナー広告を登録
  void registerBannerAd(String adUnitId, BannerAd ad) {
    _bannerAds[adUnitId] = ad;
  }

  /// 広告を破棄
  void disposeBannerAd(String adUnitId) {
    _bannerAds[adUnitId]?.dispose();
    _bannerAds.remove(adUnitId);
  }

  /// インタースティシャル広告を破棄
  void disposeInterstitialAd(String adUnitId) {
    _interstitialAds[adUnitId]?.dispose();
    _interstitialAds.remove(adUnitId);
  }

  /// リワード広告を破棄
  void disposeRewardedAd(String adUnitId) {
    _rewardedAds[adUnitId]?.dispose();
    _rewardedAds.remove(adUnitId);
  }

  /// すべての広告を破棄
  void disposeAll() {
    for (var ad in _bannerAds.values) {
      ad.dispose();
    }
    for (var ad in _interstitialAds.values) {
      ad?.dispose();
    }
    for (var ad in _rewardedAds.values) {
      ad?.dispose();
    }
    _bannerAds.clear();
    _interstitialAds.clear();
    _rewardedAds.clear();
  }

  /// テスト用デバイスを追加
  static void addTestDevice(String deviceId) {
    RequestConfiguration requestConfiguration = RequestConfiguration(
      keywords: <String>['test'],
      contentUrl: 'https://developer.google.com',
    );
    MobileAds.instance.setRequestConfiguration(requestConfiguration);
  }
}

/// ダミーAdオブジェクト（エラー時の型安全性のため）
class _DummyAd implements Ad {
  @override
  Future<void> dispose() async {}

  @override
  String? get responseInfo => null;
}

/// AdMob広告の配置マネージャー
class AdPlacementManager {
  final AdService _adService;
  final List<AdPlacement> placements;

  AdPlacementManager({
    required this.placements,
  }) : _adService = AdService();

  /// 広告を初期化（起動時）
  Future<void> initializeAds() async {
    // バナー広告を事前読み込み
    final bannerAds = placements.where((ad) => ad.adType == 'banner' && ad.isActive);
    for (var ad in bannerAds) {
      _adService.createBannerAd(
        ad.adUnitId,
        size: AdSize.banner,
      );
    }

    // インタースティシャル広告を読み込み
    final interstitialAds =
        placements.where((ad) => ad.adType == 'interstitial' && ad.isActive);
    for (var ad in interstitialAds) {
      await _adService.loadInterstitialAd(ad.adUnitId);
    }

    // リワード広告を読み込み
    final rewardedAds = placements.where((ad) => ad.adType == 'rewarded' && ad.isActive);
    for (var ad in rewardedAds) {
      await _adService.loadRewardedAd(ad.adUnitId);
    }
  }

  /// 配置で広告を表示
  Future<void> showAdForPlacement(
    String placement, {
    OnUserEarnedRewardListener? onUserEarnedReward,
  }) async {
    final adsForPlacement = placements.where(
      (ad) => ad.placement == placement && ad.isActive,
    );

    for (var ad in adsForPlacement) {
      if (ad.adType == 'interstitial') {
        await _adService.showInterstitialAd(ad.adUnitId);
        break;
      } else if (ad.adType == 'rewarded') {
        await _adService.showRewardedAd(
          ad.adUnitId,
          onUserEarnedReward: onUserEarnedReward,
        );
        break;
      }
    }
  }

  /// クリーンアップ
  void cleanup() {
    _adService.disposeAll();
  }
}
