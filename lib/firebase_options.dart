import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase Web SDK config for the "DYOS Web" app registered in the
/// dyos-520c2 Firebase project (Firebase console > Project settings > Your apps).
///
/// Android and iOS read their config from native `google-services.json` /
/// `GoogleService-Info.plist` and never use this class — web has no such
/// native config file, so `Firebase.initializeApp()` needs it explicitly,
/// otherwise it throws before the app can render anything.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAogCPm1zPJ6y8eYF25mAIy6c6HO1Ycg6A',
    appId: '1:112080403338:web:fccb37953fd8f13669a673',
    messagingSenderId: '112080403338',
    projectId: 'dyos-520c2',
    authDomain: 'dyos-520c2.firebaseapp.com',
    storageBucket: 'dyos-520c2.firebasestorage.app',
    measurementId: 'G-NF4H6Y5MLE',
  );
}
