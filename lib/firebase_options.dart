import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyC9IlkcllbNY6d10XB0dH8JcYtvsweo5_4',
    appId: '1:270573902154:web:1329e58e467987572f49b3',
    messagingSenderId: '270573902154',
    projectId: 'poeage-hub',
    authDomain: 'poeage-hub.firebaseapp.com',
    storageBucket: 'poeage-hub.firebasestorage.app',
    measurementId: 'G-NCS5GFMS0J',
  );

  // Replace these placeholder values with your actual Firebase configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC55hcVdkjLnDL7FBiVkHRXCTq75EwN0Ro',
    appId: '1:270573902154:android:e994b69a7322128f2f49b3',
    messagingSenderId: '270573902154',
    projectId: 'poeage-hub',
    storageBucket: 'poeage-hub.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlfyhZdYuzQxoWxIvXpFnf69nrokNsp0s',
    appId: '1:270573902154:ios:6b161644ccb69ebe2f49b3',
    messagingSenderId: '270573902154',
    projectId: 'poeage-hub',
    storageBucket: 'poeage-hub.firebasestorage.app',
    androidClientId: '270573902154-b168p9q5v70iamt7r48ls2e52ahhk2j0.apps.googleusercontent.com',
    iosClientId: '270573902154-pthhf1cba1easjbnv989kg3p5493i8iv.apps.googleusercontent.com',
    iosBundleId: 'com.example.sellerpanel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlfyhZdYuzQxoWxIvXpFnf69nrokNsp0s',
    appId: '1:270573902154:ios:6b161644ccb69ebe2f49b3',
    messagingSenderId: '270573902154',
    projectId: 'poeage-hub',
    storageBucket: 'poeage-hub.firebasestorage.app',
    androidClientId: '270573902154-b168p9q5v70iamt7r48ls2e52ahhk2j0.apps.googleusercontent.com',
    iosClientId: '270573902154-pthhf1cba1easjbnv989kg3p5493i8iv.apps.googleusercontent.com',
    iosBundleId: 'com.example.sellerpanel',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9IlkcllbNY6d10XB0dH8JcYtvsweo5_4',
    appId: '1:270573902154:web:cbd9464a7c85653c2f49b3',
    messagingSenderId: '270573902154',
    projectId: 'poeage-hub',
    authDomain: 'poeage-hub.firebaseapp.com',
    storageBucket: 'poeage-hub.firebasestorage.app',
    measurementId: 'G-4TVSRD3T8Z',
  );

}