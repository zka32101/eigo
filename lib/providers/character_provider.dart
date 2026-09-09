import 'package:shared_core/shared_core.dart';
import '../data/eigo_characters.dart';

/// 英語コレ！キャラクター進捗 Notifier。
///
/// 旧 `CharacterCollectionNotifier`（lib/providers/character_collection_provider.dart、
/// 独自実装・学習実績と無連動のダミートリガー）を置き換え、shared_core の
/// [BaseCharacterNotifier] に接続する。解放判定は `checkUnlocks()` に
/// クリアステージ数を渡すことで行う（呼び出し元: character_collection_screen.dart）。
///
/// main.dart で以下のように上書きする:
/// ```dart
/// characterStateProvider.overrideWith(CharacterNotifier.new)
/// ```
class CharacterNotifier extends BaseCharacterNotifier {
  @override
  List<BaseCharacter> get characterList => kEigoCharacters;

  @override
  String get storageKey => 'eigo_char_states';
}
