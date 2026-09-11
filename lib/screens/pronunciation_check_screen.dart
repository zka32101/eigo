import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/providers/premium_provider.dart';
import 'package:shared_core/widgets/premium_gate_widget.dart';

const _primaryColor = Colors.blue;

class PronunciationCheckScreen extends ConsumerStatefulWidget {
  const PronunciationCheckScreen({super.key});

  @override
  ConsumerState<PronunciationCheckScreen> createState() =>
      _PronunciationCheckScreenState();
}

class _PronunciationCheckScreenState
    extends ConsumerState<PronunciationCheckScreen> {
  bool _isRecording = false;
  bool _isChecking = false;
  PronunciationResult? _result;

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);

    if (!premiumState.isSubscribed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('発音判定'),
          centerTitle: true,
          backgroundColor: _primaryColor,
        ),
        body: PremiumGateWidget(
          featureName: 'リアルタイム発音判定',
          onPremiumAccess: () => _showSubscriptionDialog(context),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('発音判定'),
        centerTitle: true,
        backgroundColor: _primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 単語表示エリア
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '発音する単語',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'apple',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'りんご',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 音声入力ボタン
          SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: _isRecording || _isChecking ? null : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 32,
                    color: _isRecording || _isChecking
                        ? Colors.grey
                        : Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRecording
                        ? '録音中...'
                        : _isChecking
                            ? '判定中...'
                            : '🎤 録音開始',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isRecording || _isChecking
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 判定結果エリア
          if (_isChecking)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_primaryColor),
              ),
            )
          else if (_result != null)
            Column(
              children: [
                // スコア表示
                Card(
                  elevation: 2,
                  color: _getScoreColor(_result!.score),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '発音スコア',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_result!.score}%',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // フィードバック
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'フィードバック',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _result!.feedback,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // もう一度ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _result = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'もう一度試す',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // TODO: speech_to_text パッケージで音声入力
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isRecording = false;
      _isChecking = true;
    });

    // TODO: Claude API で発音判定
    await Future.delayed(const Duration(seconds: 2));

    // ダミー結果（本来は API レスポンスから取得）
    setState(() {
      _isChecking = false;
      _result = PronunciationResult(
        score: 85,
        feedback: 'とても良い発音です。特に「ア」に気をつけるとより完璧になります。',
      );
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Future<void> _showSubscriptionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プレミアム機能'),
        content: const Text(
          'リアルタイム発音判定は月額¥120のプレミアム会員向けです。'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: RevenueCat の購入フロー
            },
            child: const Text('今すぐ購読'),
          ),
        ],
      ),
    );
  }
}

/// 発音判定結果モデル
class PronunciationResult {
  final int score; // 0-100
  final String feedback;

  PronunciationResult({
    required this.score,
    required this.feedback,
  });
}
