import 'package:flutter/animation.dart';

/// NPC アニメーション管理サービス
/// NPCキャラクターの動作、表情、トランジションを管理
class NPCAnimationService {
  static final NPCAnimationService _instance = NPCAnimationService._internal();

  factory NPCAnimationService.getInstance() {
    return _instance;
  }

  NPCAnimationService._internal();

  /// アニメーションタイプ
  enum AnimationType {
    idle,           // アイドル状態
    talking,        // 話している
    happy,          // 喜んでいる
    sad,            // 悲しんでいる
    angry,          // 怒っている
    surprised,      // 驚いている
    thinking,       // 考えている
    greeting,       // 挨拶
    celebration,    // 祝っている
  }

  /// 感情表現タイプ
  enum EmotionType {
    neutral,
    happy,
    sad,
    angry,
    surprised,
    excited,
    confused,
    thinking,
  }

  /// アニメーションコントローラーのプール
  final Map<String, AnimationController> _animationControllers = {};

  /// キャラクター表情キャッシュ
  final Map<String, String> _characterExpressions = {};

  /// アニメーション継続時間（ミリ秒）
  static const int _shortAnimationDuration = 300;
  static const int _normalAnimationDuration = 500;
  static const int _longAnimationDuration = 1000;

  /// NPC キャラクターのアイドルアニメーションを取得
  ///
  /// 継続的に再生されるアニメーション
  Animation<double> getIdleAnimation(String npcId) {
    return Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.easeInOut,
        ));
  }

  /// 話し中のアニメーションを取得
  ///
  /// NPCが話している状態のアニメーション
  Animation<Offset> getTalkingAnimation(String npcId) {
    return Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 10),
    ).animate(CurvedAnimation(
      parent: AlwaysStoppedAnimation(0),
      curve: Curves.linear,
    ));
  }

  /// 感情表現アニメーションを取得
  Animation<double> getEmotionAnimation(
    String npcId,
    EmotionType emotion,
  ) {
    switch (emotion) {
      case EmotionType.happy:
        return Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(0),
              curve: Curves.easeOut,
            ));
      case EmotionType.sad:
        return Tween<double>(begin: 1, end: 0)
            .animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(0),
              curve: Curves.easeIn,
            ));
      case EmotionType.angry:
        return Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(0),
              curve: Curves.elasticIn,
            ));
      case EmotionType.surprised:
        return Tween<double>(begin: 0.5, end: 1)
            .animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(0),
              curve: Curves.bounceOut,
            ));
      case EmotionType.excited:
        return Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(0),
              curve: Curves.elasticOut,
            ));
      default:
        return AlwaysStoppedAnimation(0.5);
    }
  }

  /// ダイアログテキストのアニメーション効果を取得
  ///
  /// テキストが段階的に表示されるタイミング情報
  Duration getTextAnimationDelay(int characterIndex) {
    // 各文字が表示されるまでの遅延（ミリ秒）
    return Duration(milliseconds: characterIndex * 30);
  }

  /// ダイアログボックスの出現アニメーション
  Animation<double> getDialogueBoxAppearAnimation() {
    return Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.easeOut,
        ));
  }

  /// ダイアログボックスの消失アニメーション
  Animation<double> getDialogueBoxDisappearAnimation() {
    return Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.easeIn,
        ));
  }

  /// ボタンクリックアニメーション
  Animation<double> getButtonClickAnimation() {
    return Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.elasticOut,
        ));
  }

  /// スクリーントランジションアニメーション
  Animation<Offset> getScreenTransitionAnimation(bool isEntering) {
    if (isEntering) {
      return Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: AlwaysStoppedAnimation(0),
        curve: Curves.easeOut,
      ));
    } else {
      return Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).animate(CurvedAnimation(
        parent: AlwaysStoppedAnimation(0),
        curve: Curves.easeIn,
      ));
    }
  }

  /// クエスト完了アニメーション
  Animation<double> getQuestCompleteAnimation() {
    return Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.elasticOut,
        ));
  }

  /// スキル習得アニメーション
  Animation<double> getSkillAcquisitionAnimation() {
    return Tween<double>(begin: 0.5, end: 1)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.bounceOut,
        ));
  }

  /// 親密度表示アニメーション
  Animation<double> getAffectionDisplayAnimation(int affectionChange) {
    if (affectionChange > 0) {
      // 好意度増加：緑色で上昇
      return Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeOut,
          ));
    } else if (affectionChange < 0) {
      // 好意度低下：赤色で下降
      return Tween<double>(begin: 1, end: 0)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeIn,
          ));
    } else {
      // 変化なし
      return AlwaysStoppedAnimation(0.5);
    }
  }

  /// テキスト入力フォーカスアニメーション
  Animation<double> getTextInputFocusAnimation(bool isFocused) {
    if (isFocused) {
      return Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeOut,
          ));
    } else {
      return Tween<double>(begin: 1, end: 0)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeIn,
          ));
    }
  }

  /// リスト項目のアニメーション遅延
  Duration getListItemAnimationDelay(int index) {
    return Duration(milliseconds: 50 * index);
  }

  /// キャラクター表情を設定
  void setCharacterExpression(String npcId, String expression) {
    _characterExpressions[npcId] = expression;
  }

  /// キャラクター表情を取得
  String? getCharacterExpression(String npcId) {
    return _characterExpressions[npcId];
  }

  /// アニメーション継続時間を取得
  Duration getAnimationDuration(AnimationType type) {
    switch (type) {
      case AnimationType.idle:
      case AnimationType.thinking:
        return const Duration(milliseconds: _normalAnimationDuration);
      case AnimationType.talking:
        return const Duration(milliseconds: _longAnimationDuration);
      case AnimationType.happy:
      case AnimationType.surprised:
        return const Duration(milliseconds: _normalAnimationDuration);
      case AnimationType.sad:
      case AnimationType.angry:
        return const Duration(milliseconds: _longAnimationDuration);
      default:
        return const Duration(milliseconds: _normalAnimationDuration);
    }
  }

  /// ジェスチャーアニメーション（タップ反応）
  Animation<double> getGestureAnimation() {
    return Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.easeOut,
        ));
  }

  /// ローディングアニメーション（スピナー）
  Animation<double> getLoadingAnimation() {
    return Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(0),
          curve: Curves.linear,
        ));
  }

  /// スケールトランジション
  Animation<double> getScaleTransition(bool isEntering) {
    if (isEntering) {
      return Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.elasticOut,
          ));
    } else {
      return Tween<double>(begin: 1, end: 0)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeIn,
          ));
    }
  }

  /// フェードトランジション
  Animation<double> getFadeTransition(bool isEntering) {
    if (isEntering) {
      return Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeOut,
          ));
    } else {
      return Tween<double>(begin: 1, end: 0)
          .animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(0),
            curve: Curves.easeIn,
          ));
    }
  }

  /// リソースをクリーンアップ
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();
    _characterExpressions.clear();
  }
}
