import 'package:flutter/material.dart';

/// NPC パーティクルエフェクトサービス
/// スキル使用、クエスト完了などのビジュアルエフェクトを管理
class NPCParticleEffectsService {
  static final NPCParticleEffectsService _instance =
      NPCParticleEffectsService._internal();

  factory NPCParticleEffectsService.getInstance() {
    return _instance;
  }

  NPCParticleEffectsService._internal();

  /// エフェクトタイプ
  enum EffectType {
    sparkle,        // キラキラ
    star,           // 星
    heart,          // ハート
    fire,           // 炎
    water,          // 水
    wind,           // 風
    lightning,      // 雷
    magic,          // 魔法
    heal,           // 回復
    levelup,        // レベルアップ
    questComplete,  // クエスト完了
    skillAcquire,   // スキル習得
    emotion,        // 感情エフェクト
  }

  /// エフェクト設定
  class ParticleEffect {
    final EffectType type;
    final Offset position;
    final Color color;
    final Duration duration;
    final int particleCount;
    final double size;
    final double speed;

    ParticleEffect({
      required this.type,
      required this.position,
      required this.color,
      required this.duration,
      this.particleCount = 20,
      this.size = 8,
      this.speed = 1.0,
    });
  }

  /// スキル使用エフェクトを取得
  ParticleEffect getSkillEffectByType(
    String skillType,
    Offset position,
  ) {
    switch (skillType.toLowerCase()) {
      case 'fire':
      case 'fireball':
        return ParticleEffect(
          type: EffectType.fire,
          position: position,
          color: Colors.orange,
          duration: const Duration(milliseconds: 800),
          particleCount: 30,
          size: 10,
          speed: 1.5,
        );
      case 'water':
      case 'ice':
        return ParticleEffect(
          type: EffectType.water,
          position: position,
          color: Colors.blue,
          duration: const Duration(milliseconds: 800),
          particleCount: 25,
          size: 8,
          speed: 1.0,
        );
      case 'lightning':
      case 'thunder':
        return ParticleEffect(
          type: EffectType.lightning,
          position: position,
          color: Colors.yellow,
          duration: const Duration(milliseconds: 600),
          particleCount: 20,
          size: 6,
          speed: 2.0,
        );
      case 'magic':
      case 'spell':
        return ParticleEffect(
          type: EffectType.magic,
          position: position,
          color: Colors.purple,
          duration: const Duration(milliseconds: 1000),
          particleCount: 35,
          size: 7,
          speed: 1.2,
        );
      default:
        return ParticleEffect(
          type: EffectType.sparkle,
          position: position,
          color: Colors.amber,
          duration: const Duration(milliseconds: 700),
          particleCount: 20,
          size: 6,
          speed: 1.0,
        );
    }
  }

