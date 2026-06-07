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
    apiKey: 'AIzaSyCRVGxkh02cpJlK2pCPp2VhAQW1qAZcv78',
    appId: '1:960843443420:web:bc2a2706198a584efb5819',
    messagingSenderId: '960843443420',
    projectId: 'school-management-system-7644e',
    authDomain: 'school-management-system-7644e.firebaseapp.com',
    storageBucket: 'school-management-system-7644e.firebasestorage.app',
    measurementId: 'G-ZBZ76V9Q9C',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdA6aOZqbzSsVXw8sPRyKXDLkVo8XMA_8',
    appId: '1:960843443420:android:cac678d25e398775fb5819',
    messagingSenderId: '960843443420',
    projectId: 'school-management-system-7644e',
    storageBucket: 'school-management-system-7644e.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlGYZeNnkaDPWApA0o08HJS0-8D4W-SYo',
    appId: '1:960843443420:ios:079fc20ab41e997bfb5819',
    messagingSenderId: '960843443420',
    projectId: 'school-management-system-7644e',
    storageBucket: 'school-management-system-7644e.firebasestorage.app',
    iosBundleId: 'com.example.adminApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlGYZeNnkaDPWApA0o08HJS0-8D4W-SYo',
    appId: '1:960843443420:ios:079fc20ab41e997bfb5819',
    messagingSenderId: '960843443420',
    projectId: 'school-management-system-7644e',
    storageBucket: 'school-management-system-7644e.firebasestorage.app',
    iosBundleId: 'com.example.adminApp',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCRVGxkh02cpJlK2pCPp2VhAQW1qAZcv78',
    appId: '1:960843443420:web:99b6b787e72d48ddfb5819',
    messagingSenderId: '960843443420',
    projectId: 'school-management-system-7644e',
    authDomain: 'school-management-system-7644e.firebaseapp.com',
    storageBucket: 'school-management-system-7644e.firebasestorage.app',
    measurementId: 'G-VE61WEBMG7',
  );
}