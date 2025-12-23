# Firebase Setup Script for Grace Tailor Studio
# This script helps automate the Firebase setup process

# Check execution policy
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -eq "Restricted") {
    Write-Host "⚠️  PowerShell execution policy is Restricted" -ForegroundColor Yellow
    Write-Host "Run this command as Administrator to fix it:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run the commands manually (see QUICK_START.md)" -ForegroundColor Yellow
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase Setup for Grace Tailor Studio" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if FlutterFire CLI is installed
Write-Host "Checking FlutterFire CLI installation..." -ForegroundColor Yellow
$flutterfireInstalled = dart pub global list | Select-String "flutterfire_cli"

if (-not $flutterfireInstalled) {
    Write-Host "FlutterFire CLI not found. Installing..." -ForegroundColor Yellow
    dart pub global activate flutterfire_cli
    Write-Host "FlutterFire CLI installed successfully!" -ForegroundColor Green
} else {
    Write-Host "FlutterFire CLI is already installed." -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 1: Firebase Login" -ForegroundColor Cyan
Write-Host "You need to login to Firebase first." -ForegroundColor Yellow
Write-Host "Run this command: firebase login" -ForegroundColor White
Write-Host ""
$login = Read-Host "Have you logged in to Firebase? (y/n)"

if ($login -ne "y" -and $login -ne "Y") {
    Write-Host ""
    Write-Host "Please run 'firebase login' first, then run this script again." -ForegroundColor Red
    Write-Host "Or visit: https://console.firebase.google.com/ to create a project manually" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Step 2: Installing Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "Step 3: Configuring Firebase..." -ForegroundColor Cyan
Write-Host "This will generate firebase_options.dart automatically" -ForegroundColor Yellow
Write-Host ""

# Run flutterfire configure
dart pub global run flutterfire_cli:flutterfire configure

Write-Host ""
Write-Host "Step 4: Verifying setup..." -ForegroundColor Cyan

# Check if firebase_options.dart was created
if (Test-Path "lib/firebase_options.dart") {
    Write-Host "✓ firebase_options.dart created successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ firebase_options.dart not found. Setup may have failed." -ForegroundColor Red
    Write-Host "You may need to configure Firebase manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to Firebase Console: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "2. Enable Authentication > Email/Password" -ForegroundColor White
Write-Host "3. Create Firestore Database" -ForegroundColor White
Write-Host "4. Run 'flutter run' to test the app" -ForegroundColor White
Write-Host ""
Write-Host "Setup complete! Check FIREBASE_SETUP.md for detailed instructions." -ForegroundColor Green

