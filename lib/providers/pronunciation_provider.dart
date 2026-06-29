import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pronunciation_service.dart';
import '../models/pronunciation_result.dart';

final pronunciationServiceProvider = Provider((ref) {
  return PronunciationService();
});

final pronunciationStateProvider = StateNotifierProvider<
    PronunciationStateNotifier,
    PronunciationState>((ref) {
  return PronunciationStateNotifier(ref.watch(pronunciationServiceProvider));
});

class PronunciationState {
  final bool isListening;
  final bool isCheckingComplete;
  final PronunciationResult? lastResult;
  final String? errorMessage;
  final List<PronunciationResult> history;

  const PronunciationState({
    this.isListening = false,
    this.isCheckingComplete = false,
    this.lastResult,
    this.errorMessage,
    this.history = const [],
  });

  PronunciationState copyWith({
    bool? isListening,
    bool? isCheckingComplete,
    PronunciationResult? lastResult,
    String? errorMessage,
    List<PronunciationResult>? history,
  }) {
    return PronunciationState(
      isListening: isListening ?? this.isListening,
      isCheckingComplete: isCheckingComplete ?? this.isCheckingComplete,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage ?? this.errorMessage,
      history: history ?? this.history,
    );
  }
}

class PronunciationStateNotifier extends StateNotifier<PronunciationState> {
  final PronunciationService _service;

  PronunciationStateNotifier(this._service)
      : super(const PronunciationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.initialize();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Initialization failed: $e');
    }
  }

  Future<void> playExample(String word) async {
    try {
      await _service.playExample(word);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to play example: $e');
    }
  }

  Future<void> startListening() async {
    try {
      await _service.startListening();
      state = state.copyWith(
        isListening: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _service.stopListening();
      state = state.copyWith(isListening: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to stop listening: $e');
    }
  }

  Future<void> checkPronunciation(String targetWord) async {
    try {
      state = state.copyWith(isCheckingComplete: false);
      final result = await _service.checkPronunciation(targetWord);
      state = state.copyWith(
        lastResult: result,
        isCheckingComplete: true,
        history: [...state.history, result],
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Check failed: $e');
    }
  }

  void reset() {
    state = const PronunciationState();
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
