import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';
import '../theme/app_theme.dart';

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
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(),
            const SizedBox(height: 20),
            _ComparisonHeader(),
            const SizedBox(height: 12),
            _PlanCard(
              plan: PlanType.lite,
              selected: _selected == PlanType.lite,
              onTap: () => setState(() => _selected = PlanType.lite),
            ),
            const SizedBox(height: 8),
            _PlanCard(
              plan: PlanType.pro,
              selected: _selected == PlanType.pro,
              isRecommended: true,
              onTap: () => setState(() => _selected = PlanType.pro),
            ),
            const SizedBox(height: 8),
            _PlanCard(
              plan: PlanType.plus,
              selected: _selected == PlanType.plus,
              onTap: () => setState(() => _selected = PlanType.plus),
            ),
            const SizedBox(height: 8),
            _PlanCard(
              plan: PlanType.premium,
              selected: _selected == PlanType.premium,
              onTap: () => setState(() => _selected = PlanType.premium),
            ),
            const SizedBox(height: 24),
            _SubscribeButton(plan: _selected),
            const SizedBox(height: 12),
            _TrialBanner(),
            const SizedBox(height: 20),
            _FeatureComparisonTable(),
            const SizedBox(height: 16),
            _Disclaimer(),
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🎤', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'スピーキング力を\n本物にしよう！',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'AI発音チェック × 親向け詳細フィードバック',
            style: TextStyle(color: Colors.white70, fontSize: 13),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'プランを選択',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
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
    case PlanType.lite: return kListeningColor;
    case PlanType.pro: return kPrimaryColor;
    case PlanType.plus: return kAccentGreen;
    case PlanType.premium: return kAccentOrange;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withAlpha(51), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      border: Border.all(color: selected ? color : Colors.grey.shade300, width: 2),
                      color: selected ? color : Colors.transparent,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _planName(plan),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selected ? color : kTextDark),
                  ),
                  const SizedBox(width: 8),
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withAlpha(76)),
                      ),
                      child: Text('おすすめ', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                    ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _planPrice(plan),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: selected ? color : kTextDark),
                      ),
                      const Text('/月', style: TextStyle(fontSize: 11, color: kTextMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(_planSubtitle(plan), style: const TextStyle(color: kTextMuted, fontSize: 13)),
              ),
              if (selected) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ..._planFeatures(plan).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(f, style: TextStyle(
                    fontSize: 13,
                    color: f.startsWith('✅') ? kTextDark : Colors.grey,
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: isLoading ? null : () => _showPurchaseDialog(context, ref, plan),
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(
              '${_planName(plan)} プランに登録する（${_planPrice(plan)}/月）',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
            const SizedBox(height: 8),
            const Text(
              'App Store / Google Play の決済を通じて請求されます。\nいつでもキャンセル可能です。',
              style: TextStyle(fontSize: 13, color: kTextMuted),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kAccentGreen.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentGreen.withAlpha(76)),
      ),
      child: const Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '2週間無料トライアル実施中！\nすべてのプランで全機能をお試しいただけます。',
              style: TextStyle(fontSize: 13, color: kAccentGreen, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('機能比較', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextMuted);
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      children: [
        const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('機能', style: style)),
        ...['Lite', 'Pro', 'Plus', '⭐'].map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(t, style: style, textAlign: TextAlign.center),
        )),
      ],
    );
  }

  TableRow _tableRow(String label, bool lite, bool pro, bool plus, bool premium) {
    Widget cell(bool v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Icon(
        v ? Icons.check_circle : Icons.remove,
        size: 16,
        color: v ? kAccentGreen : Colors.grey.shade300,
      ),
    );

    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(label, style: const TextStyle(fontSize: 13, color: kTextDark)),
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
    return const Text(
      '※ サブスクリプションは App Store / Google Play のアカウントに請求されます。\n'
      '現在の期間が終了する24時間前までに解約しない限り、自動的に更新されます。\n'
      'いつでも設定からキャンセルできます。',
      style: TextStyle(fontSize: 11, color: kTextMuted, height: 1.5),
    );
  }
}
