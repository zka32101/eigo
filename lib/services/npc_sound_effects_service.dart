/// NPC サウンドエフェクトサービス
/// BGM、SE、音声合成を管理
class NPCSoundEffectsService {
  static final NPCSoundEffectsService _instance =
      NPCSoundEffectsService._internal();

  factory NPCSoundEffectsService.getInstance() {
    return _instance;
  }

  NPCSoundEffectsService._internal();

  /// サウンドエフェクトタイプ
  enum SoundEffectType {
    // UI SE
    buttonClick,      // ボタンクリック
    dialogueOpen,     // ダイアログ開く
    dialogueClose,    // ダイアログ閉じる
    textType,         // テキスト入力音
    notification,     // 通知音

    // ゲーム SE
    questAccept,      // クエスト受け入れ
    questComplete,    // クエスト完了
    skillAcquire,     // スキル習得
    levelUp,          // レベルアップ
    affectionChange,  // 親密度変化

    // スキル SE
    skillCast,        // スキル発動
    fireSpell,        // 炎系スキル
    waterSpell,       // 水系スキル
    windSpell,        // 風系スキル
    lightningSpell,   // 雷系スキル

    // 環境音
    ambience,         // 環境音
    footstep,         // 足音
  }

  /// 音量レベル
  enum VolumeLevel {
    mute,      // ミュート
    low,       // 小
    normal,    // 普通
    high,      // 大
    max,       // 最大
  }

  // 音量設定
  final Map<SoundEffectType, double> _volumeSettings = {
    SoundEffectType.buttonClick: 0.7,
    SoundEffectType.dialogueOpen: 0.5,
    SoundEffectType.dialogueClose: 0.5,
    SoundEffectType.textType: 0.3,
    SoundEffectType.notification: 0.8,
    SoundEffectType.questAccept: 0.8,
    SoundEffectType.questComplete: 0.9,
    SoundEffectType.skillAcquire: 0.9,
    SoundEffectType.levelUp: 0.9,
    SoundEffectType.affectionChange: 0.7,
    SoundEffectType.skillCast: 0.8,
    SoundEffectType.fireSpell: 0.8,
    SoundEffectType.waterSpell: 0.8,
    SoundEffectType.windSpell: 0.8,
    SoundEffectType.lightningSpell: 0.9,
    SoundEffectType.ambience: 0.4,
    SoundEffectType.footstep: 0.5,
  };

  // グローバル設定
  double _masterVolume = 1.0;
  double _seVolume = 1.0;
  double _bgmVolume = 0.8;
  double _voiceVolume = 1.0;

  bool _isMuted = false;

  /// サウンドエフェクトを再生
  Future<void> playSoundEffect(SoundEffectType type) async {
    if (_isMuted) return;

    final volume = _volumeSettings[type] ?? 0.5;
    final finalVolume = volume * _seVolume * _masterVolume;

    // 実装例：AudioManagerを使用してサウンドを再生
    // await _audioManager.play(
    //   soundId: type.toString(),
    //   volume: finalVolume,
    // );
  }

  /// スキル発動音を再生
  Future<void> playSkillSound(String skillType) async {
    if (_isMuted) return;

    SoundEffectType soundType;
    switch (skillType.toLowerCase()) {
      case 'fire':
      case 'fireball':
        soundType = SoundEffectType.fireSpell;
        break;
      case 'water':
      case 'ice':
        soundType = SoundEffectType.waterSpell;
        break;
      case 'wind':
        soundType = SoundEffectType.windSpell;
        break;
      case 'lightning':
      case 'thunder':
        soundType = SoundEffectType.lightningSpell;
        break;
      default:
        soundType = SoundEffectType.skillCast;
    }

    await playSoundEffect(soundType);
  }

  /// NPC 音声を再生
  Future<void> playNPCVoice(String npcId, String text) async {
    if (_isMuted) return;

    final volume = _voiceVolume * _masterVolume;

    // 実装例：Text-to-Speechエンジンを使用
    // await _ttsEngine.speak(
    //   text: text,
    //   voice: _getVoiceForNPC(npcId),
    //   volume: volume,
    // );
  }

  /// 背景音楽を再生
  Future<void> playBackgroundMusic(String musicName) async {
    if (_isMuted) return;

    final volume = _bgmVolume * _masterVolume;

    // 実装例：BGM再生
    // await _audioManager.playBGM(
    //   musicId: musicName,
    //   volume: volume,
    //   loop: true,
    // );
  }

