import 'package:shared_core/shared_core.dart';

import '../data/eigo_characters.dart';

class CharacterNotifier extends BaseCharacterNotifier {
  @override
  List<BaseCharacter> get characterList => kEigoCharacters;

  @override
  String get storageKey => 'eigo_char_states';
}
