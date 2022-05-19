// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCiKIaOr7FF0yBljIj3NteS-SmLBrr9cqA',
    appId: '1:72984374240:web:e29b83939621fd005e1985',
    messagingSenderId: '72984374240',
    projectId: 'shopify-project-5c9b0',
    authDomain: 'shopify-project-5c9b0.firebaseapp.com',
    storageBucket: 'shopify-project-5c9b0.appspot.com',
    measurementId: 'G-8FHLEB7B7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD59ZMQp8z6rWwJTx4RcnCIqJit3blTGyI',
    appId: '1:72984374240:android:52b24936721be89e5e1985',
    messagingSenderId: '72984374240',
    projectId: 'shopify-project-5c9b0',
    storageBucket: 'shopify-project-5c9b0.appspot.com',
  );
}
