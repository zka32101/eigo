import 'package:shared_core/shared_core.dart';

/// 英語コレ！利用時間制限（スクリーンタイム管理） Notifier。
///
/// shared_core の [BaseScreenTimeNotifier] に接続する（`CharacterNotifier` と
/// 同じパターン）。デフォルトは「制限なし」（[ScreenTimeSettings.enabled] が
/// false）。保護者が設定画面（`ScreenTimeSettingsWidget`）でON/上限分数を
/// 設定するまでカウントのみ行い、制限はかからない。
///
/// main.dart で以下のように上書きする:
/// ```dart
/// screenTimeProvider.overrideWith(ScreenTimeNotifier.new)
/// ```
class ScreenTimeNotifier extends BaseScreenTimeNotifier {
  @override
  String get storageKey => 'eigo_screen_time';
}
