// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Default FirebaseOptions for current platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:web:07c246c9e4b43698eabdd9',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    authDomain: 'devbalance-app-27ba3.firebaseapp.com',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
    measurementId: 'G-CJGZ18LMDY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:android:your-android-app-id',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:ios:your-ios-app-id',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
    iosBundleId: 'com.example.devbalance',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:macos:your-macos-app-id',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:windows:your-windows-app-id',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBKi_NZPBKGYlzTwzS8MUvlFzOR_f3kHZE',
    appId: '1:540426320412:linux:your-linux-app-id',
    messagingSenderId: '540426320412',
    projectId: 'devbalance-app-27ba3',
    storageBucket: 'devbalance-app-27ba3.firebasestorage.app',
  );
}
