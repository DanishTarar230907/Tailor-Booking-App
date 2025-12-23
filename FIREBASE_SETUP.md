# Firebase Setup Guide

This guide will help you set up Firebase Authentication and Firestore for the Grace Tailor Studio app.

## Prerequisites

1. A Firebase account (create one at https://firebase.google.com/)
2. Flutter CLI installed
3. Firebase CLI installed (optional, but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "Grace Tailor Studio")
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

## Step 2: Add Firebase to Your Flutter App

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Detect your Firebase projects
   - Let you select which platforms to configure (iOS, Android, Web)
   - Generate `firebase_options.dart` file automatically

### Option B: Manual Configuration

#### For Web:

1. In Firebase Console, go to Project Settings > General
2. Scroll down to "Your apps" section
3. Click the Web icon (`</>`) to add a web app
4. Register your app with a nickname
5. Copy the Firebase configuration object

6. Update `lib/main.dart` to use the configuration:
   ```dart
   await Firebase.initializeApp(
     options: FirebaseOptions(
       apiKey: "YOUR_API_KEY",
       appId: "YOUR_APP_ID",
       messagingSenderId: "YOUR_SENDER_ID",
       projectId: "YOUR_PROJECT_ID",
       // Add other required fields
     ),
   );
   ```

#### For Android:

1. In Firebase Console, go to Project Settings
2. Click "Add app" and select Android
3. Register your app with package name (check `android/app/build.gradle`)
4. Download `google-services.json`
5. Place it in `android/app/` directory

#### For iOS:

1. In Firebase Console, go to Project Settings
2. Click "Add app" and select iOS
3. Register your app with bundle ID
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication** > **Get started**
2. Click on **Sign-in method** tab
3. Enable **Email/Password** authentication:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"

## Step 4: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development) or **Start in production mode** (for production)
4. Select a location for your database
5. Click "Enable"

### Firestore Security Rules

For development, you can use these rules (update for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own data
      allow read: if request.auth != null && request.auth.uid == userId;
      // Users can create their own document
      allow create: if request.auth != null && request.auth.uid == userId;
      // Users can update their own document
      allow update: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 5: Update main.dart (if using manual setup)

If you manually configured Firebase, update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // If using FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // If using FlutterFire CLI
  );
  
  runApp(const MyApp());
}
```

## Step 6: Install Dependencies

Run the following command to install all dependencies:

```bash
flutter pub get
```

## Step 7: Test the Setup

1. Run your app:
   ```bash
   flutter run
   ```

2. Try creating an account:
   - Select "Sign Up"
   - Enter email, password, name, and select a role (Tailor or Customer)
   - Click "Sign Up"

3. Verify in Firebase Console:
   - Check **Authentication** > **Users** - you should see the new user
   - Check **Firestore Database** > **users** collection - you should see user data with role

## Troubleshooting

### Error: "FirebaseApp not initialized"

- Make sure you've called `Firebase.initializeApp()` before using any Firebase services
- Check that `firebase_options.dart` exists (if using FlutterFire CLI)

### Error: "MissingPluginException"

- Run `flutter clean`
- Run `flutter pub get`
- Restart your app

### Web: "Firebase: No Firebase App '[DEFAULT]' has been created"

- Make sure Firebase is properly initialized
- For web, check browser console for additional errors
- Verify Firebase configuration in `index.html` (if needed)

### Authentication not working

- Verify Email/Password is enabled in Firebase Console
- Check Firestore security rules allow user creation
- Check browser/app console for error messages

## Production Considerations

1. **Security Rules**: Update Firestore security rules for production
2. **Email Verification**: Consider enabling email verification
3. **Password Reset**: The current implementation doesn't include password reset - you may want to add it
4. **Error Handling**: Review and improve error handling for production
5. **User Data**: Consider what additional user data you want to store in Firestore

## Additional Features You Can Add

- Password reset functionality
- Email verification
- Social authentication (Google, Facebook, etc.)
- User profile management
- Role-based access control in Firestore rules

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Review Flutter and Firebase documentation
3. Check the app's console output for detailed error messages

