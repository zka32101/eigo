import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_message.dart';
import '../services/claude_api_service.dart';
import '../services/gemini_service.dart';
import 'package:uuid/uuid.dart';

final claudeConversationProvider = StateNotifierProvider<
    ClaudeConversationNotifier,
    ClaudeConversationState>((ref) {
  return ClaudeConversationNotifier();
});

class ClaudeConversationState {
  final List<ConversationMessage> messages;
  final bool isLoading;
  final String? error;
  final GeminiService? geminiService;
  final ClaudeApiService? claudeService;

  const ClaudeConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.geminiService,
    this.claudeService,
  });

  ClaudeConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isLoading,
    String? error,
    GeminiService? geminiService,
    ClaudeApiService? claudeService,
  }) {
    return ClaudeConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      geminiService: geminiService ?? this.geminiService,
      claudeService: claudeService ?? this.claudeService,
    );
  }
}

class ClaudeConversationNotifier extends StateNotifier<ClaudeConversationState> {
  ClaudeConversationNotifier() : super(const ClaudeConversationState());

  void initializeApiServices({
    required String? geminiKey,
    required String? claudeKey,
    required String userGrade,
  }) {
    GeminiService? gemini;
    ClaudeApiService? claude;

    if (geminiKey != null && geminiKey.isNotEmpty) {
      gemini = GeminiService(apiKey: geminiKey, userGrade: userGrade);
    }

    if (claudeKey != null && claudeKey.isNotEmpty) {
      claude = ClaudeApiService(apiKey: claudeKey, userGrade: userGrade);
    }

    state = state.copyWith(
      geminiService: gemini,
      claudeService: claude,
    );
  }

  Future<void> sendMessage(String text) async {
    const uuid = Uuid();

    if (state.geminiService == null && state.claudeService == null) {
      state = state.copyWith(
        error: '設定 > AI キー設定 から API キーを入力してください',
      );
      return;
    }

    final userMessage = ConversationMessage(
      id: uuid.v4(),
      text: text,
      role: 'user',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    ConversationMessage response;

    try {
      if (state.geminiService != null) {
        response = await state.geminiService!.sendMessage(
          text,
          state.messages,
        );

        if (!response.isError) {
          state = state.copyWith(
            messages: [...state.messages, response],
            isLoading: false,
          );
          return;
        }
      }

      if (state.claudeService != null) {
        response = await state.claudeService!.sendMessage(
          text,
          state.messages,
        );

        if (!response.isError) {
          state = state.copyWith(
            messages: [...state.messages, response],
            isLoading: false,
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Both APIs failed. Please try again.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
      );
    }
  }

  void clearConversation() {
    state = state.copyWith(messages: const []);
  }
}
