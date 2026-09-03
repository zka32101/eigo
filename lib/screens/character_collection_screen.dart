import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_model.dart';
import '../providers/character_collection_provider.dart';
import '../design_system/design_system.dart';

class CharacterCollectionScreen extends ConsumerStatefulWidget {
  const CharacterCollectionScreen({super.key});

  @override
  ConsumerState<CharacterCollectionScreen> createState() =>
      _CharacterCollectionScreenState();
}

class _CharacterCollectionScreenState extends ConsumerState<CharacterCollectionScreen> {

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(characterCollectionStatsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎭 キャラクター図鑑'),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite,
            indicatorColor: AppColors.accentOrange,
            tabs: [
              Tab(text: 'コレクション'),
              Tab(text: 'レアリティ'),
              Tab(text: '未収集'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // コレクション一覧
            _CollectionListView(stats: stats),
            // レアリティ別表示
            const _RarityView(),
            // 未収集キャラクター
            const _UncollectedView(),
          ],
        ),
      ),
    );
  }
}

class _CollectionListView extends ConsumerWidget {
  final CharacterCollectionStats stats;

  const _CollectionListView({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(characterCollectionProvider);

    if (collection.isEmpty) {
      return SingleChildScrollView(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacing.verticalSpacerXxl,
            const Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
            AppSpacing.verticalSpacerMd,
            const Text('キャラクターをまだ収集していません'),
            AppSpacing.verticalSpacerLg,
            const Text('学習を進めるとキャラクターが手に入ります！', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計カード
          _StatsCard(stats: stats),
          AppSpacing.verticalSpacerLg,

          // コレクション表示
          Text('収集したキャラクター', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: collection.length,
            itemBuilder: (context, index) {
              final collected = collection[index];
              return _CharacterCard(
                collected: collected,
                onTap: () => _showCharacterDetail(context, collected),
              );
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  void _showCharacterDetail(BuildContext context, CollectedCharacter collected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLarge)),
      ),
      builder: (context) => _CharacterDetailSheet(collected: collected),
    );
  }
}

class _RarityView extends ConsumerWidget {
  const _RarityView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(characterCollectionProvider);

    final rarities = ['common', 'uncommon', 'rare', 'legendary'];
    final rarityLabels = {
      'common': 'コモン',
      'uncommon': 'アンコモン',
      'rare': 'レア',
      'legendary': 'レジェンダリー',
    };
    final rarityEmojis = {
      'common': '⭐',
      'uncommon': '⭐⭐',
      'rare': '⭐⭐⭐',
      'legendary': '⭐⭐⭐⭐',
    };
    final rarityColors = {
      'common': AppColors.textMuted,
      'uncommon': AppColors.accentGreen,
      'rare': AppColors.accentOrange,
      'legendary': AppColors.accentOrange, // Gold
    };

    // Build rarity sections for ListView
    final raritySections = <Map<String, dynamic>>[];
    for (final rarity in rarities) {
      final byRarity = collection.where((c) => c.character.rarity == rarity).toList();
      raritySections.add({
        'type': 'header',
        'rarity': rarity,
      });
      raritySections.add({
        'type': 'spacer',
      });

      if (byRarity.isEmpty) {
        raritySections.add({
          'type': 'empty',
        });
      } else {
        for (final character in byRarity) {
          raritySections.add({
            'type': 'character',
            'collected': character,
          });
        }
      }

      raritySections.add({
        'type': 'spacer_lg',
      });
    }
    raritySections.add({'type': 'bottom_spacer'});

    return ListView.builder(
      padding: AppSpacing.allPaddingLg,
      itemCount: raritySections.length,
      itemBuilder: (context, index) {
        final section = raritySections[index];

        switch (section['type']) {
          case 'header':
            final rarity = section['rarity'] as String;
            final byRarity = collection.where((c) => c.character.rarity == rarity).toList();
            return Row(
              children: [
                Text(
                  rarityEmojis[rarity]!,
                  style: const TextStyle(fontSize: 20),
                ),
                AppSpacing.horizontalSpacerMd,
                Text(
                  '${rarityLabels[rarity]} (${byRarity.length})',
                  style: AppTypography.headlineSmall.copyWith(
                    color: rarityColors[rarity],
                  ),
                ),
              ],
            );

          case 'spacer':
            return AppSpacing.verticalSpacerMd;

          case 'spacer_lg':
            return AppSpacing.verticalSpacerLg;

          case 'empty':
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'まだこのレアリティのキャラクターは収集していません',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            );

          case 'character':
            final collected = section['collected'] as CollectedCharacter;
            return Padding(
              padding: const EdgeInsets.all(6),
              child: GestureDetector(
                onTap: () => _showCharacterDetail(context, collected),
                child: _CharacterCard(
                  collected: collected,
                  onTap: () => _showCharacterDetail(context, collected),
                ),
              ),
            );

          case 'bottom_spacer':
            return AppSpacing.verticalSpacerXxl;

          default:
            return const SizedBox();
        }
      },
    );
  }

  void _showCharacterDetail(BuildContext context, CollectedCharacter collected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLarge)),
      ),
      builder: (context) => _CharacterDetailSheet(collected: collected),
    );
  }
}

class _UncollectedView extends ConsumerWidget {
  const _UncollectedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uncollected = ref.watch(uncollectedCharactersProvider);

