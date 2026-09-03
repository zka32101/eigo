import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';

enum PlanType { lite, pro, plus, premium }

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  PlanType _selected = PlanType.pro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 プランを選ぼう'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(),
            AppSpacing.verticalSpacerLg,
            _ComparisonHeader(),
            AppSpacing.verticalSpacerXs,
            _PlanCard(
              plan: PlanType.lite,
              selected: _selected == PlanType.lite,
              onTap: () => setState(() => _selected = PlanType.lite),
            ),
            AppSpacing.verticalSpacerXs,
            _PlanCard(
              plan: PlanType.pro,
              selected: _selected == PlanType.pro,
              isRecommended: true,
              onTap: () => setState(() => _selected = PlanType.pro),
            ),
            AppSpacing.verticalSpacerXs,
            _PlanCard(
              plan: PlanType.plus,
              selected: _selected == PlanType.plus,
              onTap: () => setState(() => _selected = PlanType.plus),
            ),
            AppSpacing.verticalSpacerXs,
            _PlanCard(
              plan: PlanType.premium,
              selected: _selected == PlanType.premium,
              onTap: () => setState(() => _selected = PlanType.premium),
            ),
            AppSpacing.verticalSpacerXl,
            _SubscribeButton(plan: _selected),
            AppSpacing.verticalSpacerXs,
            _TrialBanner(),
            AppSpacing.verticalSpacerLg,
            _FeatureComparisonTable(),
            AppSpacing.verticalSpacerMd,
            _Disclaimer(),
            AppSpacing.verticalSpacerXxl,
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      ),
      child: Column(
        children: [
          const Text('🎤', style: TextStyle(fontSize: 48)),
          AppSpacing.verticalSpacerXs,
          Text(
            'スピーキング力を\n本物にしよう！',
            style: AppTypography.headlineLarge.copyWith(color:AppColors.textWhite, height: 1.4),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            'AI発音チェック × 親向け詳細フィードバック',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'プランを選択',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

String _planName(PlanType p) {
  switch (p) {
    case PlanType.lite: return 'Lite';
    case PlanType.pro: return 'Pro';
    case PlanType.plus: return 'Plus';
    case PlanType.premium: return 'Premium';
  }
}

String _planPrice(PlanType p) {
  switch (p) {
    case PlanType.lite: return '¥200';
    case PlanType.pro: return '¥400';
    case PlanType.plus: return '¥550';
    case PlanType.premium: return '¥1,800';
  }
}

String _planSubtitle(PlanType p) {
  switch (p) {
    case PlanType.lite: return 'リスニングのみ';
    case PlanType.pro: return 'リスニング + スピーキング';
    case PlanType.plus: return '4技能（L+S+R+W）';
    case PlanType.premium: return '全6教科 + 英語Pro + 親コーチング';
  }
}

List<String> _planFeatures(PlanType p) {
  switch (p) {
    case PlanType.lite: return [
      '✅ リスニング問題 全ステージ',
      '✅ 親ダッシュボード（基本版）',
      '✅ バッジシステム',
      '❌ スピーキング発音チェック',
      '❌ 詳細スピーキング分析',
    ];
    case PlanType.pro: return [
      '✅ リスニング問題 全ステージ',
      '✅ スピーキング発音チェック（AI）',
      '✅ 発音スコア 0-100 表示',
      '✅ 親向けスピーキング詳細ダッシュボード',
      '✅ AIコーチングアドバイス',
      '✅ バッジ・コインシステム',
    ];
    case PlanType.plus: return [
      '✅ Pro の全機能',
      '✅ リーディング問題',
      '✅ ライティング問題',
      '✅ 4技能バランス学習',
      '✅ 総合進捗グラフ',
    ];
    case PlanType.premium: return [
      '✅ Plus の全機能（英語）',
      '✅ 算数・国語・理科・社会・道徳',
      '✅ 兄弟2人まで同一価格',
      '✅ 週次AIコーチングレポート',
      '✅ テスト対策モード',
      '✅ 親向けランキング機能',
    ];
  }
}

Color _planColor(PlanType p) {
  switch (p) {
    case PlanType.lite: return AppColors.listeningColor;
    case PlanType.pro: return AppColors.primary;
    case PlanType.plus: return AppColors.accentGreen;
    case PlanType.premium: return AppColors.accentOrange;
  }
}

class _PlanCard extends StatelessWidget {
  final PlanType plan;
  final bool selected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _planColor(plan);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          border: Border.all(
            color: selected ? color :AppColors.textMuted,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withAlpha(51), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? color :AppColors.textMuted, width: 2),
                      color: selected ? color : Colors.transparent,
                    ),
                    child: selected ? const Icon(Icons.check, color: AppColors.textWhite, size: 12) : null,
                  ),
                  AppSpacing.horizontalSpacerXs,
                  Text(
                    _planName(plan),
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: selected ? color : AppColors.textPrimary),
                  ),
                  AppSpacing.horizontalSpacerXs,
                  if (isRecommended)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(color: color.withAlpha(76)),
                      ),
                      child: Text('おすすめ', style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _planPrice(plan),
                        style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold, color: selected ? color : AppColors.textPrimary),
                      ),
                      Text('/月', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalSpacerXs,
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(_planSubtitle(plan), style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 13)),
              ),
              if (selected) ...[
                AppSpacing.verticalSpacerXs,
                const Divider(height: 1),
                AppSpacing.verticalSpacerXs,
                ..._planFeatures(plan).map((f) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs, left: 4),
                  child: Text(f, style: AppTypography.bodySmall.copyWith(
                    fontSize: 13,
                    color: f.startsWith('✅') ? AppColors.textPrimary : Colors.grey,
                  )),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribeButton extends ConsumerWidget {
  final PlanType plan;
  const _SubscribeButton({required this.plan});

  String _productId(PlanType p) {
    switch (p) {
      case PlanType.lite: return 'eigo_kore_lite_monthly';
      case PlanType.pro: return 'eigo_kore_pro_monthly';
      case PlanType.plus: return 'eigo_kore_plus_monthly';
      case PlanType.premium: return 'eigo_kore_premium_monthly';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseProvider);
    final color = _planColor(plan);
    final isLoading = purchase.isLoading;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
      ),
      onPressed: isLoading ? null : () => _showPurchaseDialog(context, ref, plan),
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color:AppColors.textWhite, strokeWidth: 2))
          : Text(
              '${_planName(plan)} プランに登録する（${_planPrice(plan)}/月）',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
    );
  }

  void _showPurchaseDialog(BuildContext context, WidgetRef ref, PlanType plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_planName(plan)} プラン'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_planPrice(plan)}/月 で申し込みます。'),
            AppSpacing.verticalSpacerXs,
            Text(
              'App Store / Google Play の決済を通じて請求されます。\nいつでもキャンセル可能です。',
              style: AppTypography.bodySmall.copyWith(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(purchaseProvider.notifier).purchase(_productId(plan));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_planName(plan)} プランへようこそ！'),
                    backgroundColor: _planColor(plan),
                  ),
                );
              }
            },
            child: const Text('申し込む'),
          ),
        ],
      ),
    );
  }
}

