import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_model.dart';
import '../providers/purchase_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/product_card.dart';
import '../design_system/design_system.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['コイン', 'ブースター', 'サブスク', 'パッケージ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ ショップ'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Coins tab
          _CoinsTab(userId: userId),
          // Boosters tab
          _BoostersTab(userId: userId),
          // Subscriptions tab
          _SubscriptionsTab(userId: userId),
          // Packages tab
          _PackagesTab(userId: userId),
        ],
      ),
    );
  }
}

// Coins Tab
class _CoinsTab extends ConsumerWidget {
  final String userId;

  const _CoinsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productsByTypeProvider(ProductType.consumable));

    return productsAsync.when(
      data: (products) {
        final coins = products.where((p) => p.tags.contains('coins')).toList();
        if (coins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🪙',
                  style: TextStyle(fontSize: 64),
                ),
                AppSpacing.verticalSpacerMd,
                const Text('コイン商品がありません'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: coins.length,
          itemBuilder: (context, index) {
            final product = coins[index];
            return ProductCard(
              product: product,
              onTap: () => _handlePurchase(context, ref, product, userId),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラー: $error')),
    );
  }

  void _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    Product product,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            AppSpacing.verticalSpacerMd,
            if (product.rewardCoins != null)
              Text('獲得コイン: ${product.rewardCoins}🪙'),
            if (product.rewardXp != null)
              Text('獲得XP: ${product.rewardXp}⭐'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title}を購入しました！'),
                ),
              );
            },
            child: Text('${product.displayPrice}で購入'),
          ),
        ],
      ),
    );
  }
}

// Boosters Tab
class _BoostersTab extends ConsumerWidget {
  final String userId;

  const _BoostersTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productsByTypeProvider(ProductType.nonConsumable));

    return productsAsync.when(
      data: (products) {
        final boosters =
            products.where((p) => p.tags.contains('booster')).toList();
        if (boosters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⚡',
                  style: TextStyle(fontSize: 64),
                ),
                AppSpacing.verticalSpacerMd,
                const Text('ブースター商品がありません'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: boosters.length,
          itemBuilder: (context, index) {
            final product = boosters[index];
            return ProductCard(
              product: product,
              onTap: () => _handlePurchase(context, ref, product, userId),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラー: $error')),
    );
  }

  void _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    Product product,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.title),
        content: Text(product.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title}を購入しました！'),
                ),
              );
            },
            child: Text('${product.displayPrice}で購入'),
          ),
        ],
      ),
    );
  }
}

// Subscriptions Tab
class _SubscriptionsTab extends ConsumerWidget {
  final String userId;

  const _SubscriptionsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎯',
                  style: TextStyle(fontSize: 64),
                ),
                AppSpacing.verticalSpacerMd,
                const Text('サブスクリプションプランがありません'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _SubscriptionCard(
              plan: plan,
              onTap: () => _handleSubscription(context, plan),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラー: $error')),
    );
  }

  void _handleSubscription(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.description),
            AppSpacing.verticalSpacerMd,
            if (plan.benefits != null) ...[
              const Text(
                '特典:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(plan.benefits!),
              AppSpacing.verticalSpacerMd,
            ],
            Text('${plan.periodLabel}: ${plan.displayPrice}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plan.title}を開始しました！'),
                ),
              );
            },
            child: Text('${plan.displayPrice}で開始'),
          ),
        ],
      ),
    );
  }
}

// Packages Tab
class _PackagesTab extends ConsumerWidget {
  final String userId;

  const _PackagesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(featuredPackagesProvider);

    return packagesAsync.when(
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '📦',
                  style: TextStyle(fontSize: 64),
                ),
                AppSpacing.verticalSpacerMd,
                const Text('パッケージがありません'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return _PackageCard(
              package: package,
              onTap: () => _handlePackage(context, package),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラー: $error')),
    );
  }

  void _handlePackage(BuildContext context, PurchasePackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(package.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(package.description),
              AppSpacing.verticalSpacerMd,
              const Text(
                '含まれる商品:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...package.products.map((p) => Text('  • ${p.title}')),
              AppSpacing.verticalSpacerMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '通常: ¥${package.totalValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${package.discountPercentage}% OFF',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${package.title}を購入しました！'),
                ),
              );
            },
            child: Text('¥${package.discountedPrice.toStringAsFixed(0)}で購入'),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      color: plan.isMostPopular ? AppColors.primary.withOpacity(0.05) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.title,
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (plan.isMostPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '人気',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                plan.description,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
              AppSpacing.verticalSpacerMd,
              Text(
                '${plan.periodLabel}: ${plan.displayPrice}',
                style: AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              if (plan.discountPercentage != null &&
                  plan.discountPercentage! > 0)
                Text(
                  '${plan.discountPercentage}% 割引！',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PurchasePackage package;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          style: AppTypography.bodyLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.verticalSpacerSm,
                        Text(
                          package.description,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${package.discountPercentage}%\nOFF',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${package.totalValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '¥${package.discountedPrice.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '詳細',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
