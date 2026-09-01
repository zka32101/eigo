import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

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
      final gemini = await SecureStorageService.getGoogleApiKey();
      final claude = await SecureStorageService.getClaudeApiKey();
      state = AiApiKeys(geminiKey: gemini, claudeKey: claude);
    } catch (_) {
      // Silent failure - keys will be null
    }
  }

  Future<void> setGeminiKey(String key) async {
    try {
      if (key.isEmpty) {
        await SecureStorageService.clearGoogleApiKey();
        state = AiApiKeys(geminiKey: null, claudeKey: state.claudeKey);
      } else {
        await SecureStorageService.saveGoogleApiKey(key);
        state = AiApiKeys(geminiKey: key, claudeKey: state.claudeKey);
      }
    } catch (_) {
      // Silent failure
    }
  }

  Future<void> setClaudeKey(String key) async {
    try {
      if (key.isEmpty) {
        await SecureStorageService.clearClaudeApiKey();
        state = AiApiKeys(geminiKey: state.geminiKey, claudeKey: null);
      } else {
        await SecureStorageService.saveClaudeApiKey(key);
        state = AiApiKeys(geminiKey: state.geminiKey, claudeKey: key);
      }
    } catch (_) {
      // Silent failure
    }
  }

  Future<void> clearAllKeys() async {
    try {
      await SecureStorageService.clearAllKeys();
      state = AiApiKeys();
    } catch (_) {
      // Silent failure
    }
  }
}
