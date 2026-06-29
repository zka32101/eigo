import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text, {double rate = 0.5}) async {
    await init();
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  Future<void> speakSlow(String text) => speak(text, rate: 0.35);

  Future<void> stop() async {
    await _tts.stop();
  }
}
