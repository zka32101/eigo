import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_model.dart';
import '../providers/ad_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class AdSettingsScreen extends ConsumerWidget {
  const AdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placements = ref.watch(adPlacementsProvider);
    final limits = ref.watch(adLimitsProvider);
    final history = ref.watch(adHistoryProvider);

    final todayAdCount = history.getTodayAdCount();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📺 広告設定'),
          backgroundColor: kPrimaryColor,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: '広告配置'),
              Tab(text: '制限設定'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 広告配置タブ
            _AdPlacementsTab(placements: placements),
            // 制限設定タブ
            _AdLimitsTab(limits: limits, todayCount: todayAdCount),
          ],
        ),
      ),
    );
  }
}

class _AdPlacementsTab extends ConsumerWidget {
  final List<AdPlacement> placements;

  const _AdPlacementsTab({required this.placements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedByPlacement = <String, List<AdPlacement>>{};
    for (var placement in placements) {
      groupedByPlacement.putIfAbsent(placement.placement, () => []).add(placement);
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('広告配置管理', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerSm,
          Text('各広告配置を有効/無効に設定できます', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
          AppSpacing.verticalSpacerLg,
          ...groupedByPlacement.entries.expand((entry) {
            final placement = entry.key;
            final ads = entry.value;
            final placementLabels = {
              'home': 'ホーム画面',
              'lesson': 'レッスン画面',
              'result': '結果画面',
              'shop': 'ショップ画面',
            };

            return [
              Container(
                padding: AppSpacing.allPaddingMd,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Text(
                  placementLabels[placement] ?? placement,
                  style: AppTypography.labelLarge.copyWith(color: kPrimaryColor),
                ),
              ),
              AppSpacing.verticalSpacerMd,
              ...ads.map((ad) {
                return Column(
                  children: [
                    _AdPlacementCard(ad: ad),
                    AppSpacing.verticalSpacerMd,
                  ],
                );
              }).toList(),
              AppSpacing.verticalSpacerLg,
            ];
          }).toList(),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _AdPlacementCard extends ConsumerWidget {
  final AdPlacement ad;

  const _AdPlacementCard({required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAdTypeLabel(ad.adType),
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  'Unit ID: ${ad.adUnitId.substring(0, 20)}...',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: ad.isActive,
            onChanged: (value) {
              if (value) {
                ref.read(adPlacementsProvider.notifier).enableAd(ad.id);
              } else {
                ref.read(adPlacementsProvider.notifier).disableAd(ad.id);
              }
            },
            activeColor: kAccentGreen,
          ),
        ],
      ),
    );
  }

  String _getAdTypeLabel(String type) {
    switch (type) {
      case 'banner':
        return 'バナー広告';
      case 'interstitial':
        return 'インタースティシャル広告';
      case 'rewarded':
        return 'リワード広告';
      default:
        return type;
    }
  }
}

class _AdLimitsTab extends ConsumerStatefulWidget {
  final AdLimits limits;
  final int todayCount;

  const _AdLimitsTab({
    required this.limits,
    required this.todayCount,
  });

  @override
  ConsumerState<_AdLimitsTab> createState() => _AdLimitsTabState();
}

class _AdLimitsTabState extends ConsumerState<_AdLimitsTab> {
  late int maxDailyAds;
  late int maxAdsPerPlacement;
  late int minInterval;

  @override
  void initState() {
    super.initState();
    maxDailyAds = widget.limits.maxDailyAds;
    maxAdsPerPlacement = widget.limits.maxAdsPerPlacement;
    minInterval = widget.limits.minIntervalBetweenAds.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('広告表示制限', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerLg,

          // 本日の表示回数
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: kAccentGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: kAccentGreen.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('本日の広告表示回数', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      '$widget.todayCount / ${widget.limits.maxDailyAds}',
                      style: AppTypography.headlineMedium.copyWith(color: kAccentGreen),
                    ),
                  ],
                ),
                Container(
                  padding: AppSpacing.allPaddingMd,
                  decoration: BoxDecoration(
                    color: kAccentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${((widget.todayCount / widget.limits.maxDailyAds) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 制限設定
          Text('設定項目', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
          AppSpacing.verticalSpacerMd,

          // 1日の最大広告数
          _LimitSettingCard(
            label: '1日の最大広告表示回数',
            value: maxDailyAds,
            min: 1,
            max: 20,
            onChanged: (value) {
              setState(() => maxDailyAds = value);
            },
          ),
          AppSpacing.verticalSpacerMd,

          // 1つの場所での最大表示回数
          _LimitSettingCard(
            label: '1つの場所での最大表示回数',
            value: maxAdsPerPlacement,
            min: 1,
            max: 10,
            onChanged: (value) {
              setState(() => maxAdsPerPlacement = value);
            },
          ),
          AppSpacing.verticalSpacerMd,

          // 最小表示間隔
          _LimitSettingCard(
            label: '最小表示間隔（分）',
            value: minInterval,
            min: 1,
            max: 60,
            onChanged: (value) {
              setState(() => minInterval = value);
            },
          ),
          AppSpacing.verticalSpacerLg,

          // 保存ボタン
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              onPressed: () {
                ref.read(adLimitsProvider.notifier).updateLimits(
                  AdLimits(
                    maxDailyAds: maxDailyAds,
                    maxAdsPerPlacement: maxAdsPerPlacement,
                    minIntervalBetweenAds: Duration(minutes: minInterval),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('設定を保存しました'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                '設定を保存',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _LimitSettingCard extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _LimitSettingCard({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
          AppSpacing.verticalSpacerMd,
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: (max - min),
                  onChanged: (newValue) {
                    onChanged(newValue.toInt());
                  },
                  activeColor: kPrimaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '$value',
                  style: AppTypography.labelLarge.copyWith(color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
