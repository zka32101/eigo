import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../data/eigo_characters.dart';
import '../providers/progress_provider.dart';

/// 英語コレ！キャラクター図鑑画面。
///
/// 表示ロジックはすべて shared_core の [CharacterCollectionPage] に委譲する。
/// クリアステージ数（[progressProvider] の clearedStages）を基準に
/// キャラクターの解放判定を行う。
class CharacterCollectionScreen extends ConsumerWidget {
  const CharacterCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearedCount =
        ref.watch(progressProvider.select((p) => p.clearedStages.length));
    return CharacterCollectionPage(
      characters: kEigoCharacters,
      totalStagesCleared: clearedCount,
    );
  }
}
