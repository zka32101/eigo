import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import '../data/eigo_characters.dart';
import '../providers/progress_provider.dart';

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
