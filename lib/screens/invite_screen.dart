import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/coin_provider.dart';
import '../providers/progress_provider.dart';
import '../design_system/design_system.dart';

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
        const SnackBar(content: Text('コードをコピーしました！'), backgroundColor: AppColors.primary),
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
        backgroundColor: AppColors.accentGreen,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentGreen, AppColors.accentGreen.withAlpha(150)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
              child: Column(
                children: [
                  Text('👫', style: AppTypography.headlineLarge),
                  AppSpacing.verticalSpacerXs,
                  Text('ともだちを招待しよう！',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
                  AppSpacing.verticalSpacerXs,
                  Text('招待コードを使うと\n🪙 50コインもらえる！',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7))),
                ],
              ),
            ),

            AppSpacing.verticalSpacerLg,

            // 自分の招待コード
            Text('📋 あなたの招待コード',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.verticalSpacerXs,
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.accentGreen, width: 2),
                boxShadow: [BoxShadow(color: AppColors.accentGreen.withAlpha(40), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(
                    _inviteCode,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.accentGreen,
                      letterSpacing: 8,
                    ),
                  ),
                  AppSpacing.verticalSpacerSm,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                      ),
                      onPressed: _copyCode,
                      icon: const Icon(Icons.copy, color: AppColors.textWhite, size: 18),
                      label: const Text('コードをコピー', style: TextStyle(color: AppColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpacerXs,
            Text('招待した人数: $_invitedCount 人',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),

            AppSpacing.verticalSpacerLg,

            // 招待コード入力
            Text('🎁 友達のコードを入力',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.verticalSpacerXs,
            if (_codeEntered)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.accentGreen),
                ),
                child: Column(
                  children: [
                    Text('✅', style: AppTypography.headlineLarge),
                    AppSpacing.verticalSpacerXs,
                    Text('コード適用完了！',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.accentGreen)),
                    AppSpacing.verticalSpacerXs,
                    Text('🪙 50コイン獲得！',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.accentGreen)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
                  ),
                  errorText: _errorMessage,
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.textWhite,
                  prefixIcon: const Icon(Icons.vpn_key, color: AppColors.accentGreen),
                ),
                style: AppTypography.labelLarge.copyWith(
                  letterSpacing: 6,
                ),
              ),
              AppSpacing.verticalSpacerXs,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                  ),
                  onPressed: _enterCode,
                  child: Text('コードを使う 🎁',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
                ),
              ),
            ],

            AppSpacing.verticalSpacerLg,

            // 特典説明
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 招待特典',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                  AppSpacing.verticalSpacerXs,
                  const _BenefitRow(emoji: '🪙', text: 'コードを入力すると 50コイン獲得'),
                  const _BenefitRow(emoji: '👑', text: '5人招待でプレミアムバッジ獲得'),
                  const _BenefitRow(emoji: '🎁', text: '招待された友達も 50コインもらえる'),
                ],
              ),
            ),
            AppSpacing.verticalSpacerXl,
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
    padding: EdgeInsets.only(top: AppSpacing.xs),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        AppSpacing.horizontalSpacerXs,
        Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      ],
    ),
  );
}
