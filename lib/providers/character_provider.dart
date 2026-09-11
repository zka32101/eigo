import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import '../data/eigo_characters.dart';

// ─── Phase 4.1: CharacterProfile統合版 ────────────────────────────────────

/// 英語コレ！キャラクター管理（Phase 4.1: CharacterProfile対応）
class CharacterNotifier extends BaseCharacterProfileNotifier {
  @override
  List<BaseCharacter> get characterList => kEigoCharacters;

  @override
  String get storageKey => 'eigo_character_profiles';

  @override
  Subject get appSubject => Subject.eigo;
}

/// 統一キャラクタープロバイダー（Phase 4.1）
final characterProvider = NotifierProvider<CharacterNotifier, CharacterProfileMap>(
  CharacterNotifier.new,
);
