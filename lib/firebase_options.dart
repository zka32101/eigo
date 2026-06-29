// このファイルは firebase_core の初期化に必要です。
// 実際の google-services.json を追加した後、
// `flutterfire configure` コマンドで上書きしてください。
//
// 現在は Firebase 未設定のため、初期化は graceful fallback で処理されます。

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  // TODO: `flutterfire configure` で実際の値に置き換えてください
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: '1:000000000000:android:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'eigo-kore-placeholder',
    storageBucket: 'eigo-kore-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: '1:000000000000:ios:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'eigo-kore-placeholder',
    storageBucket: 'eigo-kore-placeholder.appspot.com',
    iosClientId: 'PLACEHOLDER_CLIENT_ID',
    iosBundleId: 'com.petitworks.eigoKore',
  );
}
