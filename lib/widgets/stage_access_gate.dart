import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stage.dart';
import '../providers/purchase_provider.dart';

/// 無料期間（14日）が終わった後も無料で遊べる最大ステージ番号（他の小学コレと同じ）。
const int kFreeStageLimit = 10;

/// ステージ画面のロック。
///
/// 無料期間中・プレミアム購読中は常に [child] を表示する。
/// 無料期間が終わった後は、[kFreeStageLimit] を超えるステージだけ課金画面へ誘導する。
class StageAccessGate extends ConsumerWidget {
  final Stage stage;
  final Widget child;

  const StageAccessGate({super.key, required this.stage, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stage.stageNumber <= kFreeStageLimit) return child;
    if (ref.watch(hasPremiumAccessProvider)) return child;

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアム')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                '無料期間は終了しました',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'つづきを学ぶには、プレミアムへの登録が必要です。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/upgrade'),
                child: const Text('プレミアムを見る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
