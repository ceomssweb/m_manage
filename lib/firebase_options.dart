// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyB0tkB4AsOF4eaX1F0KFB_J9-gudwWGEA8',
    appId: '1:670181669030:web:036beb247f8650a9a31c67',
    messagingSenderId: '670181669030',
    projectId: 'mahalakshmi-traders-d7e14',
    authDomain: 'mahalakshmi-traders-d7e14.firebaseapp.com',
    databaseURL: 'https://mahalakshmi-traders-d7e14-default-rtdb.firebaseio.com',
    storageBucket: 'mahalakshmi-traders-d7e14.firebasestorage.app',
    measurementId: 'G-HKY5Z2NNJF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVhj_1qL0kl_W30OEInULA78yJwnrUVfU',
    appId: '1:670181669030:android:bb06bb5d93e2cd84a31c67',
    messagingSenderId: '670181669030',
    projectId: 'mahalakshmi-traders-d7e14',
    databaseURL: 'https://mahalakshmi-traders-d7e14-default-rtdb.firebaseio.com',
    storageBucket: 'mahalakshmi-traders-d7e14.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFuKRFldivQXWPPvpN5yVLb48SC_LAv9s',
    appId: '1:670181669030:ios:78df1232e71a5a22a31c67',
    messagingSenderId: '670181669030',
    projectId: 'mahalakshmi-traders-d7e14',
    databaseURL: 'https://mahalakshmi-traders-d7e14-default-rtdb.firebaseio.com',
    storageBucket: 'mahalakshmi-traders-d7e14.firebasestorage.app',
    iosClientId: '670181669030-dmalrgeqar8eakdquu2bfl62qkncllvc.apps.googleusercontent.com',
    iosBundleId: 'com.example.mManage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDFuKRFldivQXWPPvpN5yVLb48SC_LAv9s',
    appId: '1:670181669030:ios:78df1232e71a5a22a31c67',
    messagingSenderId: '670181669030',
    projectId: 'mahalakshmi-traders-d7e14',
    databaseURL: 'https://mahalakshmi-traders-d7e14-default-rtdb.firebaseio.com',
    storageBucket: 'mahalakshmi-traders-d7e14.firebasestorage.app',
    iosClientId: '670181669030-dmalrgeqar8eakdquu2bfl62qkncllvc.apps.googleusercontent.com',
    iosBundleId: 'com.example.mManage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB0tkB4AsOF4eaX1F0KFB_J9-gudwWGEA8',
    appId: '1:670181669030:web:25c4067b82f34ebda31c67',
    messagingSenderId: '670181669030',
    projectId: 'mahalakshmi-traders-d7e14',
    authDomain: 'mahalakshmi-traders-d7e14.firebaseapp.com',
    databaseURL: 'https://mahalakshmi-traders-d7e14-default-rtdb.firebaseio.com',
    storageBucket: 'mahalakshmi-traders-d7e14.firebasestorage.app',
    measurementId: 'G-B9V4Z1MDNS',
  );

}