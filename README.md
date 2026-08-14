# 闍ｱ隱槭さ繝ｬ・・(eigo-kore)

蟆丞ｭｦ逕溷髄縺代・ Flutter 闍ｱ隱槫ｭｦ鄙偵い繝励Μ縲ゅせ繝斐・繧ｭ繝ｳ繧ｰ繝ｻ逋ｺ髻ｳ繝√ぉ繝・け讖溯・繧堤音蛹悶＆縺帙、I莨夊ｩｱ縺ｫ繧医ｋ閾ｪ逕ｱ縺ｪ闍ｱ隱樒ｷｴ鄙偵ｒ繧ｵ繝昴・繝医＠縺ｾ縺吶・
## 識 迚ｹ蠕ｴ

- **80繧ｹ繝・・繧ｸ** 窶・谿ｵ髫守噪縺ｪ蟄ｦ鄙偵き繝ｪ繧ｭ繝･繝ｩ繝・・rades 1-6蟇ｾ蠢懊∬恭讀・邏壼ｯｾ蠢懶ｼ・- **1,676蝠・* 窶・繝ｪ繧ｹ繝九Φ繧ｰ繝ｻ繧ｹ繝斐・繧ｭ繝ｳ繧ｰ繝ｻ繝ｪ繝ｼ繝・ぅ繝ｳ繧ｰ繝ｻ繝ｩ繧､繝・ぅ繝ｳ繧ｰ縺ｮ4謚閭ｽ
- **逋ｺ髻ｳ繝√ぉ繝・け** 窶・Levenshtein霍晞屬縺ｫ繧医ｋ邊ｾ蟇・↑逋ｺ髻ｳ謗｡轤ｹ・・-100轤ｹ陦ｨ遉ｺ・・- **AI莨夊ｩｱ** 窶・Gemini繝ｻClaude API 縺ｫ繧医ｋ繝輔Μ繝ｼ繝医・繧ｯ邱ｴ鄙・- **繧ｹ繝・・繧ｸ蟆主・逕ｻ髱｢** 窶・蜷・せ繝・・繧ｸ縺ｮ蟄ｦ鄙貞燕縺ｫ縲後く繝ｼ繝ｯ繝ｼ繝峨・繝昴う繝ｳ繝医・萓区枚縲阪ｒ陦ｨ遉ｺ
- **隗｣遲碑ｪｬ譏・* 窶・豁｣隗｣蠕後↓縲檎匱髻ｳ繝ｻ譌･譛ｬ隱槭・蟄ｦ鄙偵ユ繧｣繝・・繧ｹ縲阪ｒ陦ｨ遉ｺ
- **500隱槭・隱槫ｽ吶き繝ｼ繝・* 窶・12繧ｫ繝・ざ繝ｪ縲・屮譏灘ｺｦ繝輔ぅ繝ｫ繧ｿ繝ｼ縲ゝTS蟇ｾ蠢・- **譛晞夂衍** 窶・豈取悃50繝輔Ξ繝ｼ繧ｺ縺ｮ闍ｱ隱槭ｒ閾ｪ蜍暮・菫｡

## 投 繧ｳ繝ｳ繝・Φ繝・ｦ乗ｨ｡

| 鬆・岼 | 蜀・ｮｹ |
|------|------|
| **繧ｹ繝・・繧ｸ** | 80譛ｬ |
| **邱丞撫鬘梧焚** | 1,676蝠・|
| **隱槫ｽ吶き繝ｼ繝・* | 500隱橸ｼ・2繧ｫ繝・ざ繝ｪ・・|
| **莨夊ｩｱ繧ｷ繝ｼ繝ｳ** | 59譛ｬ |
| **譛昴ヵ繝ｬ繝ｼ繧ｺ** | 50譛ｬ |

## 女・・謚陦薙せ繧ｿ繝・け

- **Frontend**: Flutter 3.11+
- **State Management**: Riverpod
- **Database**: Firebase Firestore + SharedPreferences
- **AI/ML**: 
  - Google Generative AI (Gemini 1.5 Flash)
  - Anthropic Claude API (繝輔か繝ｼ繝ｫ繝舌ャ繧ｯ)
