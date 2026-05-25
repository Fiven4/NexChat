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
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHL5nku5ri8PSMVEyJySoktUBQ0ovuRqY',
    appId: '1:221389920736:web:3077cb951c9ba188f13385',
    messagingSenderId: '221389920736',
    projectId: 'messenger-b40c3',
    authDomain: 'messenger-b40c3.firebaseapp.com',
    storageBucket: 'messenger-b40c3.firebasestorage.app',
    measurementId: 'G-1LE1F00FD5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1HWr-uqUGmChKsh-sNH2YmCYuljKe4dQ',
    appId: '1:221389920736:android:271efc2c88e5c2d4f13385',
    messagingSenderId: '221389920736',
    projectId: 'messenger-b40c3',
    storageBucket: 'messenger-b40c3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkR6SABsD9__LIPqiCHdZ7pDFO1Pf8Ujc',
    appId: '1:221389920736:ios:a42c1e70d21c2266f13385',
    messagingSenderId: '221389920736',
    projectId: 'messenger-b40c3',
    storageBucket: 'messenger-b40c3.firebasestorage.app',
    iosBundleId: 'com.example.messenger',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkR6SABsD9__LIPqiCHdZ7pDFO1Pf8Ujc',
    appId: '1:221389920736:ios:a42c1e70d21c2266f13385',
    messagingSenderId: '221389920736',
    projectId: 'messenger-b40c3',
    storageBucket: 'messenger-b40c3.firebasestorage.app',
    iosBundleId: 'com.example.messenger',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCHL5nku5ri8PSMVEyJySoktUBQ0ovuRqY',
    appId: '1:221389920736:web:f155f46ac05f8f21f13385',
    messagingSenderId: '221389920736',
    projectId: 'messenger-b40c3',
    authDomain: 'messenger-b40c3.firebaseapp.com',
    storageBucket: 'messenger-b40c3.firebasestorage.app',
    measurementId: 'G-LTVRFMQ1Y5',
  );
}