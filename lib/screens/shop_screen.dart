import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../providers/inventory_provider.dart';
import '../providers/coin_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final coins = ref.watch(coinProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🛍️ ショップ'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: const [
              Tab(text: 'ポーション'),
              Tab(text: 'ブースト'),
              Tab(text: 'アクセサリ'),
              Tab(text: 'コレクション'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ShopCategoryView(
              items: catalogItems
                  .where((i) => i.category == 'ポーション')
                  .toList(),
              coins: coins.totalCoins,
              inventory: inventory,
              ref: ref,
            ),
            _ShopCategoryView(
              items: catalogItems
                  .where((i) => i.category == 'ブースト')
                  .toList(),
              coins: coins.totalCoins,
              inventory: inventory,
              ref: ref,
            ),
            _ShopCategoryView(
              items: catalogItems
                  .where((i) => i.category == 'アクセサリ')
                  .toList(),
              coins: coins.totalCoins,
              inventory: inventory,
              ref: ref,
            ),
            _ShopCategoryView(
              items: catalogItems
                  .where((i) => i.category == 'コレクション')
                  .toList(),
              coins: coins.totalCoins,
              inventory: inventory,
              ref: ref,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCategoryView extends ConsumerWidget {
  final List<Item> items;
  final int coins;
  final List<InventoryItem> inventory;
  final WidgetRef ref;

  const _ShopCategoryView({
    required this.items,
    required this.coins,
    required this.inventory,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('このカテゴリにはアイテムがありません'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // コイン残高表示
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentOrange.withAlpha(20), kAccentOrange.withAlpha(5)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 32)),
                AppSpacing.horizontalSpacerMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('保有コイン', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
                    Text('$coins 🪙', style: AppTypography.labelLarge),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // アイテムグリッド
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final inventoryItem = inventory.firstWhere(
                (inv) => inv.item.id == item.id,
                orElse: () => InventoryItem(
                  item: item,
                  quantity: 0,
                  acquiredAt: DateTime.now(),
                ),
              );

              return _ShopItemCard(
                item: item,
                owned: inventoryItem.quantity,
                coins: coins,
                onPurchase: () => _purchaseItem(context, item, ref),
              );
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  Future<void> _purchaseItem(BuildContext context, Item item, WidgetRef ref) async {
    if (coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コインが不足しています')),
      );
      return;
    }

    // コイン消費
    await ref.read(coinProvider.notifier).spend(item.price);

    // インベントリに追加
    await ref.read(inventoryProvider.notifier).addItem(item);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name}を購入しました！'),
          backgroundColor: kAccentGreen,
        ),
      );
    }
  }
}

class _ShopItemCard extends StatefulWidget {
  final Item item;
  final int owned;
  final int coins;
  final VoidCallback onPurchase;

  const _ShopItemCard({
    required this.item,
    required this.owned,
    required this.coins,
    required this.onPurchase,
  });

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.coins >= widget.item.price;

    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // アイテム表示
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(10),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadiusLarge),
                  topRight: Radius.circular(AppSizes.borderRadiusLarge),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    if (widget.owned > 0) ...[
                      AppSpacing.verticalSpacerXs,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: kAccentGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                        ),
                        child: Text(
                          '所有: ${widget.owned}',
                          style: AppTypography.bodySmall.copyWith(
                            color: kAccentGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // アイテム情報
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  widget.item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: kTextMuted,
                    fontSize: 11,
                  ),
                ),
                AppSpacing.verticalSpacerSm,

                // 価格と購入ボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🪙 ${widget.item.price}',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: canAfford ? kAccentOrange : kTextMuted,
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: canAfford ? widget.onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? kAccentOrange : Colors.grey[300],
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                          ),
                        ),
                        child: Text(
                          '購入',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.white : Colors.grey[600],
                          ),
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
    );
  }
}
