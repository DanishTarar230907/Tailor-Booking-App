# Configure "grace" Firebase Project

Since you already have the "grace" project (ID: grace-9bb55) in Firebase Console, here's how to connect it to your Flutter app.

## Option 1: Using FlutterFire CLI (Recommended)

### Step 1: Login to Firebase CLI

Open a terminal and run:
```bash
firebase login
```

This will open a browser. Sign in with the same Google account you use for Firebase Console.

### Step 2: Configure Flutter App

Run:
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

When prompted:
1. **Select existing project** - Choose "grace" (grace-9bb55)
2. **Select platforms** - Choose at least **web** (you can add android/ios later)
3. The script will generate `lib/firebase_options.dart` automatically

## Option 2: Manual Configuration (If CLI doesn't work)

### Step 1: Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the **"grace"** project
3. Click the **gear icon** ⚙️ next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **"Your apps"** section
6. If you don't have a web app yet:
   - Click the **Web icon** (`</>`)
   - Register app with nickname: "Grace Tailor Studio Web"
   - Copy the configuration

### Step 2: Create firebase_options.dart

Create `lib/firebase_options.dart` with this template:

```dart
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY_FROM_CONSOLE',
    appId: 'YOUR_WEB_APP_ID_FROM_CONSOLE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grace-9bb55',
    authDomain: 'grace-9bb55.firebaseapp.com',
    storageBucket: 'grace-9bb55.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grace-9bb55',
    storageBucket: 'grace-9bb55.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grace-9bb55',
    storageBucket: 'grace-9bb55.appspot.com',
    iosBundleId: 'com.example.grace',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'grace-9bb55',
    storageBucket: 'grace-9bb55.appspot.com',
    iosBundleId: 'com.example.grace',
  );
}
```

**Replace the placeholder values** with actual values from Firebase Console:
- `apiKey`: Found in Firebase Console > Project Settings > Your apps > Web app config
- `appId`: Found in same location
- `messagingSenderId`: Found in same location (usually same for all platforms)
- `projectId`: `grace-9bb55` (you already have this)
- `authDomain`: `grace-9bb55.firebaseapp.com`
- `storageBucket`: `grace-9bb55.appspot.com`

## Step 3: Enable Required Services

Make sure these are enabled in your "grace" project:

### Enable Authentication
1. In Firebase Console, select "grace" project
2. Go to **Authentication** > **Get started**
3. Click **Sign-in method** tab
4. Enable **Email/Password**
5. Click **Save**

### Create Firestore Database
1. Go to **Firestore Database**
2. If not created, click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location
5. Click **Enable**

## Step 4: Test

Run your app:
```bash
flutter run
```

The app should now connect to your "grace" Firebase project!

## Quick Check

After configuration, verify:
- ✅ `lib/firebase_options.dart` exists
- ✅ File contains `projectId: 'grace-9bb55'`
- ✅ Authentication enabled in Firebase Console
- ✅ Firestore Database created

