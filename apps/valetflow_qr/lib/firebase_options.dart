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
        throw UnsupportedError('iOS config not set up yet.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv5WWegWn2B9hVTKJfD68KDrNDvSwOHjI',
    appId: '1:835667889247:android:0a43f3fd423ecc63ea9fea',
    messagingSenderId: '835667889247',
    projectId: 'valetflowqr-40544',
    storageBucket: 'valetflowqr-40544.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTSWg1isO7d_zgSKeMTwIjB8NSp_gBU0o',
    appId: '1:835667889247:web:6d86da70f314e33dea9fea',
    messagingSenderId: '835667889247',
    projectId: 'valetflowqr-40544',
    authDomain: 'valetflowqr-40544.firebaseapp.com',
    storageBucket: 'valetflowqr-40544.firebasestorage.app',
  );

}