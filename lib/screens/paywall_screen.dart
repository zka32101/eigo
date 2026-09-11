import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_core/shared_core.dart';

import '../design_system/design_system.dart';
import '../providers/purchase_provider.dart';
import '../services/purchase_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    try {
      await PurchaseService.initializeRevenueCat();
      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初期化エラー: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアムプラン'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヒーローセクション
              _buildHeroSection(),
              SizedBox(height: AppSpacing.lg),

              // 機能リスト
              _buildFeatureList(),
              SizedBox(height: AppSpacing.lg),

              // プランカード
              _buildPlanCard(),
              SizedBox(height: AppSpacing.lg),

              // 購入ボタン
              _buildPurchaseButton(context, ref, purchaseState),
              SizedBox(height: AppSpacing.md),

              // トライアルバナー
              _buildTrialBanner(),
              SizedBox(height: AppSpacing.lg),

              // 免責事項
              _buildDisclaimer(),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      ),
      child: Column(
        children: [
          const Text('🎤', style: TextStyle(fontSize: 48)),
          SizedBox(height: AppSpacing.xs),
          Text(
            'スピーキング力を\n本物にしよう！',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textWhite,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'AI発音チェック × 親向け詳細フィードバック',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textWhite.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      ('🎯', '無制限クイズ', '全ステージのクイズに無制限でアクセス'),
      ('🎤', 'AI発音チェック', 'スピーキング力を客観的に評価'),
      ('📊', '親向けダッシュボード', '子どもの成長を詳しく追跡'),
      ('🤖', 'AIコーチング', 'パーソナライズされた学習アドバイス'),
      ('📺', '広告なし', 'さらに快適な学習体験'),
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    feature.$1,
                    style: const TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.$2,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feature.$3,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Pro プラン',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '¥120',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '/月',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'リスニング + スピーキング完全対応',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    WidgetRef ref,
    PurchaseState purchaseState,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      onPressed: purchaseState.isLoading
          ? null
          : () => _handlePurchase(context, ref),
      child: purchaseState.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.textWhite,
                strokeWidth: 2,
              ),
            )
          : Text(
              '¥120/月で始める',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('初期化中です。しばらくお待ちください。'),
        ),
      );
      return;
    }

    // 親向けゲートを表示（COPPAコンプライアンス対応）
    final passedGate = await requireParentalGate(context);
    if (!passedGate || !context.mounted) return;

    // 購入処理
    final success = await ref.read(purchaseProvider.notifier).purchase(
      'eigo_kore_pro_monthly',
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pro プランへようこそ！'),
          backgroundColor: AppColors.primary,
        ),
      );
      // 購入成功後、ホーム画面に戻る
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(purchaseProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ?? '購入に失敗しました。もう一度お試しください。',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildTrialBanner() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.accentGreen.withAlpha(76)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 24)),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '2週間無料トライアル実施中！\nすべての機能をお試しいただけます。',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      '※ サブスクリプションは App Store / Google Play のアカウントに請求されます。'
      '現在の期間が終了する24時間前までに解約しない限り、自動的に更新されます。'
      'いつでも設定からキャンセルできます。',
      style: AppTypography.bodySmall.copyWith(
        fontSize: 11,
        color: AppColors.textMuted,
        height: 1.5,
      ),
    );
  }
}
