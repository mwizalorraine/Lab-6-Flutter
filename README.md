# FCM Push Notifications - Lab 6

A Flutter application demonstrating Firebase Cloud Messaging (FCM) push notifications.

## Features

- **Request notification permission** from the user
- **Display FCM device token** on screen with copy button
- **Receive push notifications** in all app states:
  - Foreground (with popup dialog + local notification)
  - Background (notification in system tray)
  - Terminated (opens app from notification)
- **Display received messages** in a scrollable list inside the app UI
- **Show a popup dialog** when a notification is received while app is open

---

## Setup Guide (Step by Step)

### Prerequisites

- Flutter SDK installed (3.5+)
- A real Android device (FCM doesn't work reliably on emulators)
- A Google account for Firebase Console
- Node.js installed (for FlutterFire CLI)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project** → name it (e.g., `fcm-push-lab6`)
3. Disable Google Analytics (optional) → **Create Project**

### Step 2: Add Android App to Firebase

1. In Firebase Console → click **Android icon** to add an Android app
2. Package name: `com.example.fcm_push_app`
3. App nickname: `FCM Push App`
4. Click **Register App**
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`
7. Click **Continue** through the remaining steps

### Step 3: Configure with FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Run in the project root directory
flutterfire configure
```

This will:
- Auto-detect your Firebase project
- Generate `lib/firebase_options.dart` with your real config
- Place `google-services.json` in the correct location

> **Note:** The `lib/firebase_options.dart` included in this repo is a PLACEHOLDER.
> You MUST run `flutterfire configure` to replace it with your actual Firebase config.

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Run on a Real Device

```bash
# Connect your phone via USB (enable USB debugging)
flutter run
```

### Step 6: Get the Device Token

When the app launches:
1. **Allow** notification permission when prompted
2. The FCM token will appear on screen
3. Tap the **copy icon** to copy it
4. The token is also printed in the debug console

### Step 7: Send a Test Notification from Firebase

1. Go to **Firebase Console** → your project
2. Navigate to **Engage** → **Messaging** (Cloud Messaging)
3. Click **Create your first campaign** → **Firebase Notification messages**
4. Fill in:
   - **Notification title:** `Hello from Firebase`
   - **Notification text:** `Test Notification`
5. Click **Send test message**
6. Paste the **FCM token** you copied from the app
7. Click **Test**

### Step 8: Verify

You should see:
- A **system notification** appear on your phone
- If the app is open: a **popup dialog** and the message added to the **in-app list**
- If the app is in background: notification in the **notification bar**

---

## Project Structure

```
lib/
├── main.dart                    # Entry point, Firebase init, background handler
├── firebase_options.dart        # Firebase config (REPLACE with FlutterFire output)
├── models/
│   └── notification_model.dart  # Data model for received notifications
├── screens/
│   └── home_screen.dart         # Main UI screen
├── services/
│   └── notification_service.dart # FCM + local notifications logic
└── widgets/
    ├── notification_card.dart   # Card widget for notification list
    └── token_display.dart       # Token display with copy button
```

## Testing Checklist

| Scenario | Expected Behavior |
|---|---|
| App is **open** (foreground) | Popup dialog + local notification + added to list |
| App is in **background** | System notification in tray; tap opens app and shows dialog |
| App is **terminated** | System notification; tap launches app and shows dialog |
| Copy token | Tap copy icon → token copied to clipboard |

---

## Troubleshooting

- **No token showing?** → Make sure `google-services.json` is in `android/app/` and you ran `flutterfire configure`
- **No notifications?** → Check that you allowed permissions; test on a REAL device, not emulator
- **Build errors?** → Run `flutter clean && flutter pub get` then rebuild
- **Permission denied on Android 13+?** → The app requests `POST_NOTIFICATIONS` at runtime automatically

## Author

NIYONKURU Jean De La Croix — Year 3 CSE, University of Rwanda
