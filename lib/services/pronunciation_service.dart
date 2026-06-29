import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/pronunciation_result.dart';

class PronunciationService {
  final _speechToText = stt.SpeechToText();
  final _tts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = '';

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<void> initialize() async {
    await _speechToText.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.8);
  }

  Future<void> playExample(String word) async {
    await _tts.speak(word);
  }

  Future<void> startListening() async {
    if (!_isListening && _speechToText.isAvailable) {
      _recognizedText = '';
      _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords.toLowerCase();
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
      _isListening = true;
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }

  Future<PronunciationResult> checkPronunciation(String targetWord) async {
    await stopListening();

    final userInput = _recognizedText.trim();
    final target = targetWord.toLowerCase().trim();

    // 簡易スコアリング
    double accuracy = _calculateAccuracy(userInput, target);
    String feedback = _generateFeedback(accuracy, target, userInput);

    return PronunciationResult(
      word: targetWord,
      userPronunciation: userInput.isNotEmpty ? userInput : '（認識できませんでした）',
      accuracy: accuracy,
      feedback: feedback,
      isPassed: accuracy >= 0.7,
    );
  }

  double _calculateAccuracy(String userInput, String target) {
    if (userInput.isEmpty) return 0.0;
    if (userInput == target) return 1.0;

    // 部分一致スコア
    int matchCount = 0;
    final userWords = userInput.split(' ');
    final targetWords = target.split(' ');

    for (var i = 0; i < targetWords.length; i++) {
      if (i < userWords.length && userWords[i] == targetWords[i]) {
        matchCount++;
      }
    }

    double wordAccuracy = matchCount / targetWords.length;

    // 文字列類似度（Levenshtein距離）
    double charAccuracy = _stringSimilarity(userInput, target);

    // 加重平均
    return (wordAccuracy * 0.6) + (charAccuracy * 0.4);
  }

  double _stringSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    int distance = _levenshteinDistance(a, b);
    int maxLen = a.length > b.length ? a.length : b.length;

    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String a, String b) {
    List<List<int>> dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) dp[i][0] = i;
    for (int j = 0; j <= b.length; j++) dp[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[a.length][b.length];
  }

  String _generateFeedback(double accuracy, String target, String userInput) {
    if (userInput.isEmpty) {
      return '音声が認識されませんでした。もう一度試してください。';
    }
    if (accuracy >= 0.95) {
      return 'パーフェクト！完璧な発音です！🌟';
    }
    if (accuracy >= 0.8) {
      return 'とても良い発音です！もう少しで完璧です。✅';
    }
    if (accuracy >= 0.6) {
      return '良い努力です！「$target」をもう一度試してみてください。';
    }
    if (accuracy >= 0.4) {
      return '頑張ってください！「$target」の発音をもう一度聞いて真似してみてね。';
    }
    return '「$target」と何かが違います。音声例をもう一度聞いてから試してください。💪';
  }

  void dispose() {
    _speechToText.stop();
    _tts.stop();
  }
}
