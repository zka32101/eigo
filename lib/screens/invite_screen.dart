import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/coin_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  String _inviteCode = '';
  int _invitedCount = 0;
  bool _codeEntered = false;
  final _codeController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('my_invite_code') ?? '';
    if (code.isEmpty) {
      // ランダム生成（インストール時固定）
      code = _generateCode();
      await prefs.setString('my_invite_code', code);
    }
    final count = prefs.getInt('invite_count') ?? 0;
    setState(() {
      _inviteCode = code;
      _invitedCount = count;
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = StringBuffer();
    int n = now;
    for (int i = 0; i < 6; i++) {
      result.write(chars[n % chars.length]);
      n = (n ~/ chars.length) + (i * 7);
    }
    return result.toString();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _inviteCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コードをコピーしました！'), backgroundColor: kPrimaryColor),
      );
    }
  }

  Future<void> _enterCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) { setState(() => _errorMessage = 'コードを入力してください'); return; }
    if (code == _inviteCode) { setState(() => _errorMessage = '自分のコードは使えません'); return; }
    if (code.length != 6) { setState(() => _errorMessage = '6文字のコードを入力してください'); return; }

    final prefs = await SharedPreferences.getInstance();
    final usedCodes = prefs.getStringList('used_invite_codes') ?? [];
    if (usedCodes.contains(code)) { setState(() => _errorMessage = 'このコードは使用済みです'); return; }

    usedCodes.add(code);
    final newCount = _invitedCount + 1;
    await prefs.setStringList('used_invite_codes', usedCodes);
    await prefs.setInt('invite_count', newCount);

    // コイン報酬付与
    ref.read(coinProvider.notifier).addCoins(50);

    setState(() {
      _codeEntered = true;
      _invitedCount = newCount;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text('👫 ともだち招待'),
        backgroundColor: kAccentGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccentGreen, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('👫', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 8),
                  Text('ともだちを招待しよう！',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('招待コードを使うと\n🪙 50コインもらえる！',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 自分の招待コード
            const Text('📋 あなたの招待コード',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccentGreen, width: 2),
                boxShadow: [BoxShadow(color: kAccentGreen.withAlpha(40), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(
                    _inviteCode,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kAccentGreen,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _copyCode,
                      icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                      label: const Text('コードをコピー', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text('招待した人数: $_invitedCount 人',
              style: const TextStyle(fontSize: 13, color: kTextMuted)),

            const SizedBox(height: 24),

            // 招待コード入力
            const Text('🎁 友達のコードを入力',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 8),
            if (_codeEntered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kAccentGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kAccentGreen),
                ),
                child: const Column(
                  children: [
                    Text('✅', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text('コード適用完了！',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAccentGreen)),
                    SizedBox(height: 4),
                    Text('🪙 50コイン獲得！',
                      style: TextStyle(fontSize: 14, color: kAccentGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else ...[
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '6文字のコードを入力',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kAccentGreen, width: 2),
                  ),
                  errorText: _errorMessage,
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.vpn_key, color: kAccentGreen),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _enterCode,
                  child: const Text('コードを使う 🎁',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 特典説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 招待特典',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDark)),
                  SizedBox(height: 8),
                  _BenefitRow(emoji: '🪙', text: 'コードを入力すると 50コイン獲得'),
                  _BenefitRow(emoji: '👑', text: '5人招待でプレミアムバッジ獲得'),
                  _BenefitRow(emoji: '🎁', text: '招待された友達も 50コインもらえる'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _BenefitRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: kTextDark)),
      ],
    ),
  );
}
