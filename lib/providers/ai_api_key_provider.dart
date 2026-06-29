import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _geminiKeyName = 'eigo_kore_gemini_api_key';
const _claudeKeyName = 'eigo_kore_claude_api_key';

final aiApiKeysProvider = StateNotifierProvider<AiApiKeyNotifier, AiApiKeys>((ref) {
  return AiApiKeyNotifier();
});

class AiApiKeys {
  final String? geminiKey;
  final String? claudeKey;

  AiApiKeys({this.geminiKey, this.claudeKey});

  bool get hasGeminiKey => geminiKey != null && geminiKey!.isNotEmpty;
  bool get hasClaudeKey => claudeKey != null && claudeKey!.isNotEmpty;
}

class AiApiKeyNotifier extends StateNotifier<AiApiKeys> {
  AiApiKeyNotifier() : super(AiApiKeys()) {
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    try {
      final gemini = await _storage.read(key: _geminiKeyName);
      final claude = await _storage.read(key: _claudeKeyName);
      state = AiApiKeys(geminiKey: gemini, claudeKey: claude);
    } catch (_) {
      // Silent failure - keys will be null
    }
  }

  Future<void> setGeminiKey(String key) async {
    try {
      if (key.isEmpty) {
        await _storage.delete(key: _geminiKeyName);
        state = AiApiKeys(geminiKey: null, claudeKey: state.claudeKey);
      } else {
        await _storage.write(key: _geminiKeyName, value: key);
        state = AiApiKeys(geminiKey: key, claudeKey: state.claudeKey);
      }
    } catch (_) {
      // Silent failure
    }
  }

  Future<void> setClaudeKey(String key) async {
    try {
      if (key.isEmpty) {
        await _storage.delete(key: _claudeKeyName);
        state = AiApiKeys(geminiKey: state.geminiKey, claudeKey: null);
      } else {
        await _storage.write(key: _claudeKeyName, value: key);
        state = AiApiKeys(geminiKey: state.geminiKey, claudeKey: key);
      }
    } catch (_) {
      // Silent failure
    }
  }

  Future<void> clearAllKeys() async {
    try {
      await _storage.delete(key: _geminiKeyName);
      await _storage.delete(key: _claudeKeyName);
      state = AiApiKeys();
    } catch (_) {
      // Silent failure
    }
  }
}
