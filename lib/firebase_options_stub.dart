// Stub file for firebase_options.dart
// This file is used when firebase_options.dart doesn't exist yet
// After running `flutterfire configure`, this will be replaced by the generated file

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// import 'package:flutter/foundation.dart'
//    show defaultTargetPlatform, kIsWeb, TargetPlatform; // Unused

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured. Please run: dart pub global run flutterfire_cli:flutterfire configure',
    );
  }
}

