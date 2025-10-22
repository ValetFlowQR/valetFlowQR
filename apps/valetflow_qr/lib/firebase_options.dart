import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not supported with this manual config. Use flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS config not set up yet.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCTSWg1isO7d_zgSKeMTwIjB8NSp_gBU0o",
    appId: "1:835667889247:android:a8f8681fd2b2be81ea9fea",
    messagingSenderId: "835667889247",
    projectId: "valetflowqr-40544",
    storageBucket: "valetflowqr-40544.appspot.com",
  );
}