  /// 背景音楽をフェードアウト
  Future<void> fadeOutBackgroundMusic({Duration duration = const Duration(seconds: 2)}) async {
    // 実装例：フェードアウト
    // await _audioManager.fadeBGM(
    //   duration: duration,
    //   endVolume: 0,
    // );
  }

  /// 背景音楽をフェードイン
  Future<void> fadeInBackgroundMusic({Duration duration = const Duration(seconds: 2)}) async {
    // 実装例：フェードイン
    // await _audioManager.fadeBGM(
    //   duration: duration,
    //   startVolume: 0,
    //   endVolume: _bgmVolume,
    // );
  }

  /// すべてのサウンドを停止
  Future<void> stopAllSounds() async {
    // 実装例
    // await _audioManager.stopAll();
  }

  /// マスターボリュームを設定
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0, 1);
  }

  /// SEボリュームを設定
  void setSEVolume(double volume) {
    _seVolume = volume.clamp(0, 1);
  }

  /// BGMボリュームを設定
  void setBGMVolume(double volume) {
    _bgmVolume = volume.clamp(0, 1);
  }

  /// 音声ボリュームを設定
  void setVoiceVolume(double volume) {
    _voiceVolume = volume.clamp(0, 1);
  }

  /// ボリュームレベルを設定
  void setVolumeLevel(VolumeLevel level) {
    switch (level) {
      case VolumeLevel.mute:
        _masterVolume = 0;
        break;
      case VolumeLevel.low:
        _masterVolume = 0.3;
        break;
      case VolumeLevel.normal:
        _masterVolume = 0.7;
        break;
      case VolumeLevel.high:
        _masterVolume = 0.9;
        break;
      case VolumeLevel.max:
        _masterVolume = 1.0;
        break;
    }
  }

  /// マスターボリュームを取得
  double getMasterVolume() {
    return _masterVolume;
  }

  /// SEボリュームを取得
  double getSEVolume() {
    return _seVolume;
  }

  /// BGMボリュームを取得
  double getBGMVolume() {
    return _bgmVolume;
  }

  /// 音声ボリュームを取得
  double getVoiceVolume() {
    return _voiceVolume;
  }

  /// ミュート状態を設定
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// ミュート状態を取得
  bool isMuted() {
    return _isMuted;
  }

  /// NPC 固有の音声を取得
  String _getVoiceForNPC(String npcId) {
    // NPCごとの音声を返す
    // 実装例：各NPCに異なるTTSボイスを割り当て
    return 'voice_${npcId.toLowerCase()}';
  }

  /// 個別サウンドエフェクトのボリュームを設定
  void setSoundEffectVolume(SoundEffectType type, double volume) {
    _volumeSettings[type] = volume.clamp(0, 1);
  }

  /// 個別サウンドエフェクトのボリュームを取得
  double getSoundEffectVolume(SoundEffectType type) {
    return _volumeSettings[type] ?? 0.5;
  }

  /// ボタンクリック音を再生
  Future<void> playButtonClickSound() async {
    await playSoundEffect(SoundEffectType.buttonClick);
  }

  /// ダイアログ開く音を再生
  Future<void> playDialogueOpenSound() async {
    await playSoundEffect(SoundEffectType.dialogueOpen);
  }

  /// ダイアログ閉じる音を再生
  Future<void> playDialogueCloseSound() async {
    await playSoundEffect(SoundEffectType.dialogueClose);
  }

  /// テキスト入力音を再生
  Future<void> playTextTypeSound() async {
    await playSoundEffect(SoundEffectType.textType);
  }

  /// 通知音を再生
  Future<void> playNotificationSound() async {
    await playSoundEffect(SoundEffectType.notification);
  }

  /// クエスト受け入れ音を再生
  Future<void> playQuestAcceptSound() async {
    await playSoundEffect(SoundEffectType.questAccept);
  }

  /// クエスト完了音を再生
  Future<void> playQuestCompleteSound() async {
    await playSoundEffect(SoundEffectType.questComplete);
  }

  /// スキル習得音を再生
  Future<void> playSkillAcquireSound() async {
    await playSoundEffect(SoundEffectType.skillAcquire);
  }

  /// レベルアップ音を再生
  Future<void> playLevelUpSound() async {
    await playSoundEffect(SoundEffectType.levelUp);
  }

  /// 親密度変化音を再生
  Future<void> playAffectionChangeSound(int affectionChange) async {
    if (affectionChange > 0) {
      await playSoundEffect(SoundEffectType.questComplete);
    } else if (affectionChange < 0) {
      await playSoundEffect(SoundEffectType.notification);
    }
  }

  /// リソースをクリーンアップ
  Future<void> dispose() async {
    await stopAllSounds();
  }
}
