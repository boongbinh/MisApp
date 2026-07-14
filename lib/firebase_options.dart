// File generated manually based on google-services.json & GoogleService-Info.plist
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android config (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAL7cvvB-2jytY5v5H79ME5mFHTBv1hsBQ',
    appId: '1:482660212159:android:9752a5c41c8a24e446d50a',
    messagingSenderId: '482660212159',
    projectId: 'testpushnoti-9e2a1',
    storageBucket: 'testpushnoti-9e2a1.firebasestorage.app',
  );

  // iOS config (from GoogleService-Info.plist)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHW6UyYnDgOMYsVN18LAJSyiZoApa81hI',
    appId: '1:482660212159:ios:d8f6f995c172be6d46d50a',
    messagingSenderId: '482660212159',
    projectId: 'testpushnoti-9e2a1',
    storageBucket: 'testpushnoti-9e2a1.firebasestorage.app',
    iosBundleId: 'skypec.mis.ios',
  );

  // macOS config (thường trùng với iOS)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHW6UyYnDgOMYsVN18LAJSyiZoApa81hI',
    appId: '1:482660212159:ios:d8f6f995c172be6d46d50a',
    messagingSenderId: '482660212159',
    projectId: 'testpushnoti-9e2a1',
    storageBucket: 'testpushnoti-9e2a1.firebasestorage.app',
    iosBundleId: 'skypec.mis.ios',
  );
}
