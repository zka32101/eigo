import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/promotion_model.dart';
import '../providers/promotion_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class PromotionScreen extends ConsumerStatefulWidget {
  const PromotionScreen({super.key});

  @override
  ConsumerState<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends ConsumerState<PromotionScreen> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に全キャンペーンの表示回数を記録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaigns = ref.read(promotionalCampaignsProvider);
      for (var campaign in campaigns) {
        ref.read(promotionalCampaignsProvider.notifier).incrementViewCount(campaign.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(campaignStatsProvider);
    final campaigns = ref.watch(promotionalCampaignsProvider);
    final activeCampaigns = campaigns.where((c) => c.isActive && !c.isExpired).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📢 おすすめアプリ'),
          backgroundColor: kPrimaryColor,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: [
              Tab(text: 'キャンペーン'),
              Tab(text: '統計'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // キャンペーン一覧
            _CampaignsListView(campaigns: activeCampaigns),
            // 統計情報
            _StatsView(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _CampaignsListView extends ConsumerWidget {
  final List<PromotionalCampaign> campaigns;

  const _CampaignsListView({required this.campaigns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign_outlined, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('現在のキャンペーンはありません'),
          ],
        ),
      );
    }

    // フィーチャーキャンペーンと通常キャンペーンを分ける
    final featured = campaigns.where((c) => c.isFeatured).toList();
    final regular = campaigns.where((c) => !c.isFeatured).toList();

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // フィーチャーキャンペーン
          if (featured.isNotEmpty) ...[
            Text('ピックアップ', style: AppTypography.headlineSmall),
            AppSpacing.verticalSpacerMd,
            ...featured.map((campaign) {
              return Column(
                children: [
                  _PromotionCard(campaign: campaign),
                  AppSpacing.verticalSpacerMd,
                ],
              );
            }).toList(),
            AppSpacing.verticalSpacerLg,
          ],

          // 通常キャンペーン
          if (regular.isNotEmpty) ...[
            Text('その他のおすすめ', style: AppTypography.headlineSmall),
            AppSpacing.verticalSpacerMd,
            ...regular.map((campaign) {
              return Column(
                children: [
                  _PromotionCard(campaign: campaign),
                  AppSpacing.verticalSpacerMd,
                ],
              );
            }).toList(),
          ],

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _PromotionCard extends ConsumerWidget {
  final PromotionalCampaign campaign;

  const _PromotionCard({required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryLabel = _getCategoryLabel(campaign.category);
    final categoryColor = _getCategoryColor(campaign.category);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLarge)),
          ),
          builder: (context) => _PromotionDetailSheet(campaign: campaign),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // キャンペーンイメージ
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(30),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadiusLarge),
                  topRight: Radius.circular(AppSizes.borderRadiusLarge),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      campaign.imageUrl,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      child: Text(
                        categoryLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (campaign.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: kAccentOrange,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐ ', style: TextStyle(fontSize: 12)),
                            Text(
                              'ピック',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // キャンペーン情報
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    campaign.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${campaign.promotedApp}',
                        style: AppTypography.labelSmall,
                      ),
                      if (campaign.endDate != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentRed.withAlpha(20),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                          ),
                          child: Text(
                            '終了まであと${campaign.endDate!.difference(DateTime.now()).inDays}日',
                            style: AppTypography.bodySmall.copyWith(
                              color: kAccentRed,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'new_app':
        return '新作';
      case 'limited_time':
        return '期間限定';
      case 'seasonal':
        return 'シーズン';
      case 'exclusive':
        return '限定';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'new_app':
        return kAccentGreen;
      case 'limited_time':
        return kAccentRed;
      case 'seasonal':
        return kAccentOrange;
      case 'exclusive':
        return kPrimaryColor;
      default:
        return Colors.grey;
    }
  }
}

class _PromotionDetailSheet extends ConsumerWidget {
  final PromotionalCampaign campaign;

  const _PromotionDetailSheet({required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: AppSpacing.allPaddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: _getCategoryColor(campaign.category).withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                ),
                child: Center(
                  child: Text(campaign.imageUrl, style: const TextStyle(fontSize: 80)),
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // タイトルと説明
              Text(campaign.title, style: AppTypography.headlineMedium),
              AppSpacing.verticalSpacerMd,
              Text(campaign.description, style: AppTypography.bodyMedium),
              AppSpacing.verticalSpacerLg,

              // キャンペーン情報
              Container(
                padding: AppSpacing.allPaddingMd,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('アプリ名', campaign.promotedApp),
                    AppSpacing.verticalSpacerMd,
                    _InfoRow('カテゴリ', _getCategoryLabel(campaign.category)),
                    AppSpacing.verticalSpacerMd,
                    if (campaign.endDate != null)
                      _InfoRow(
                        '期限',
                        'あと${campaign.endDate!.difference(DateTime.now()).inDays}日',
                      ),
                  ],
                ),
              ),
              AppSpacing.verticalSpacerLg,

              // ダウンロードボタン
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(campaign.appStoreUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      icon: const Icon(Icons.apple),
                      label: const Text('App Store'),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(campaign.playStoreUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      icon: const Icon(Icons.android),
                      label: const Text('Google Play'),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        );
      },
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'new_app':
        return '新作';
      case 'limited_time':
        return '期間限定';
      case 'seasonal':
        return 'シーズン';
      case 'exclusive':
        return '限定';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'new_app':
        return kAccentGreen;
      case 'limited_time':
        return kAccentRed;
      case 'seasonal':
        return kAccentOrange;
      case 'exclusive':
        return kPrimaryColor;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Failed to launch URL: $e');
    }
  }
}

class _StatsView extends ConsumerWidget {
  final CampaignStats stats;

  const _StatsView({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('キャンペーン統計', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerLg,

          // 統計カード
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                label: '総キャンペーン',
                value: '${stats.totalCampaigns}',
                icon: '📋',
                color: kPrimaryColor,
              ),
              _StatCard(
                label: 'アクティブ',
                value: '${stats.activeCampaigns}',
                icon: '✨',
                color: kAccentGreen,
              ),
              _StatCard(
                label: '総表示数',
                value: '${stats.totalViews}',
                icon: '👁️',
                color: kAccentOrange,
              ),
              _StatCard(
                label: '総クリック',
                value: '${stats.totalClicks}',
                icon: '👆',
                color: kAccentRed,
              ),
            ],
          ),
          AppSpacing.verticalSpacerLg,

          // CTR
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: kPrimaryColor.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('📊', style: TextStyle(fontSize: 28)),
                ),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('平均クリック率', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        '${stats.averageCTR.toStringAsFixed(2)}%',
                        style: AppTypography.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
              AppSpacing.verticalSpacerXs,
              Text(value, style: AppTypography.headlineSmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
        Text(value, style: AppTypography.labelSmall),
      ],
    );
  }
}
