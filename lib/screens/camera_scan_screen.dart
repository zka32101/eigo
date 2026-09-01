import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_scan_model.dart';
import '../providers/camera_scan_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class CameraScanScreen extends ConsumerWidget {
  const CameraScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myDictionary = ref.watch(myDictionaryProvider);
    final stats = ref.watch(dictionaryStatsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📸 カメラ単語スキャン'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: [
              Tab(child: Stack(
                children: [
                  const Text('スキャン'),
                  if (stats.totalItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: kAccentOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${stats.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )),
              const Tab(text: '辞書'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Camera scan tab
            _CameraScanTab(),
            // Dictionary tab
            _MyDictionaryTab(vocabulary: myDictionary, stats: stats),
          ],
        ),
      ),
    );
  }
}

class _CameraScanTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CameraScanTab> createState() => _CameraScanTabState();
}

class _CameraScanTabState extends ConsumerState<_CameraScanTab> {
  String _selectedImage = '';
  String _detectedLabel = '';

  void _simulatePhotoCapture() {
    // In production, use image_picker and camera packages
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スキャンするアイテムを選択'),
        content: SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              _CameraSelectItem('apple', '🍎'),
              _CameraSelectItem('chair', '🪑'),
              _CameraSelectItem('cat', '🐱'),
              _CameraSelectItem('flower', '🌸'),
            ],
          ),
        ),
      ),
    );
  }

  void _processScannedItem(String label) {
    Navigator.pop(context);
    setState(() {
      _selectedImage = label;
      _detectedLabel = label;
    });

    // Trigger AI recognition
    _showRecognitionResult(label);
  }

  void _showRecognitionResult(String label) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RecognitionResultSheet(
        label: label,
        onAdd: (vocab) {
          ref.read(myDictionaryProvider.notifier).addVocabulary(vocab);
          ref.read(dictionaryStatsProvider.notifier).recordScan(vocab.category);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「${vocab.englishWord}」を辞書に追加しました'),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
          setState(() => _selectedImage = '');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpacerLg,
          
          // Camera button section
          Container(
            margin: AppSpacing.allPaddingLg,
            padding: AppSpacing.allPaddingLg,
            decoration: BoxDecoration(
              color: kPrimaryColor.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: kPrimaryColor.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '部屋のアイテムを撮ってみましょう！',
                  style: AppTypography.labelLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpacerMd,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _simulatePhotoCapture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラを起動'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Recent scans section
          if (_selectedImage.isNotEmpty)
            _RecentScanCard(label: _selectedImage),
          
          // Tips section
          _TipsSection(),
          
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _CameraSelectItem extends StatelessWidget {
  final String label;
  final String emoji;

  const _CameraSelectItem(this.label, this.emoji);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        final state = context.findAncestorStateOfType<_CameraScanTabState>();
        state?._processScannedItem(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            AppSpacing.verticalSpacerSm,
            Text(label, style: AppTypography.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _RecentScanCard extends ConsumerWidget {
  final String label;

  const _RecentScanCard({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recognitionAsync = ref.watch(aiRecognitionProvider(label));

    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kPrimaryColor.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📸 スキャン結果',
            style: AppTypography.labelLarge,
          ),
          AppSpacing.verticalSpacerMd,
          
          recognitionAsync.when(
            data: (result) => result != null
                ? _RecognitionContent(result: result)
                : Center(
                    child: Text(
                      'アイテムが認識されませんでした',
                      style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                    ),
                  ),
            loading: () => Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  AppSpacing.verticalSpacerMd,
                  Text('AIが分析中...', style: AppTypography.bodySmall),
                ],
              ),
            ),
            error: (err, st) => Center(
              child: Text('エラー: $err', style: AppTypography.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecognitionContent extends StatelessWidget {
  final AIRecognitionResult result;

  const _RecognitionContent({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: kPrimaryColor.withAlpha(10),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.objectName.toUpperCase(),
                style: AppTypography.headlineSmall.copyWith(
                  color: kPrimaryColor,
                ),
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                result.japaneseTranslation,
                style: AppTypography.labelLarge,
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                result.pronunciationIPA,
                style: AppTypography.bodySmall.copyWith(
                  color: kTextMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              AppSpacing.verticalSpacerMd,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'カテゴリー',
                          style: AppTypography.labelSmall.copyWith(
                            color: kTextMuted,
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          result.category,
                          style: AppTypography.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '認識度',
                          style: AppTypography.labelSmall.copyWith(
                            color: kTextMuted,
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          '${(result.confidence * 100).toStringAsFixed(0)}%',
                          style: AppTypography.labelLarge.copyWith(
                            color: kAccentGreen,
                          ),
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
        Text(
          result.detailedDescription,
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}

class _RecognitionResultSheet extends ConsumerWidget {
  final String label;
  final Function(ScannedVocabulary) onAdd;

  const _RecognitionResultSheet({
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recognitionAsync = ref.watch(aiRecognitionProvider(label));

    return recognitionAsync.when(
      data: (result) => result != null
          ? _ResultBottomSheet(result: result, onAdd: onAdd)
          : Center(
              child: Text('アイテムが認識されませんでした'),
            ),
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            AppSpacing.verticalSpacerMd,
            Text('AIが分析中...'),
          ],
        ),
      ),
      error: (err, st) => Center(
        child: Text('エラー: $err'),
      ),
    );
  }
}

class _ResultBottomSheet extends ConsumerWidget {
  final AIRecognitionResult result;
  final Function(ScannedVocabulary) onAdd;

  const _ResultBottomSheet({
    required this.result,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadius),
          topRight: Radius.circular(AppSizes.borderRadius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            
            Text(
              result.objectName.toUpperCase(),
              style: AppTypography.headlineMedium.copyWith(
                color: kPrimaryColor,
              ),
            ),
            AppSpacing.verticalSpacerSm,
            
            Text(
              result.japaneseTranslation,
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.verticalSpacerMd,
            
            // Recognition confidence
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              child: LinearProgressIndicator(
                value: result.confidence,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(kAccentGreen),
              ),
            ),
            AppSpacing.verticalSpacerSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '認識度',
                  style: AppTypography.labelSmall.copyWith(color: kTextMuted),
                ),
                Text(
                  '${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTypography.labelLarge.copyWith(
                    color: kAccentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            
            // Category and pronunciation
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'カテゴリー',
                        style: AppTypography.labelSmall.copyWith(
                          color: kTextMuted,
                        ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        result.category,
                        style: AppTypography.labelLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '発音',
                        style: AppTypography.labelSmall.copyWith(
                          color: kTextMuted,
                        ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        result.pronunciationIPA,
                        style: AppTypography.labelLarge.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            
            // Description
            Text(
              '説明',
              style: AppTypography.labelSmall.copyWith(color: kTextMuted),
            ),
            AppSpacing.verticalSpacerXs,
            Text(
              result.detailedDescription,
              style: AppTypography.bodySmall,
            ),
            AppSpacing.verticalSpacerLg,
            
            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final vocab = ScannedVocabulary(
                    itemId: DateTime.now().millisecondsSinceEpoch.toString(),
                    englishWord: result.objectName,
                    japaneseWord: result.japaneseTranslation,
                    pronunciation: result.pronunciationIPA,
                    category: result.category,
                    description: result.detailedDescription,
                    imagePath: '',
                    scannedAt: DateTime.now(),
                    useCount: 0,
                  );
                  onAdd(vocab);
                },
                icon: const Icon(Icons.add),
                label: const Text('辞書に追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyDictionaryTab extends ConsumerWidget {
  final List<ScannedVocabulary> vocabulary;
  final DictionaryStats stats;

  const _MyDictionaryTab({
    required this.vocabulary,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(vocabularyCategoriesProvider);

    if (vocabulary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('まだアイテムがありません'),
            AppSpacing.verticalSpacerSm,
            const Text(
              'カメラでアイテムをスキャンしましょう！',
              style: TextStyle(color: kTextMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          _StatsCard(stats: stats),
          AppSpacing.verticalSpacerLg,
          
          // Categories
          Text('カテゴリー別', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: categories.map((cat) {
              final count = vocabulary.where((v) => v.category == cat.categoryId).length;
              return _CategoryChip(
                category: cat,
                count: count,
                items: vocabulary.where((v) => v.category == cat.categoryId).toList(),
              );
            }).toList(),
          ),
          
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final DictionaryStats stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withAlpha(20), kPrimaryColor.withAlpha(5)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kPrimaryColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('📸', style: const TextStyle(fontSize: 28)),
              AppSpacing.verticalSpacerXs,
              Text('${stats.totalItems}', style: AppTypography.headlineMedium),
              Text('アイテム', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
            ],
          ),
          Column(
            children: [
              Text('🔥', style: const TextStyle(fontSize: 28)),
              AppSpacing.verticalSpacerXs,
              Text('${stats.currentStreak}', style: AppTypography.headlineMedium),
              Text('日連続', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
            ],
          ),
          Column(
            children: [
              Text('⭐', style: const TextStyle(fontSize: 28)),
              AppSpacing.verticalSpacerXs,
              Text('${stats.categories.length}', style: AppTypography.headlineMedium),
              Text('カテゴリー', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final VocabularyCategory category;
  final int count;
  final List<ScannedVocabulary> items;

  const _CategoryChip({
    required this.category,
    required this.count,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _CategoryItemsSheet(
            category: category,
            items: items,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            AppSpacing.horizontalSpacerSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.categoryName, style: AppTypography.labelSmall),
                Text('$count個', style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItemsSheet extends StatelessWidget {
  final VocabularyCategory category;
  final List<ScannedVocabulary> items;

  const _CategoryItemsSheet({
    required this.category,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadius),
          topRight: Radius.circular(AppSizes.borderRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 28)),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Text(
                  category.categoryName,
                  style: AppTypography.headlineSmall,
                ),
              ),
              Text('${items.length}', style: AppTypography.labelLarge),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _VocabularyCard(vocab: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final ScannedVocabulary vocab;

  const _VocabularyCard({required this.vocab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab.englishWord.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(color: kPrimaryColor),
          ),
          AppSpacing.verticalSpacerXs,
          Text(vocab.japaneseWord, style: AppTypography.labelLarge),
          AppSpacing.verticalSpacerXs,
          Text(
            vocab.pronunciation,
            style: AppTypography.bodySmall.copyWith(
              color: kTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            vocab.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kAccentOrange.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kAccentOrange.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 スキャンのコツ',
            style: AppTypography.labelLarge.copyWith(color: kAccentOrange),
          ),
          AppSpacing.verticalSpacerMd,
          _TipItem('明るい場所で撮ってください'),
          _TipItem('アイテムが中心に入るようにしてください'),
          _TipItem('複数のアイテムは1つずつスキャン'),
          _TipItem('定期的にスキャンしてストリークを保つ'),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Text('✓ ', style: TextStyle(color: kAccentOrange, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
