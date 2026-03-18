# Nexus — Firebase Setup Guide

## One-time setup (5 minutes)

### 1. Create a Firebase project
1. Go to https://console.firebase.google.com
2. Click "Add project" → name it "nexus" → Continue
3. Disable Google Analytics (not needed) → Create project

### 2. Enable Authentication
1. In Firebase console → Authentication → Get started
2. Sign-in method → Email/Password → Enable → Save

### 3. Enable Firestore
1. Firestore Database → Create database
2. Choose "Start in test mode" (we'll add rules after)
3. Pick a region close to you → Done

### 4. Connect Flutter to Firebase
Install FlutterFire CLI once:
```bash
dart pub global activate flutterfire_cli
```

Then in your project folder:
```bash
flutterfire configure
```
- Select your "nexus" project
- Select: Android, iOS, Web, Windows, Linux
- This auto-generates `lib/firebase_options.dart` — it replaces the placeholder

### 5. Add Firestore security rules
In Firebase console → Firestore → Rules → paste contents of `firestore.rules`

### 6. Android — add google-services.json
FlutterFire configure does this automatically. If not:
- Firebase console → Project settings → Android app → Download google-services.json
- Place in `android/app/google-services.json`

### 7. Run
```bash
flutter pub get
flutter run -d android    # or -d windows / -d linux
```

## How it works
- Sign in on Android → your device registers in Firestore with its LAN IP
- Sign in on Windows → registers there too, sees your Android immediately
- Both devices appear in each other's Devices screen in real time
- All file transfers happen directly over LAN (zero cloud data usage)
- Firebase is only used for login + device discovery (IP registry)

## Free tier limits (more than enough)
- Firebase Auth: unlimited users free
- Firestore: 1GB storage, 50K reads/day, 20K writes/day — free forever