- **Speech**: 
  - flutter_tts (Text-to-Speech)
  - speech_to_text (髻ｳ螢ｰ隱崎ｭ・
- **Storage**: flutter_secure_storage (API 繧ｭ繝ｼ證怜捷蛹・
- **Notifications**: flutter_local_notifications

## 刀 繝励Ο繧ｸ繧ｧ繧ｯ繝域ｧ区・

```
lib/
笏懌楳笏 main.dart                      窶・繧ｨ繝ｳ繝医Μ繝昴う繝ｳ繝医・繝ｫ繝ｼ繝亥ｮ夂ｾｩ
笏懌楳笏 screens/                       窶・UI逕ｻ髱｢
笏・  笏懌楳笏 home_screen.dart
笏・  笏懌楳笏 stage_select_screen.dart
笏・  笏懌楳笏 stage_intro_screen.dart    窶・繧ｹ繝・・繧ｸ蟆主・逕ｻ髱｢
笏・  笏懌楳笏 lesson_screen.dart         窶・繝ｬ繝・せ繝ｳ逕ｻ髱｢・郁ｧ｣遲碑ｪｬ譏惹ｻ倥″・・笏・  笏懌楳笏 result_screen.dart
笏・  笏懌楳笏 vocabulary_screen.dart     窶・隱槫ｽ吶き繝ｼ繝・笏・  笏懌楳笏 ai_freetalk_screen.dart
笏・  笏懌楳笏 pronunciation_check_screen.dart
笏・  笏披楳笏 settings_screen.dart
笏懌楳笏 models/
笏・  笏懌楳笏 stage.dart
笏・  笏懌楳笏 question.dart
笏・  笏披楳笏 user_profile.dart
笏懌楳笏 providers/                     窶・Riverpod state management
笏・  笏懌楳笏 progress_provider.dart
笏・  笏懌楳笏 level_provider.dart
笏・  笏懌楳笏 badge_provider.dart
笏・  笏懌楳笏 claude_conversation_provider.dart  窶・AI莨夊ｩｱ
笏・  笏懌楳笏 pronunciation_provider.dart
笏・  笏懌楳笏 ai_api_key_provider.dart   窶・API 繧ｭ繝ｼ邂｡逅・笏・  笏披楳笏 morning_notification_provider.dart
笏懌楳笏 services/
笏・  笏懌楳笏 speech_service.dart        窶・髻ｳ螢ｰ隱崎ｭ倥・謗｡轤ｹ
笏・  笏懌楳笏 tts_service.dart           窶・TTS
笏・  笏懌楳笏 gemini_service.dart        窶・Gemini API
笏・  笏懌楳笏 claude_api_service.dart    窶・Claude API
笏・  笏披楳笏 morning_notification_service.dart
笏懌楳笏 data/
笏・  笏懌楳笏 stage_data.dart            窶・80繧ｹ繝・・繧ｸ螳夂ｾｩ
笏・  笏懌楳笏 question_data*.dart        窶・1,676蝠上ョ繝ｼ繧ｿ
笏・  笏懌楳笏 vocabulary_data.dart       窶・500隱槭き繝ｼ繝・笏・  笏懌楳笏 conversation_data.dart     窶・59莨夊ｩｱ繧ｷ繝ｼ繝ｳ
笏・  笏懌楳笏 stage_intro_data.dart      窶・繧ｹ繝・・繧ｸ蟆主・繝・・繧ｿ
笏・  笏披楳笏 morning_phrase_data.dart   窶・譛昴ヵ繝ｬ繝ｼ繧ｺ
笏披楳笏 theme/
    笏披楳笏 app_theme.dart             窶・繝・じ繧､繝ｳ繧ｷ繧ｹ繝・Β
```

## 噫 繧ｻ繝・ヨ繧｢繝・・

### 蠢・育腸蠅・- Flutter 3.11+
- Dart 3.0+
- Android SDK 21+ / iOS 11+

### 繧､繝ｳ繧ｹ繝医・繝ｫ

```bash
git clone https://github.com/petitworksappsdev-hash/eigo-kore.git
cd eigo-kore
flutter pub get
flutter run
```

### Firebase 險ｭ螳・
1. Firebase Console 縺ｧ譁ｰ隕上・繝ｭ繧ｸ繧ｧ繧ｯ繝井ｽ懈・
2. `android/app/google-services.json` 繧帝・鄂ｮ
3. Firestore Database 繧貞・譛溷喧・医そ繧ｭ繝･繝ｪ繝・ぅ繝ｫ繝ｼ繝ｫ險ｭ螳夲ｼ・
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /progress/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### API 繧ｭ繝ｼ險ｭ螳・
繧｢繝励Μ蜀・瑚ｨｭ螳・> AI 繧ｭ繝ｼ險ｭ螳壹阪°繧我ｻ･荳九ｒ蜈･蜉幢ｼ・- **Gemini API Key**: https://aistudio.google.com/app/apikey
- **Claude API Key**: https://console.anthropic.com/account/keys

## 導 繝薙Ν繝・& 繝ｪ繝ｪ繝ｼ繧ｹ

### APK 繝薙Ν繝会ｼ・ndroid・・
```bash
flutter build apk --release
# 蜃ｺ蜉・ build/app/outputs/flutter-apk/app-release.apk (72.5MB)
```

### IPA 繝薙Ν繝会ｼ・OS・・
```bash
flutter build ios --release
# Xcode 縺ｧ Archive 竊・Export
```

### Google Play 縺ｸ縺ｮ繝ｪ繝ｪ繝ｼ繧ｹ

1. Google Play Console 縺ｫ繝ｭ繧ｰ繧､繝ｳ
2. 譁ｰ隕上い繝励Μ菴懈・
3. APK/AAB 繧偵い繝・・繝ｭ繝ｼ繝・4. 繧ｹ繝医い謗ｲ霈画ュ蝣ｱ・郁ｪｬ譏弱√せ繧ｯ繝ｪ繝ｼ繝ｳ繧ｷ繝ｧ繝・ヨ縲√・繝ｩ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ・峨ｒ蜈･蜉・5. 繝ｪ繝ｪ繝ｼ繧ｹ逕ｳ隲・
## 柏 繝励Λ繧､繝舌す繝ｼ & 繧ｻ繧ｭ繝･繝ｪ繝・ぅ

- **COPPA 貅匁侠**: 13謇肴悴貅繧貞ｯｾ雎｡縺ｨ縺励◆蟄舌←繧ょ髄縺代い繝励Μ
- **繝・・繧ｿ證怜捷蛹・*: API 繧ｭ繝ｼ縺ｯ flutter_secure_storage 縺ｧ證怜捷蛹・- **騾壻ｿ｡繧ｻ繧ｭ繝･繝ｪ繝・ぅ**: HTTPS 縺ｮ縺ｿ菴ｿ逕ｨ
- **繝励Λ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ**: [繝励Λ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ](./PRIVACY_POLICY.md)

## 投 遶ｶ蜷亥・譫・
| 繧｢繝励Μ | 蠑ｷ縺ｿ | eigo-kore 縺ｮ蟾ｮ蛻･蛹・|
|--------|------|-------------------|
| **繝√Ε繝ｬ繝ｳ繧ｸ繧､繝ｳ繧ｰ繝ｪ繝・す繝･** | 2,600繝ｬ繝・せ繝ｳ | 繧ｹ繝斐・繧ｭ繝ｳ繧ｰ繝ｻ逋ｺ髻ｳ繝√ぉ繝・け迚ｹ蛹・|
| **ECC Jr.** | 7,400隱・| AI莨夊ｩｱ讖溯・・域･ｭ逡悟・・・|
| **繝医ラ闍ｱ隱・* | 3,500繧｢繧ｯ繝・ぅ繝薙ユ繧｣ | 繧ｹ繝・・繧ｸ蟆主・繝ｻ隗｣遲碑ｪｬ譏主・螳・|
| **Duolingo** | 10,000+ | 蟆丞ｭｦ逕溷髄縺大ｰる摩繝ｻ繧ｹ繝斐・繧ｭ繝ｳ繧ｰ迚ｹ蛹・|

## 嶋 繝ｭ繝ｼ繝峨・繝・・

- [ ] v3.5: Web 迚亥ｯｾ蠢・& Chromebook 繧ｵ繝昴・繝・- [ ] v4.0: 謨呵ご譁ｽ險ｭ蜷代￠邂｡逅・判髱｢・亥・逕溽畑・・- [ ] v4.1: 繝槭Ν繝√・繝ｬ繧､繝､繝ｼ蟇ｾ謌ｦ繝｢繝ｼ繝・- [ ] v4.2: Advanced AI coaching・亥句挨蟄ｦ鄙偵・繝ｩ繝ｳ謠先｡茨ｼ・
## 塘 繝ｩ繧､繧ｻ繝ｳ繧ｹ

MIT License 窶・隧ｳ邏ｰ縺ｯ [LICENSE](./LICENSE) 繧貞盾辣ｧ

## 捉窶昨汳ｻ 髢狗匱閠・
****  
- GitHub: [@petitworksappsdev-hash](https://github.com/petitworksappsdev-hash)
- Email: zkaz83@gmail.com

## 到 繧ｵ繝昴・繝・
- 繝舌げ蝣ｱ蜻翫・讖溯・繝ｪ繧ｯ繧ｨ繧ｹ繝・ [GitHub Issues](https://github.com/petitworksappsdev-hash/eigo-kore/issues)
- 繝励Λ繧､繝舌す繝ｼ髢｢騾｣: zkaz83@gmail.com

---

**繝舌・繧ｸ繝ｧ繝ｳ**: v3.4  
**譛邨よ峩譁ｰ**: 2026-06-28  
**繧ｹ繝・・繧ｿ繧ｹ**: 噫 Ready for Release

