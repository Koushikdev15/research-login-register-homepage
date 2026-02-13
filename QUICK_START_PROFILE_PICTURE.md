# 🚀 Profile Picture Upload - Quick Start Checklist

## ⚡ 5-Minute Setup

### Step 1: Firebase Storage Setup (2 minutes)
```
□ Go to https://console.firebase.google.com/
□ Select your project
□ Click "Storage" in sidebar
□ Click "Get Started" (if not enabled)
□ Choose location → Click "Done"
```

### Step 2: Configure Storage Rules (1 minute)
```
□ Click "Rules" tab in Storage
□ Copy-paste this code:
```

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profilePictures/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

```
□ Click "Publish"
□ Wait for "Rules published successfully"
```

### Step 3: Test Upload (2 minutes)
```
□ Run: flutter run -d chrome
□ Press F12 (open DevTools Console)
□ Login to app
□ Click profile picture
□ Select an image
□ Watch console for success message
```

---

## 🔧 If It Doesn't Work

### Quick Fixes

**Problem: CORS Error**
```bash
# Create cors.json file:
echo '[{"origin":["*"],"method":["GET","POST","PUT"],"maxAgeSeconds":3600}]' > cors.json

# Apply (replace YOUR-BUCKET):
gsutil cors set cors.json gs://YOUR-BUCKET.appspot.com
```

**Problem: Permission Denied**
```
→ Check Firebase Console → Storage → Rules
→ Make sure rules are published
→ Verify user is logged in
```

**Problem: Image Picker Not Opening**
```
→ Allow pop-ups in browser
→ Grant file access permission
→ Try different browser
```

---

## 📋 Pre-Flight Checklist

Before testing:
```
✓ Firebase Storage enabled
✓ Storage rules configured
✓ User logged in
✓ Browser DevTools open (F12)
✓ Internet connection active
```

---

## ✅ Success Indicators

You'll see:
```
✓ "Opening image picker..." message
✓ File dialog opens
✓ "Uploading profile picture..." message
✓ Console logs upload progress
✓ "Profile picture updated successfully!" message
✓ Image appears in app
✓ Image visible in Firebase Console → Storage
```

---

## 🆘 Emergency Debug

**Open browser console (F12) and run:**
```javascript
// Check if Firebase is initialized
console.log(firebase.apps.length > 0 ? 'Firebase OK' : 'Firebase NOT initialized');

// Check current user
firebase.auth().currentUser ? console.log('User:', firebase.auth().currentUser.uid) : console.log('Not logged in');
```

---

## 📞 Need Help?

1. Check `PROFILE_PICTURE_SETUP_GUIDE.md` for detailed steps
2. Check `PROFILE_PICTURE_TROUBLESHOOTING.md` for common issues
3. Share console output for debugging

---

**Your code is already set up!** Just need to configure Firebase. 🎉
