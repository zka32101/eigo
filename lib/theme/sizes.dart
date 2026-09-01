/// eigo-kore アプリケーション全体で使用するサイズ定数
/// ボタン、アイコン、カード、その他の UI コンポーネントのサイズ
///
/// 使用例:
/// ```dart
/// ElevatedButton(
///   style: ElevatedButton.styleFrom(
///     minimumSize: Size.square(AppSizes.buttonHeight),
///   ),
///   child: ...
/// )
/// ```
class AppSizes {
  // ===== ボタン =====

  /// ボタンの標準高さ
  /// 用途: ElevatedButton, OutlinedButton
  static const double buttonHeight = 48.0;

  /// ボタンの小さい高さ
  /// 用途: 小さなボタン、インラインボタン
  static const double buttonHeightSmall = 40.0;

  /// ボタンの最小タップ対象サイズ（Material Design 3）
  static const double touchTargetMin = 48.0;

  // ===== アイコン =====

  /// アイコンの標準サイズ
  /// 用途: AppBar, ナビゲーション, リスト項目
  static const double iconSize = 24.0;

  /// アイコンの大きいサイズ
  /// 用途: ボタン内のアイコン、ハイライト要素
  static const double iconSizeLarge = 32.0;

  /// アイコンの小さいサイズ
  /// 用途: バッジ、小さなインジケータ
  static const double iconSizeSmall = 16.0;

  // ===== リスト・テーブル =====

  /// リスト項目の標準高さ
  /// 用途: ListTile, リスト行
  static const double listTileHeight = 56.0;

  /// リスト項目の大きい高さ
  /// 用途: 詳細情報付きのリスト項目
  static const double listTileHeightLarge = 72.0;

  /// リスト項目の小さい高さ
  /// 用途: コンパクトなリスト表示
  static const double listTileHeightSmall = 48.0;

  // ===== カード =====

  /// カードの標準角丸
  /// 用途: 大多数のカード
  static const double borderRadius = 12.0;

  /// カードの大きい角丸
  /// 用途: 強調されたカード、大きなカード
  static const double borderRadiusLarge = 16.0;

  /// カードの小さい角丸
  /// 用途: 小さなボタン、バッジ
  static const double borderRadiusSmall = 8.0;

  // ===== シャドウ =====

  /// 標準シャドウの高さ（elevation）
  static const double elevationStandard = 2.0;

  /// 高いシャドウ
  static const double elevationHigh = 4.0;

  /// 非常に高いシャドウ
  static const double elevationVeryHigh = 8.0;

  // ===== テキスト入力 =====

  /// テキスト入力フィールドの高さ
  static const double textFieldHeight = 56.0;

  /// テキスト入力フィールドの小さい高さ
  static const double textFieldHeightSmall = 48.0;

  /// テキスト入力フィールドの角丸
  static const double textFieldBorderRadius = 12.0;

  // ===== アバター・プロフィール =====

  /// アバター画像の標準サイズ
  static const double avatarSize = 48.0;

  /// アバター画像の大きいサイズ
  static const double avatarSizeLarge = 64.0;

  /// アバター画像の小さいサイズ
  static const double avatarSizeSmall = 32.0;

  // ===== ペット・イラスト =====

  /// ペットイラストの標準サイズ
  static const double petSize = 120.0;

  /// ペットイラストの大きいサイズ（詳細表示）
  static const double petSizeLarge = 200.0;

  /// ペットイラストの小さいサイズ（リスト表示）
  static const double petSizeSmall = 80.0;

  // ===== バッジ・チップ =====

  /// バッジの標準高さ
  static const double badgeHeight = 32.0;

  /// バッジの標準角丸
  static const double badgeBorderRadius = 16.0;

  // ===== ダイアログ =====

  /// ダイアログの標準幅（モバイル）
  static const double dialogWidth = 320.0;

  /// ダイアログの最大幅（タブレット）
  static const double dialogMaxWidth = 400.0;

  // ===== AppBar =====

  /// AppBar の標準高さ
  static const double appBarHeight = 56.0;

  /// AppBar 拡張時の高さ
  static const double appBarExpandedHeight = 120.0;

  // ===== BottomSheet =====

  /// BottomSheet のハンドル（つまみ）の高さ
  static const double bottomSheetHandleHeight = 4.0;

  /// BottomSheet のハンドルの幅
  static const double bottomSheetHandleWidth = 32.0;

  // ===== ディバイダー =====

  /// ディバイダー（区切り線）の高さ
  static const double dividerHeight = 1.0;

  /// ディバイダーの太い高さ
  static const double dividerHeightBold = 2.0;

  // ===== プログレスバー =====

  /// プログレスバーの高さ
  static const double progressBarHeight = 8.0;

  /// プログレスバーの太い高さ
  static const double progressBarHeightBold = 12.0;

  // ===== FAB（フローティングアクションボタン） =====

  /// FAB の標準サイズ
  static const double fabSize = 56.0;

  /// FAB の大きいサイズ
  static const double fabSizeLarge = 96.0;

  // ===== チップス・タグ =====

  /// チップの高さ
  static const double chipHeight = 32.0;

  /// チップの角丸
  static const double chipBorderRadius = 16.0;
}

/// レスポンシブブレークポイント定義
class Breakpoints {
  /// モバイル画面の最大幅
  /// < 360dp
  static const double mobile = 360;

  /// タブレット画面の最小幅
  /// >= 600dp
  static const double tablet = 600;

  /// デスクトップ画面の最小幅
  /// >= 1200dp
  static const double desktop = 1200;
}

/// BuildContext の拡張メソッド
/// レスポンシブデザインで画面サイズを判定
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// モバイル画面か判定
  bool get isMobile => screenWidth < Breakpoints.tablet;

  /// タブレット画面か判定
  bool get isTablet =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;

  /// デスクトップ画面か判定
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// 大画面（タブレット以上）か判定
  bool get isLargeScreen => screenWidth >= Breakpoints.tablet;
}
