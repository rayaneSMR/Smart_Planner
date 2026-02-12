# Firebase Cloud Messaging Setup Guide

## Overview
Your Smart Planner app is now configured to receive **background notifications** even when the app is closed - just like Messenger!

## What Was Changed

### 1. **Dependencies Added**
   - `firebase_core`: Firebase initialization
   - `firebase_messaging`: Cloud Messaging for background notifications
   - `flutter_dotenv`: Safe environment variable management

### 2. **Android Configuration Updated**
   - Added FCM service in `AndroidManifest.xml`
   - Added necessary permissions (INTERNET, WAKE_LOCK)

### 3. **Notification Service Enhanced**
   - Integrated Firebase Cloud Messaging
   - Added background message handler
   - Device token management

### 4. **Main App Initialization**
   - Firebase initialized before app launch
   - Automatic listening for background notifications

## Next Steps: Complete Firebase Setup

### Step 1: Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: "smart_planner" (or your preferred name)
4. Continue through setup (disable Analytics is fine)

### Step 2: Add Android App to Firebase
1. In Firebase Console, click the Android icon
2. Set Package Name: `com.example.smart_planner` (or your package name)
3. Click "Register App"
4. **Download** `google-services.json`
5. Place it in: `android/app/`

### Step 3: Configure Firebase in Android
1. Open `android/build.gradle.kts` (root level)
2. Add to dependencies:
   ```gradle
   classpath("com.google.gms:google-services:4.3.15")
   ```

2. Open `android/app/build.gradle.kts`
3. At the **bottom**, add:
   ```gradle
   apply(plugin = "com.google.gms.google-services")
   ```

### Step 4: Set Firebase Credentials (Choose One)

#### Option A: Using .env file (Recommended for Development)
1. Copy `.env.example` to `.env`
   ```bash
   cp .env.example .env
   ```

2. Get your Firebase credentials:
   - Go to Project Settings in Firebase Console
   - Copy: API Key, App ID, Messaging Sender ID, Project ID
   
3. Edit `.env` and fill in your credentials:
   ```
   FIREBASE_API_KEY=your_actual_api_key_here
   FIREBASE_APP_ID=your_actual_app_id_here
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
   FIREBASE_PROJECT_ID=your_project_id_here
   ```

4. **⚠️ Important**: Add `.env` to `.gitignore` so it's not committed!

#### Option B: Direct Configuration
1. Edit `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase credentials

### Step 5: Install Dependencies
```bash
flutter pub get
```

### Step 6: Run the App
```bash
flutter run
```

## How It Works

### Notification Flow:

**App Closed (or in Background):**
1. Backend sends notification via Firebase Cloud Messaging
2. Android system receives it (even if app is killed!)
3. `_firebaseMessagingBackgroundHandler` is triggered
4. Local notification displays to user

**App Open (Foreground):**
1. Firebase message received
2. Custom foreground handler shows notification immediately

**User Taps Notification:**
1. App launches or comes to foreground
2. `onMessageOpenedApp` handler processes it

## Testing Background Notifications

### Option 1: Using Firebase Console
1. Go to Firebase Console → Messaging
2. Create new campaign
3. Select your app from Users segment
4. Send test message
5. **Close your app completely**
6. Watch notification appear!

### Option 2: Using your Backend Server
Send HTTP request to Firebase:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {ACCESS_TOKEN}" \
  -d '{
    "message": {
      "token": "DEVICE_TOKEN",
      "notification": {
        "title": "Task Reminder",
        "body": "Your task is due today"
      }
    }
  }'
```

## Device Token

Your app automatically retrieves and saves the device token which uniquely identifies this device.
- The token is saved locally in Hive
- Use it to send notifications from your backend
- Token refreshes automatically when needed

## Troubleshooting

### App Not Receiving Notifications?
1. Check `google-services.json` is in `android/app/`
2. Verify Firebase credentials in `firebase_options.dart` or `.env`
3. Ensure notifications are enabled in device settings
4. Check `flutter logs` for error messages

### Can't Find `google-services.json`?
1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Generate new private key (JSON)
4. Place in `android/app/`

### Still Not Working?
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run --verbose` to see detailed logs
4. Check Firebase Console for message delivery status

## Files Modified/Created

- ✅ `pubspec.yaml` - Added Firebase dependencies
- ✅ `lib/main.dart` - Firebase initialization
- ✅ `lib/firebase_options.dart` - Firebase configuration
- ✅ `lib/services/notification_service.dart` - FCM integration
- ✅ `android/app/src/main/AndroidManifest.xml` - FCM service
- ✅ `.env.example` - Configuration template
- ℹ️ `google-services.json` - **YOU NEED TO ADD THIS MANUALLY** from Firebase Console

## Support

For more information:
- [Firebase Cloud Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
