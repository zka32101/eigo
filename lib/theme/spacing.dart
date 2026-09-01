/// eigo-kore アプリケーション全体で使用するスペーシング定数
/// 8dp グリッドシステムに基づく統一されたスペーシング値
///
/// 使用例:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: ...
/// )
/// ```
class AppSpacing {
  // ===== 基本スペーシング =====

  /// 4dp - 非常に小さい間隔
  /// 用途: アイコンと隣接テキスト間、極小の余白
  static const double xs = 4.0;

  /// 8dp - 小さい間隔
  /// 用途: リスト項目内のアイテム間、ボタン内パディング
  static const double sm = 8.0;

  /// 12dp - 小中程度の間隔
  /// 用途: カード内の要素間、一般的な内部マージン
  static const double md = 12.0;

  /// 16dp - 標準間隔（最も一般的）
  /// 用途: 画面のパディング、カード間の間隔、セクション間隔
  static const double lg = 16.0;

  /// 20dp - 大きい間隔
  /// 用途: 主要セクション間の間隔
  static const double xl = 20.0;

  /// 24dp - 非常に大きい間隔
  /// 用途: 画面最上部のパディング、大きなセクション間隔
  static const double xxl = 24.0;

  /// 32dp - 極大間隔
  /// 用途: ヘッダーと本文の間隔、主要な区切り
  static const double xxxl = 32.0;

  // ===== EdgeInsets ショートカット =====

  /// パディング: 左右 lg (16dp)
  static const EdgeInsets horizontalPaddingLg = EdgeInsets.symmetric(horizontal: lg);

  /// パディング: 左右 md (12dp)
  static const EdgeInsets horizontalPaddingMd = EdgeInsets.symmetric(horizontal: md);

  /// パディング: 上下 lg (16dp)
  static const EdgeInsets verticalPaddingLg = EdgeInsets.symmetric(vertical: lg);

  /// パディング: 上下 md (12dp)
  static const EdgeInsets verticalPaddingMd = EdgeInsets.symmetric(vertical: md);

  /// パディング: 全て lg (16dp)
  static const EdgeInsets allPaddingLg = EdgeInsets.all(lg);

  /// パディング: 全て md (12dp)
  static const EdgeInsets allPaddingMd = EdgeInsets.all(md);

  /// パディング: 左右 lg + 上下 lg
  static const EdgeInsets symmetricPaddingLg = EdgeInsets.symmetric(horizontal: lg, vertical: lg);

  /// パディング: 左右 lg + 上下 md
  static const EdgeInsets symmetricPaddingMixed = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ===== SizedBox ショートカット =====

  /// 垂直スペーサー: 8dp
  static const SizedBox verticalSpacerSm = SizedBox(height: sm);

  /// 垂直スペーサー: 12dp
  static const SizedBox verticalSpacerMd = SizedBox(height: md);

  /// 垂直スペーサー: 16dp
  static const SizedBox verticalSpacerLg = SizedBox(height: lg);

  /// 垂直スペーサー: 20dp
  static const SizedBox verticalSpacerXl = SizedBox(height: xl);

  /// 垂直スペーサー: 24dp
  static const SizedBox verticalSpacerXxl = SizedBox(height: xxl);

  /// 水平スペーサー: 8dp
  static const SizedBox horizontalSpacerSm = SizedBox(width: sm);

  /// 水平スペーサー: 12dp
  static const SizedBox horizontalSpacerMd = SizedBox(width: md);

  /// 水平スペーサー: 16dp
  static const SizedBox horizontalSpacerLg = SizedBox(width: lg);
}
