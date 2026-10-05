// File generated for YODGAR Firebase project: yodgar-a348f
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

  // Web Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB2NhdSsImseQct04xkQhlP88zPRd249Ms',
    appId: '1:303804017142:web:678f7486eff3b5d9b0ffd7',
    messagingSenderId: '303804017142',
    projectId: 'yodgar-a348f',
    authDomain: 'yodgar-a348f.firebaseapp.com',
    databaseURL: 'https://yodgar-a348f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'yodgar-a348f.firebasestorage.app',
  );

  // Android Firebase configuration from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2NhdSsImseQct04xkQhlP88zPRd249Ms',
    appId: '1:303804017142:android:678f7486eff3b5d9b0ffd7',
    messagingSenderId: '303804017142',
    projectId: 'yodgar-a348f',
    databaseURL: 'https://yodgar-a348f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'yodgar-a348f.firebasestorage.app',
  );

  // iOS Firebase configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2NhdSsImseQct04xkQhlP88zPRd249Ms',
    appId: '1:303804017142:ios:678f7486eff3b5d9b0ffd7',
    messagingSenderId: '303804017142',
    projectId: 'yodgar-a348f',
    databaseURL: 'https://yodgar-a348f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'yodgar-a348f.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterApp',
  );

  // macOS Firebase configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2NhdSsImseQct04xkQhlP88zPRd249Ms',
    appId: '1:303804017142:ios:678f7486eff3b5d9b0ffd7',
    messagingSenderId: '303804017142',
    projectId: 'yodgar-a348f',
    databaseURL: 'https://yodgar-a348f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'yodgar-a348f.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterApp',
  );

  // Windows Firebase configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB2NhdSsImseQct04xkQhlP88zPRd249Ms',
    appId: '1:303804017142:web:678f7486eff3b5d9b0ffd7',
    messagingSenderId: '303804017142',
    projectId: 'yodgar-a348f',
    authDomain: 'yodgar-a348f.firebaseapp.com',
    databaseURL: 'https://yodgar-a348f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'yodgar-a348f.firebasestorage.app',
  );
}
