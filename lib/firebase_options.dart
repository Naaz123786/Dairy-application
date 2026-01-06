// lib/firebase_options.dart
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA1KsIiXcOX4toT2nxsbjD_ZVtBbCIlqH4',
    appId: '1:356878048664:web:cb8fc9c3085c97953adfed',
    messagingSenderId: '356878048664',
    projectId: 'dairy-application-3db79',
    authDomain: 'dairy-application-3db79.firebaseapp.com',
    storageBucket: 'dairy-application-3db79.firebasestorage.app',
    measurementId: 'G-7G4DKPJN24',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVGNz0nyGvgHgoLKrFt2vMqvzat3n4zF0',
    appId: '1:356878048664:android:824012123a3aeb863adfed',
    messagingSenderId: '356878048664',
    projectId: 'dairy-application-3db79',
    storageBucket: 'dairy-application-3db79.firebasestorage.app',
  );
}
