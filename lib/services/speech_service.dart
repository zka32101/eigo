import 'dart:math' as math;
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._();
  factory SpeechService() => _instance;
  SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _initialized = false;

  Future<bool> init() async {
    if (_initialized) return _available;
    _available = await _speech.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
    _initialized = true;
    return _available;
  }

  bool get isAvailable => _available;
  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_available) return;
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: 'en_US',
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  // 発音スコアを計算（0-100）
  int calculatePronunciationScore(String expected, String recognized) {
    if (recognized.isEmpty) return 0;

    final exp = expected.toLowerCase().trim().replaceAll(RegExp(r"[',!?.]"), '');
    final rec = recognized.toLowerCase().trim().replaceAll(RegExp(r"[',!?.]"), '');

    if (exp == rec) return 95 + math.Random().nextInt(6);

    final expWords = exp.split(' ');
    final recWords = rec.split(' ');
    int matched = 0;
    for (final word in expWords) {
      if (recWords.any((w) => _similarity(w, word) > 0.8)) matched++;
    }
    final wordAccuracy = matched / expWords.length;
    final charSim = _similarity(exp, rec);

    final score = ((wordAccuracy * 0.7 + charSim * 0.3) * 100).round();
    final jitter = math.Random().nextInt(7) - 3;
    return (score + jitter).clamp(0, 100);
  }

  double _similarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    final longer = s1.length > s2.length ? s1 : s2;
    final longerLength = longer.length;
    if (longerLength == 0) return 1.0;
    return (longerLength - _editDistance(longer, longer == s1 ? s2 : s1)) / longerLength.toDouble();
  }

  int _editDistance(String s1, String s2) {
    final len1 = s1.length, len2 = s2.length;
    final dp = List.generate(len1 + 1, (i) => List.generate(len2 + 1, (j) => 0));
    for (var i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        dp[i][j] = s1[i - 1] == s2[j - 1]
            ? dp[i - 1][j - 1]
            : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(math.min);
      }
    }
    return dp[len1][len2];
  }

  String getFeedback(int score) {
    if (score >= 90) return 'すばらしい！ネイティブのような発音です！🌟';
    if (score >= 80) return 'とても上手！もう少しで完璧です！😊';
    if (score >= 70) return 'いい感じ！もう一度練習してみよう！👍';
    if (score >= 60) return '惜しい！ゆっくり発音してみよう！🎯';
    if (score >= 40) return 'もう一度チャレンジ！聞いてから真似してみよう！💪';
    return 'もう一度聞いて、ゆっくり言ってみよう！🎧';
  }

  String getParentFeedback(int score, String word) {
    if (score >= 90) return '"$word" の発音は完璧です！';
    if (score >= 80) return '"$word" の発音はとても良いです。少し練習を続けましょう。';
    if (score >= 70) return '"$word" の発音は良いですが、もう少し練習が必要です。';
    if (score >= 60) return '"$word" の発音に課題があります。一緒に練習してあげてください。';
    return '"$word" の発音は改善が必要です。ゆっくり区切って練習しましょう。';
  }
}