class _TrialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.accentGreen.withAlpha(76)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 20)),
          AppSpacing.horizontalSpacerXs,
          Expanded(
            child: Text(
              '2週間無料トライアル実施中！\nすべてのプランで全機能をお試しいただけます。',
              style: AppTypography.bodySmall.copyWith(fontSize: 13, color: AppColors.accentGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('機能比較', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.verticalSpacerXs,
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                _tableHeader(),
                _tableRow('リスニング', true, true, true, true),
                _tableRow('スピーキング', false, true, true, true),
                _tableRow('発音スコア', false, true, true, true),
                _tableRow('リーディング', false, false, true, true),
                _tableRow('ライティング', false, false, true, true),
                _tableRow('親ダッシュボード', true, true, true, true),
                _tableRow('詳細分析', false, true, true, true),
                _tableRow('AIコーチング', false, true, true, true),
                _tableRow('全6教科', false, false, false, true),
                _tableRow('テスト対策', false, false, false, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _tableHeader() {
    final style = AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 12);
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.textMuted)),
      ),
      children: [
        Padding(padding: EdgeInsets.only(bottom: 8), child: Text('機能', style: style)),
        ...['Lite', 'Pro', 'Plus', '⭐'].map((t) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(t, style: style, textAlign: TextAlign.center),
        )),
      ],
    );
  }

  TableRow _tableRow(String label, bool lite, bool pro, bool plus, bool premium) {
    Widget cell(bool v) => Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Icon(
        v ? Icons.check_circle : Icons.remove,
        size: 16,
        color: v ? AppColors.accentGreen :AppColors.textMuted,
      ),
    );

    return TableRow(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 13, color: AppColors.textPrimary)),
      ),
      Align(alignment: Alignment.center, child: cell(lite)),
      Align(alignment: Alignment.center, child: cell(pro)),
      Align(alignment: Alignment.center, child: cell(plus)),
      Align(alignment: Alignment.center, child: cell(premium)),
    ]);
  }
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '※ サブスクリプションは App Store / Google Play のアカウントに請求されます。\n'
      '現在の期間が終了する24時間前までに解約しない限り、自動的に更新されます。\n'
      'いつでも設定からキャンセルできます。',
      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted, height: 1.5),
    );
  }
}
