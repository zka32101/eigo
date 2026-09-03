import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingMd,
        child: SelectableText(
          '''英語コレ！プライバシーポリシー

最終更新日: 2026年1月1日

1. 収集する情報
本アプリは、音声認識機能（スピーキング練習）を使用するため、
マイクへのアクセス権限を使用します。
音声データはローカルで処理され、サーバーには送信されません。

2. データの保存
学習進捗データ（スコア、クリア状況等）は、
お使いの端末内にのみ保存されます。

3. 第三者への提供
収集した情報を第三者へ提供することはありません。

4. お問い合わせ
info@petitworks.example.com

5. 変更について
本ポリシーは予告なく変更される場合があります。''',
          style: AppTypography.bodySmall.copyWith(height: 1.7, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
