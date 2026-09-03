import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../design_system/design_system.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isOwned;
  final bool isLoading;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.isOwned = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: isOwned || isLoading ? null : onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product header with icon and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product icon/image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        product.icon ?? '🎁',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: AppTypography.bodyLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.verticalSpacerSm,
                        Text(
                          product.description,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,

              // Rewards section
              if (product.rewardCoins != null ||
                  product.rewardXp != null ||
                  product.rewardBadgeId != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '獲得報酬',
                      style: AppTypography.labelMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Wrap(
                      spacing: 12,
                      children: [
                        if (product.rewardCoins != null)
                          _RewardBadge(
                            icon: '🪙',
                            label: '${product.rewardCoins}',
                          ),
                        if (product.rewardXp != null)
                          _RewardBadge(
                            icon: '⭐',
                            label: '${product.rewardXp} XP',
                          ),
                        if (product.rewardBadgeId != null)
                          _RewardBadge(
                            icon: '🏅',
                            label: 'バッジ',
                          ),
                      ],
                    ),
                    AppSpacing.verticalSpacerMd,
                  ],
                ),

              // Tags
              if (product.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: product.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTagColor(tag).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.labelSmall.copyWith(
                          color: _getTagColor(tag),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              AppSpacing.verticalSpacerMd,

              // Price and button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.displayPrice,
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓ 所持中',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onTap,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('購入'),
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

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'daily':
        return AppColors.accentOrange;
      case 'popular':
        return AppColors.accentRed;
      case 'limited':
        return AppColors.accentPurple;
      case 'new':
        return AppColors.accentGreen;
      default:
        return AppColors.primary;
    }
  }
}

class _RewardBadge extends StatelessWidget {
  final String icon;
  final String label;

  const _RewardBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
