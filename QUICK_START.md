# Quick Start Guide - Firebase Setup

## ⚡ Fastest Way to Set Up Firebase

### Step 1: Fix PowerShell Execution Policy (Windows Only)

If you see an error about "running scripts is disabled", run this in PowerShell **as Administrator**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 2: Login to Firebase

Open a terminal and run:

```bash
firebase login
```

This will open a browser for you to authenticate with your Google account.

### Step 3: Run Firebase Configuration

**Option A: Use the setup script (Recommended)**

Windows:
```powershell
.\setup_firebase.ps1
```

Linux/Mac:
```bash
chmod +x setup_firebase.sh
./setup_firebase.sh
```

**Option B: Manual configuration**

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

Follow the prompts:
1. Select your Firebase project (or create a new one)
2. Select platforms (web, android, ios) - at least select **web** for now
3. The script will generate `lib/firebase_options.dart` automatically

### Step 4: Enable Firebase Services

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. **Enable Authentication:**
   - Go to **Authentication** > **Get started**
   - Click **Sign-in method** tab
   - Enable **Email/Password**
   - Click **Save**

4. **Create Firestore Database:**
   - Go to **Firestore Database**
   - Click **Create database**
   - Choose **Start in test mode** (for development)
   - Select a location
   - Click **Enable**

### Step 5: Test the App

```bash
flutter run
```

You should see:
- Login/Signup screen
- Ability to create accounts with roles (Tailor/Customer)
- Automatic routing to the correct dashboard based on role

## ✅ Verification Checklist

- [ ] Firebase CLI installed and logged in
- [ ] `lib/firebase_options.dart` file exists
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Firestore database created
- [ ] App runs without Firebase errors
- [ ] Can create a new account
- [ ] Can login with created account
- [ ] Dashboard shows based on role

## 🆘 Troubleshooting

### "Firebase is not configured yet" error

- Make sure `lib/firebase_options.dart` exists
- If not, run: `dart pub global run flutterfire_cli:flutterfire configure`

### "FirebaseApp not initialized"

- Check that Firebase.initializeApp() is called in main.dart
- Verify firebase_options.dart has correct values

### Authentication errors

- Verify Email/Password is enabled in Firebase Console
- Check Firestore security rules allow user creation
- Check browser/app console for detailed error messages

### PowerShell script errors

- Run PowerShell as Administrator
- Set execution policy: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or run commands manually instead of using the script

## 📚 More Help

See `FIREBASE_SETUP.md` for detailed instructions and advanced configuration.