  /// クエスト完了エフェクト
  ParticleEffect getQuestCompleteEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.questComplete,
      position: position,
      color: Colors.green,
      duration: const Duration(milliseconds: 1200),
      particleCount: 40,
      size: 8,
      speed: 0.8,
    );
  }

  /// スキル習得エフェクト
  ParticleEffect getSkillAcquisitionEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.skillAcquire,
      position: position,
      color: Colors.lightBlue,
      duration: const Duration(milliseconds: 1500),
      particleCount: 50,
      size: 10,
      speed: 1.2,
    );
  }

  /// 回復エフェクト
  ParticleEffect getHealEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.heal,
      position: position,
      color: Colors.green,
      duration: const Duration(milliseconds: 900),
      particleCount: 25,
      size: 7,
      speed: 1.0,
    );
  }

  /// レベルアップエフェクト
  ParticleEffect getLevelUpEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.levelup,
      position: position,
      color: Colors.yellow,
      duration: const Duration(milliseconds: 1200),
      particleCount: 45,
      size: 9,
      speed: 1.3,
    );
  }

  /// 感情エフェクト（親密度変化）
  ParticleEffect getEmotionEffect(
    String emotion,
    Offset position,
  ) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'love':
        return ParticleEffect(
          type: EffectType.heart,
          position: position,
          color: Colors.red,
          duration: const Duration(milliseconds: 1000),
          particleCount: 15,
          size: 12,
          speed: 0.5,
        );
      case 'sad':
      case 'tears':
        return ParticleEffect(
          type: EffectType.water,
          position: position,
          color: Colors.blue,
          duration: const Duration(milliseconds: 800),
          particleCount: 10,
          size: 6,
          speed: 0.8,
        );
      case 'anger':
      case 'fire':
        return ParticleEffect(
          type: EffectType.fire,
          position: position,
          color: Colors.red,
          duration: const Duration(milliseconds: 600),
          particleCount: 20,
          size: 8,
          speed: 1.5,
        );
      case 'surprise':
      case 'stars':
        return ParticleEffect(
          type: EffectType.star,
          position: position,
          color: Colors.yellow,
          duration: const Duration(milliseconds: 700),
          particleCount: 25,
          size: 7,
          speed: 1.0,
        );
      default:
        return ParticleEffect(
          type: EffectType.sparkle,
          position: position,
          color: Colors.amber,
          duration: const Duration(milliseconds: 600),
          particleCount: 15,
          size: 6,
          speed: 0.8,
        );
    }
  }

  /// 親密度増加エフェクト（ハート）
  ParticleEffect getAffectionIncreaseEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.heart,
      position: position,
      color: Colors.pinkAccent,
      duration: const Duration(milliseconds: 1000),
      particleCount: 20,
      size: 10,
      speed: 0.6,
    );
  }

  /// ダイアログ選択肢選択エフェクト
  ParticleEffect getDialogueChoiceEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.sparkle,
      position: position,
      color: Colors.amber,
      duration: const Duration(milliseconds: 500),
      particleCount: 12,
      size: 5,
      speed: 1.0,
    );
  }

  /// NPC出現エフェクト
  ParticleEffect getNPCAppearEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.magic,
      position: position,
      color: Colors.purpleAccent,
      duration: const Duration(milliseconds: 800),
      particleCount: 30,
      size: 8,
      speed: 1.2,
    );
  }

  /// NPC消失エフェクト
  ParticleEffect getNPCDisappearEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.wind,
      position: position,
      color: Colors.grey,
      duration: const Duration(milliseconds: 600),
      particleCount: 25,
      size: 7,
      speed: 0.9,
    );
  }

  /// ボタンホバーエフェクト
  ParticleEffect getButtonHoverEffect(Offset position) {
    return ParticleEffect(
      type: EffectType.sparkle,
      position: position,
      color: Colors.amber,
      duration: const Duration(milliseconds: 300),
      particleCount: 8,
      size: 4,
      speed: 0.5,
    );
  }

  /// エフェクトの色を取得
  Color getEffectColor(EffectType type) {
    switch (type) {
      case EffectType.sparkle:
        return Colors.amber;
      case EffectType.star:
        return Colors.yellow;
      case EffectType.heart:
        return Colors.red;
      case EffectType.fire:
        return Colors.orange;
      case EffectType.water:
        return Colors.blue;
      case EffectType.wind:
        return Colors.grey;
      case EffectType.lightning:
        return Colors.yellow;
      case EffectType.magic:
        return Colors.purple;
      case EffectType.heal:
        return Colors.green;
      case EffectType.levelup:
        return Colors.cyan;
      case EffectType.questComplete:
        return Colors.green;
      case EffectType.skillAcquire:
        return Colors.lightBlue;
      case EffectType.emotion:
        return Colors.pink;
    }
  }

  /// エフェクトの継続時間を取得
  Duration getEffectDuration(EffectType type) {
    switch (type) {
      case EffectType.sparkle:
        return const Duration(milliseconds: 500);
      case EffectType.fire:
      case EffectType.lightning:
        return const Duration(milliseconds: 600);
      case EffectType.magic:
      case EffectType.questComplete:
        return const Duration(milliseconds: 1000);
      case EffectType.skillAcquire:
      case EffectType.levelup:
        return const Duration(milliseconds: 1200);
      case EffectType.heart:
        return const Duration(milliseconds: 800);
      default:
        return const Duration(milliseconds: 700);
    }
  }

  /// エフェクトのパーティクル数を取得
  int getParticleCount(EffectType type) {
    switch (type) {
      case EffectType.sparkle:
      case EffectType.star:
        return 20;
      case EffectType.heart:
      case EffectType.fire:
        return 25;
      case EffectType.water:
      case EffectType.wind:
        return 15;
      case EffectType.lightning:
        return 20;
      case EffectType.magic:
        return 30;
      case EffectType.heal:
        return 25;
      case EffectType.levelup:
        return 40;
      case EffectType.questComplete:
        return 35;
      case EffectType.skillAcquire:
        return 45;
      case EffectType.emotion:
        return 20;
    }
  }

  /// 複合エフェクトを取得（複数のエフェクトを同時実行）
  List<ParticleEffect> getCombinedEffect(
    List<EffectType> types,
    Offset position,
  ) {
    return types
        .map((type) => ParticleEffect(
              type: type,
              position: position,
              color: getEffectColor(type),
              duration: getEffectDuration(type),
              particleCount: getParticleCount(type),
            ))
        .toList();
  }

  /// エフェクトのサイズを取得
  double getEffectSize(EffectType type) {
    switch (type) {
      case EffectType.heart:
        return 12;
      case EffectType.star:
        return 10;
      case EffectType.fire:
      case EffectType.magic:
        return 9;
      case EffectType.lightning:
        return 8;
      default:
        return 6;
    }
  }

  /// エフェクトの速度を取得
  double getEffectSpeed(EffectType type) {
    switch (type) {
      case EffectType.lightning:
        return 2.0;
      case EffectType.fire:
      case EffectType.magic:
        return 1.5;
      case EffectType.water:
      case EffectType.wind:
        return 1.0;
      case EffectType.heart:
        return 0.5;
      default:
        return 0.8;
    }
  }
}