    if (uncollected.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.accentGreen),
            AppSpacing.verticalSpacerMd,
            const Text('すべてのキャラクターを収集しました！'),
            AppSpacing.verticalSpacerLg,
            const Text('おめでとうございます！', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('あと${uncollected.length}キャラクター！', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: uncollected.length,
            itemBuilder: (context, index) {
              final character = uncollected[index];
              return _UncollectedCharacterCard(
                character: character,
                onCollect: () => _collectCharacter(context, ref, character),
              );
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  void _collectCharacter(BuildContext context, WidgetRef ref, Character character) {
    ref.read(characterCollectionProvider.notifier).collectCharacter(character);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${character.name}をゲットしました！'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CollectedCharacter collected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.collected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = collected.character.rarity;
    final rarityColor = _getRarityColor(rarity);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          side: BorderSide(color: rarityColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // キャラクター表示
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: rarityColor.withAlpha(20),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.borderRadiusLarge - 2),
                    topRight: Radius.circular(AppSizes.borderRadiusLarge - 2),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            collected.character.emoji,
                            style: const TextStyle(fontSize: 60),
                          ),
                          if (collected.isFavorite) ...[
                            AppSpacing.verticalSpacerXs,
                            const Icon(Icons.favorite, color: AppColors.error, size: 20),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lv.${collected.level}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // キャラクター情報
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collected.character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  // 好感度バー
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: collected.affection / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.bgLight,
                      valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '好感度: ${collected.affection}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return AppColors.textMuted;
      case 'uncommon':
        return AppColors.accentGreen;
      case 'rare':
        return AppColors.accentOrange;
      case 'legendary':
        return AppColors.accentOrange; // Gold
      default:
        return AppColors.textMuted;
    }
  }
}

class _UncollectedCharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onCollect;

  const _UncollectedCharacterCard({
    required this.character,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = character.rarity;
    final rarityColor = _getRarityColor(rarity);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // キャラクター表示（グレーアウト）
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgLight,
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
                      character.emoji,
                      style: const TextStyle(fontSize: 40, color: AppColors.textMuted),
                    ),
                    AppSpacing.verticalSpacerSm,
                    const Icon(Icons.lock, color: AppColors.textMuted, size: 24),
                  ],
                ),
              ),
            ),
          ),

          // キャラクター情報
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '???',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                AppSpacing.verticalSpacerSm,
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onCollect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rarityColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                    ),
                    child: Text(
                      'ゲット',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return AppColors.textMuted;
      case 'uncommon':
        return AppColors.accentGreen;
      case 'rare':
        return AppColors.accentOrange;
      case 'legendary':
        return AppColors.accentOrange; // Gold
      default:
        return AppColors.textMuted;
    }
  }
}

class _CharacterDetailSheet extends ConsumerWidget {
  final CollectedCharacter collected;

  const _CharacterDetailSheet({required this.collected});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    collected.character.name,
                    style: AppTypography.headlineMedium,
                  ),
                  IconButton(
                    icon: Icon(
                      collected.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.error,
                    ),
                    onPressed: () {
                      ref
                          .read(characterCollectionProvider.notifier)
                          .setFavorite(collected.character.id, !collected.isFavorite);
                    },
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,

              // キャラクター情報
              Container(
                padding: AppSpacing.allPaddingMd,
                decoration: BoxDecoration(
                  color: AppColors.bgLight.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          collected.character.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${collected.character.type}',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                              ),
                              AppSpacing.verticalSpacerXs,
                              Text(
                                collected.character.rarity,
                                style: AppTypography.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpacerMd,

              // 説明
              Text('説明', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              AppSpacing.verticalSpacerSm,
              Text(collected.character.description, style: AppTypography.bodyMedium),
              AppSpacing.verticalSpacerMd,

              // ストーリー
              Text('背景', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              AppSpacing.verticalSpacerSm,
              Text(collected.character.background, style: AppTypography.bodySmall),
              AppSpacing.verticalSpacerMd,

              // レベルと好感度
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('レベル', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                        AppSpacing.verticalSpacerSm,
                        Text('${collected.level} / 10', style: AppTypography.headlineSmall),
                        AppSpacing.verticalSpacerSm,
                        if (collected.level < 10)
                          ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(characterCollectionProvider.notifier)
                                  .levelUpCharacter(collected.character.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('レベルアップ'),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('好感度', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                        AppSpacing.verticalSpacerSm,
                        Text('${collected.affection} %', style: AppTypography.headlineSmall),
                        AppSpacing.verticalSpacerSm,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: collected.affection / 100,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,

              // スキル
              if (collected.character.skills.isNotEmpty) ...[
                Text('スキル', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                AppSpacing.verticalSpacerSm,
                ...collected.character.skills.map((skill) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Text('✨ ', style: TextStyle(fontSize: 14)),
                        Text(skill, style: AppTypography.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ],
              AppSpacing.verticalSpacerXxl,
            ],
          ),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  final CharacterCollectionStats stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('コレクション進捗', style: AppTypography.labelLarge),
          AppSpacing.verticalSpacerMd,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${stats.collected} / ${stats.totalAvailable}',
                        style: AppTypography.headlineMedium),
                    AppSpacing.verticalSpacerSm,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stats.collected / stats.totalAvailable,
                        minHeight: 8,
                        backgroundColor: AppColors.bgLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          stats.completionRate == 100 ? AppColors.accentGreen : AppColors.accentOrange,
                        ),
                      ),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      '${stats.completionRate}% 完成',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSpacerLg,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatItem('⭐', '${stats.commonCount}'),
                  _StatItem('⭐⭐', '${stats.uncommonCount}'),
                  _StatItem('⭐⭐⭐', '${stats.rareCount}'),
                  _StatItem('⭐⭐⭐⭐', '${stats.legendaryCount}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String count;

  const _StatItem(this.emoji, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          AppSpacing.horizontalSpacerXs,
          Text(count, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
