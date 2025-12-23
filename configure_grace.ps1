# Quick script to configure Flutter app with "grace" Firebase project
# Run this AFTER completing firebase login

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring Flutter app for 'grace' project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if firebase is logged in
Write-Host "Checking Firebase login status..." -ForegroundColor Yellow
$loginStatus = firebase login:list 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Firebase CLI is not logged in." -ForegroundColor Red
    Write-Host "Please run: firebase login" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit
}

Write-Host "✓ Firebase CLI is logged in" -ForegroundColor Green
Write-Host ""

# Run flutterfire configure
Write-Host "Running FlutterFire configuration..." -ForegroundColor Yellow
Write-Host "When prompted, select the 'grace' project (grace-9bb55)" -ForegroundColor Cyan
Write-Host ""

dart pub global run flutterfire_cli:flutterfire configure

Write-Host ""
Write-Host "Checking if firebase_options.dart was created..." -ForegroundColor Yellow

if (Test-Path "lib/firebase_options.dart") {
    Write-Host "✓ firebase_options.dart created successfully!" -ForegroundColor Green
    
    # Check if it contains the grace project
    $content = Get-Content "lib/firebase_options.dart" -Raw
    if ($content -match "grace-9bb55") {
        Write-Host "✓ Project ID 'grace-9bb55' found in configuration!" -ForegroundColor Green
    }
} else {
    Write-Host "✗ firebase_options.dart not found." -ForegroundColor Red
    Write-Host "Configuration may have failed. Please try again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to Firebase Console: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "2. Select 'grace' project" -ForegroundColor White
Write-Host "3. Enable Authentication > Email/Password" -ForegroundColor White
Write-Host "4. Create Firestore Database (if not already created)" -ForegroundColor White
Write-Host "5. Run: flutter run" -ForegroundColor White
Write-Host ""

