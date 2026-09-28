import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  static const _items = [
    _HowToItem(
      emoji: '📚',
      title: 'ステージに挑戦しよう',
      description:
          'ホーム画面から「ステージ」を選んで、リスニング・スピーキングの問題に挑戦できます。'
          'クリアすると次のステージが解放されます。',
    ),
    _HowToItem(
      emoji: '🎤',
      title: '発音をチェックしよう',
      description: '英語を声に出して読むと、AIが発音を採点してくれます。何度でも練習できます。',
    ),
    _HowToItem(
      emoji: '🤖',
      title: 'AIフリートークで話してみよう',
      description: 'AIキャラクターと自由に英会話の練習ができます。まずは簡単なあいさつから始めてみましょう。',
    ),
    _HowToItem(
      emoji: '🔥',
      title: '毎日続けて連続記録を伸ばそう',
      description: '毎日学習すると「連続学習日数」が増えていきます。コインやバッジもたまります。',
    ),
    _HowToItem(
      emoji: '🐾',
      title: 'キャラクターを育てよう',
      description: '学習で貯めたコインを使って、パートナーキャラクターを育成・着せ替えできます。',
    ),
    _HowToItem(
      emoji: '⚙️',
      title: '設定はここから',
      description: '通知やAPIキー、プランの変更など、細かい設定はすべて「設定」画面にまとまっています。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('このアプリの使い方'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: AppSpacing.allPaddingLg,
        children: [
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 28)),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Text(
                    'このアプリの目標は「基本的な会話ができる」ようになること。\n'
                    'あいさつから日常のやりとりまで、毎日少しずつ練習していきましょう。',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,
          Text(
            '「英語コレ！」でできることを簡単に紹介します。',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.verticalSpacerLg,
          for (final item in _items) ...[
            _HowToCard(item: item),
            AppSpacing.verticalSpacerMd,
          ],
        ],
      ),
    );
  }
}

class _HowToItem {
  final String emoji;
  final String title;
  final String description;

  const _HowToItem({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class _HowToCard extends StatelessWidget {
  final _HowToItem item;
  const _HowToCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            AppSpacing.horizontalSpacerMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    item.description,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
