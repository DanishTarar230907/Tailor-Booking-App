#!/bin/bash

# Firebase Setup Script for Grace Tailor Studio
# This script helps automate the Firebase setup process

echo "========================================"
echo "Firebase Setup for Grace Tailor Studio"
echo "========================================"
echo ""

# Check if FlutterFire CLI is installed
echo "Checking FlutterFire CLI installation..."
if ! dart pub global list | grep -q "flutterfire_cli"; then
    echo "FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
    echo "FlutterFire CLI installed successfully!"
else
    echo "FlutterFire CLI is already installed."
fi

echo ""
echo "Step 1: Firebase Login"
echo "You need to login to Firebase first."
echo "Run this command: firebase login"
echo ""
read -p "Have you logged in to Firebase? (y/n) " login

if [ "$login" != "y" ] && [ "$login" != "Y" ]; then
    echo ""
    echo "Please run 'firebase login' first, then run this script again."
    echo "Or visit: https://console.firebase.google.com/ to create a project manually"
    exit 1
fi

echo ""
echo "Step 2: Installing Flutter dependencies..."
flutter pub get

echo ""
echo "Step 3: Configuring Firebase..."
echo "This will generate firebase_options.dart automatically"
echo ""

# Run flutterfire configure
dart pub global run flutterfire_cli:flutterfire configure

echo ""
echo "Step 4: Verifying setup..."

# Check if firebase_options.dart was created
if [ -f "lib/firebase_options.dart" ]; then
    echo "✓ firebase_options.dart created successfully!"
else
    echo "✗ firebase_options.dart not found. Setup may have failed."
    echo "You may need to configure Firebase manually."
fi

echo ""
echo "Next Steps:"
echo "1. Go to Firebase Console: https://console.firebase.google.com/"
echo "2. Enable Authentication > Email/Password"
echo "3. Create Firestore Database"
echo "4. Run 'flutter run' to test the app"
echo ""
echo "Setup complete! Check FIREBASE_SETUP.md for detailed instructions."

