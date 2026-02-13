# Complete Profile Picture Upload Setup Guide

## 📋 Table of Contents
1. [Firebase Console Setup](#step-1-firebase-console-setup)
2. [Verify Flutter Dependencies](#step-2-verify-flutter-dependencies)
3. [Configure Firebase Storage Rules](#step-3-configure-firebase-storage-rules)
4. [Enable CORS for Web](#step-4-enable-cors-for-web)
5. [Test the Upload Feature](#step-5-test-the-upload-feature)
6. [Troubleshooting](#step-6-troubleshooting)

---

## Step 1: Firebase Console Setup

### 1.1 Enable Firebase Storage

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `research-login-register-homepage`
3. **Click "Storage"** in the left sidebar
4. **If not enabled, click "Get Started"**
5. **Choose "Start in production mode"** (we'll configure rules next)
6. **Select a location** (choose closest to your users, e.g., `asia-south1` for India)
7. **Click "Done"**

### 1.2 Verify Storage is Active

You should see:
- ✅ Storage bucket URL (e.g., `your-project.appspot.com`)
- ✅ Files tab (currently empty)
- ✅ Rules tab
- ✅ Usage tab

---

## Step 2: Verify Flutter Dependencies

### 2.1 Check pubspec.yaml

Open `pubspec.yaml` and verify these dependencies exist:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.7  # ← This is required!

  # Image handling
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1

  # State management
  provider: ^6.1.2
```

### 2.2 Install Dependencies

If you made any changes, run:

```bash
flutter pub get
```

---

## Step 3: Configure Firebase Storage Rules

### 3.1 Set Up Security Rules

1. **Go to Firebase Console** → Storage → **Rules** tab
2. **Replace the existing rules** with this:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile Pictures - Anyone can read, only owner can write
    match /profilePictures/{userId}/{allPaths=**} {
      allow read: if true;  // Public read access
      allow write: if request.auth != null && request.auth.uid == userId;  // Only owner can upload
      allow delete: if request.auth != null && request.auth.uid == userId;  // Only owner can delete
    }
    
    // Documents - Only authenticated users
    match /documents/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. **Click "Publish"**
4. **Wait for confirmation**: "Rules published successfully"

### 3.2 Verify Rules

Test your rules:
1. Click on **"Rules playground"** tab
2. Test read access:
   - Path: `/profilePictures/testUser123/profile.jpg`
   - Operation: `read`
   - Result should be: ✅ **Allowed**

---

## Step 4: Enable CORS for Web

### 4.1 Why CORS is Needed

When running on web (Chrome), Firebase Storage needs CORS configuration to allow uploads from localhost.

### 4.2 Create CORS Configuration File

1. **Create a file** named `cors.json` in your project root:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
```

### 4.3 Install Google Cloud SDK

**For Windows:**
1. Download: https://cloud.google.com/sdk/docs/install
2. Run the installer
3. Follow the setup wizard
4. Open a new terminal/command prompt

**For Mac/Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 4.4 Initialize and Configure

```bash
# Initialize gcloud
gcloud init

# Login to your Google account
gcloud auth login

# Set your project (replace with your Firebase project ID)
gcloud config set project your-project-id
```

### 4.5 Apply CORS Configuration

```bash
# Navigate to your project directory
cd "c:\Users\Koushik P\Desktop\Google_antigravity\research_feb13\research-login-register-homepage"

# Apply CORS settings (replace YOUR-BUCKET-NAME with your Firebase storage bucket)
gsutil cors set cors.json gs://YOUR-BUCKET-NAME.appspot.com
```

**To find your bucket name:**
- Go to Firebase Console → Storage
- Look at the URL, it's like: `gs://your-project.appspot.com`

---

## Step 5: Test the Upload Feature

### 5.1 Run the App

```bash
flutter run -d chrome
```

### 5.2 Open Browser DevTools

1. **Press F12** to open DevTools
2. **Click "Console" tab**
3. Keep it open to see debug messages

### 5.3 Test Upload Flow

1. **Login as a faculty member**
2. **Navigate to Home/Dashboard**
3. **Click on the profile picture** (camera icon)
4. **Select an image** from your computer
5. **Watch the console** for debug messages

### 5.4 Expected Console Output

You should see:
```
Opening image picker...
Image selected: profile.jpg, Size: 245678 bytes
Starting profile picture upload for user: abc123...
Storage reference created: profilePictures/abc123/1234567890.jpg
Image data read: 245678 bytes
Upload task started...
Upload completed successfully
Download URL obtained: https://firebasestorage.googleapis.com/...
Firestore updated with new profile picture URL
Profile picture uploaded successfully: https://...
```

### 5.5 Verify in Firebase Console

1. **Go to Firebase Console** → Storage → Files
2. **You should see**: `profilePictures/[userId]/[timestamp].jpg`
3. **Click on the file** to view details
4. **Copy the download URL** and open in browser - image should display

### 5.6 Verify in Firestore

1. **Go to Firebase Console** → Firestore Database
2. **Navigate to**: `users/[userId]`
3. **Check field**: `profilePictureURL` should contain the image URL

---

## Step 6: Troubleshooting

### Issue 1: "Permission Denied" Error

**Symptoms:**
```
Error: Permission denied. Could not perform this operation
```

**Solutions:**
1. ✅ Check Firebase Storage Rules (Step 3)
2. ✅ Verify user is authenticated (check Firebase Auth console)
3. ✅ Ensure userId in storage path matches authenticated user

**Fix:**
```javascript
// In Firebase Console → Storage → Rules
match /profilePictures/{userId}/{allPaths=**} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

---

### Issue 2: "CORS Error" on Web

**Symptoms:**
```
Access to fetch at 'https://firebasestorage.googleapis.com/...' from origin 'http://localhost:...' has been blocked by CORS policy
```

**Solutions:**
1. ✅ Apply CORS configuration (Step 4)
2. ✅ Restart your Flutter app after applying CORS
3. ✅ Clear browser cache (Ctrl+Shift+Delete)

**Quick Fix:**
```bash
# Create cors.json file with:
[{"origin": ["*"], "method": ["GET", "POST", "PUT"], "maxAgeSeconds": 3600}]

# Apply it:
gsutil cors set cors.json gs://your-bucket.appspot.com
```

---

### Issue 3: Image Picker Not Opening

**Symptoms:**
- Nothing happens when clicking profile picture
- No file dialog appears

**Solutions:**
1. ✅ Check browser permissions (allow file access)
2. ✅ Disable pop-up blocker for localhost
3. ✅ Try a different browser

**Test:**
```dart
// Add this debug code to home_page.dart
Future<void> _testImagePicker() async {
  print('Testing image picker...');
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  print('Image selected: ${image?.path}');
}
```

---

### Issue 4: Upload Succeeds but Image Not Displaying

**Symptoms:**
- Upload completes successfully
- Image URL saved to Firestore
- But image doesn't show in app

**Solutions:**
1. ✅ Check if URL is valid (open in browser)
2. ✅ Verify CachedNetworkImage is working
3. ✅ Check storage rules allow public read

**Debug:**
```dart
// In home_page.dart build method
print('User profile picture URL: ${user?.profilePictureURL}');

// Check if URL is accessible
if (user?.profilePictureURL != null) {
  print('Opening URL in browser: ${user!.profilePictureURL}');
}
```

---

### Issue 5: "User not logged in" Error

**Symptoms:**
```
Error: User not logged in
```

**Solutions:**
1. ✅ Ensure user is authenticated before accessing home page
2. ✅ Check AuthProvider is properly initialized
3. ✅ Verify Firebase Auth is working

**Fix:**
```dart
// In home_page.dart
final userId = authProvider.currentUserId;
if (userId == null) {
  print('ERROR: User not authenticated!');
  // Navigate back to login
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

---

### Issue 6: Large File Upload Fails

**Symptoms:**
- Small images work
- Large images fail or timeout

**Solutions:**
1. ✅ Reduce image size before upload
2. ✅ Compress image quality
3. ✅ Check Firebase Storage quota

**Already Implemented:**
```dart
// In storage_service.dart - pickImageFromGallery()
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1024,      // ← Limits size
  maxHeight: 1024,     // ← Limits size
  imageQuality: 85,    // ← Compresses image
);
```

---

## 🎯 Quick Checklist

Before testing, ensure:

- [ ] Firebase Storage is enabled in Firebase Console
- [ ] Storage rules are configured (Step 3)
- [ ] CORS is configured for web (Step 4)
- [ ] User is authenticated (logged in)
- [ ] Dependencies are installed (`flutter pub get`)
- [ ] App is running (`flutter run -d chrome`)
- [ ] Browser DevTools Console is open (F12)

---

## 🔍 Debug Commands

### Check Firebase Configuration
```bash
# In your project directory
cat android/app/google-services.json
cat ios/Runner/GoogleService-Info.plist
```

### Check Storage Rules
```bash
# Using Firebase CLI
firebase deploy --only storage
```

### View Console Logs
```bash
# In browser DevTools (F12) → Console tab
# Filter by: "profile" or "upload"
```

---

## 📞 Still Having Issues?

If you're still experiencing problems:

1. **Share the console output** (from browser DevTools)
2. **Share the error message** (exact text)
3. **Check Firebase Console** → Storage → Usage (for quota)
4. **Verify Firebase project** is active and billing is enabled (if needed)

---

## ✅ Success Indicators

You'll know it's working when:

1. ✅ Image picker opens when clicking profile picture
2. ✅ "Uploading..." message appears
3. ✅ Console shows upload progress
4. ✅ "Profile picture updated successfully!" message appears
5. ✅ Image appears in Firebase Console → Storage
6. ✅ Image displays in the app
7. ✅ Firestore has the profilePictureURL field updated

---

## 🚀 Next Steps After Setup

Once profile pictures are working:

1. **Add image cropping** (optional)
2. **Add loading indicator** during upload
3. **Add image compression** for better performance
4. **Add delete profile picture** option
5. **Add default avatars** for users without pictures

---

**Last Updated:** February 13, 2026  
**Version:** 1.0  
**Status:** Production Ready ✅
