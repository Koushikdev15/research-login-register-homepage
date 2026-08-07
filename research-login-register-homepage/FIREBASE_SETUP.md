# Firebase Setup Guide for Research CSE

## 📋 Prerequisites

1. A Google account
2. Flutter project (already created)
3. Firebase CLI (optional but recommended)

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `research-cse` (or your preferred name)
4. Disable Google Analytics (or enable if needed)
5. Click "Create project"

## 📱 Step 2: Add Android App

1. In Firebase Console, click the Android icon
2. **Android package name**: `com.researchcse.research_cse`
3. **App nickname**: Research CSE Android
4. **Debug signing certificate SHA-1**: (Get this by running the command below)

### Get SHA-1 Certificate:
```bash
cd android
./gradlew signingReport
```
Or on Windows:
```bash
cd android
gradlew.bat signingReport
```

Look for the SHA-1 under `Variant: debug` and copy it.

5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

## 🍎 Step 3: Add iOS App (Optional)

1. Click the iOS icon in Firebase Console
2. **iOS bundle ID**: `com.researchcse.researchCse`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

## 🔐 Step 4: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password**:
   - Click on Email/Password
   - Enable the first toggle
   - Save

4. Enable **Google Sign-In**:
   - Click on Google
   - Enable the toggle
   - Enter support email
   - Save

## 📊 Step 5: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (we'll add security rules later)
4. Select a location (choose closest to your users)
5. Click "Enable"

## 🗂️ Step 6: Setup Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click "Get started"
3. Choose **Start in test mode**
4. Use the same location as Firestore
5. Click "Done"

## 🛡️ Step 7: Deploy Security Rules

### Firestore Rules

1. Go to **Firestore Database** → **Rules**
2. Replace with the rules from the project specification
3. Click "Publish"

### Storage Rules

1. Go to **Storage** → **Rules**
2. Replace with the storage rules from the project specification
3. Click "Publish"

## ⚙️ Step 8: Configure Android

### Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### Update `android/app/build.gradle`:
```gradle
// Add at the bottom of the file
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        // Make sure these match
        applicationId "com.researchcse.research_cse"
        minSdkVersion 21  // Changed from default
        targetSdkVersion 34
    }
}
```

### Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add internet permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application
        android:label="Research CSE"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of the file -->
    </application>
</manifest>
```

## 🍎 Step 9: Configure iOS (if applicable)

### Update `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take profile pictures</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select profile pictures</string>
```

## 🔧 Step 10: Install FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

This will automatically:
- Create Firebase apps
- Download configuration files
- Generate `firebase_options.dart`

## ✅ Step 11: Verify Installation

Run this command to check if everything is set up:
```bash
flutter doctor
```

Then test the app:
```bash
flutter run
```

## 🧪 Step 12: Test Authentication

1. Run the app
2. Try to register a new faculty account
3. Check Firebase Console → Authentication to see if the user was created
4. Try logging in with the same credentials
5. Test Google Sign-In

## 📝 Step 13: Initial Test Data

### Create a Test User Manually

1. Go to Firebase Console → Authentication
2. Click "Add user"
3. Enter email: `test@faculty.com`
4. Enter password: `Test@123`
5. Click "Add user"

### Add Test Data in Firestore

1. Go to Firestore Database
2. Create collection: `users`
3. Document ID: (the UID from Authentication)
4. Add fields:
   ```
   email: "test@faculty.com"
   role: "faculty"
   createdAt: (timestamp - now)
   profilePictureURL: null
   ```

## 🔐 Security Considerations

### Before Production:

1. **Update Security Rules**: Change from test mode to production rules
2. **Enable Email Verification**: Enforce email verification
3. **Add reCAPTCHA**: For web authentication
4. **Set Up App Check**: To prevent abuse
5. **Enable Multi-Factor Authentication**: For sensitive accounts
6. **Set Up Backup**: Regular Firestore backups

## ⚠️ Common Issues & Solutions

### Issue: "google-services.json not found"
**Solution**: Make sure the file is in `android/app/` directory

### Issue: "Default FirebaseApp is not initialized"
**Solution**: Make sure `await Firebase.initializeApp()` is called in main()

### Issue: "SHA-1 certificate not working"
**Solution**: Add both debug and release SHA-1 certificates in Firebase Console

### Issue: "Google Sign-In not working"
**Solution**: 
- Check SHA-1 is added
- Verify package name matches
- Android: Download new `google-services.json` after adding SHA-1

### Issue: "Firestore permission denied"
**Solution**: Check security rules and make sure user is authenticated

## 📚 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## 🎯 Production Checklist

Before deploying to production:

- [ ] Update all security rules to production mode
- [ ] Enable email verification requirement
- [ ] Set up proper error tracking (Firebase Crashlytics)
- [ ] Configure analytics
- [ ] Set up App Check
- [ ] Test on real devices
- [ ] Add rate limiting
- [ ] Configure authorized domains
- [ ] Set up monitoring and alerts
- [ ] Create backup strategy
- [ ] Document API keys management

---

**Last Updated**: February 5, 2026
