import 'package:shared_core/shared_core.dart';

import '../data/eigo_characters.dart';

/// 英語コレ！キャラクター管理
///
/// characterStateProvider（shared_core）を main.dart の ProviderScope で
/// CharacterNotifier.new によりoverrideして使用する。
/// shared_core の CharacterCollectionPage ウィジェットは characterStateProvider
/// （BaseCharacterNotifier / CharacterStateMap）を前提としているため、
/// ここは BaseCharacterProfileNotifier ではなく BaseCharacterNotifier を継承すること。
class CharacterNotifier extends BaseCharacterNotifier {
  @override
  List<BaseCharacter> get characterList => kEigoCharacters;

  @override
  String get storageKey => 'eigo_char_states';
}
