// ============================================================
// このファイルを編集してください！
//
// Firebase Console > プロジェクト設定 > マイアプリ > ウェブアプリ
// から firebaseConfig の値をコピーして以下に貼り付けてください。
//
// 設定例:
//   const firebaseConfig = {
//     apiKey: "AIza...",
//     authDomain: "your-project.firebaseapp.com",
//     projectId: "your-project",
//     storageBucket: "your-project.firebasestorage.app",
//     messagingSenderId: "123456789",
//     appId: "1:123456789:web:abcdef"
//   };
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Android は未設定です。firebase_options.dart を編集してください。');
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS は未設定です。firebase_options.dart を編集してください。');
      default:
        throw UnsupportedError(
          '${defaultTargetPlatform.name} は未対応です。',
        );
    }
  }

  // ▼▼▼ Firebase Console から値をコピーして置き換えてください ▼▼▼
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3MOskLhZhKgxN6FFWB6h9_vZzB3lUoBY',
    appId: '1:551767290923:web:2a80c613ca5408ec3e666e',
    messagingSenderId: '551767290923',
    projectId: 'garden-note-d9c5a',
    authDomain: 'garden-note-d9c5a.firebaseapp.com',
    storageBucket: 'garden-note-d9c5a.firebasestorage.app',
  );
  // ▲▲▲ Firebase Console から値をコピーして置き換えてください ▲▲▲
}
