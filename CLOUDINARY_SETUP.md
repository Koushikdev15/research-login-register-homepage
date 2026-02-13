# Cloudinary Setup Guide (Alternative to Firebase Storage)

## Why Cloudinary?
- 25 GB free storage (5x more than Firebase)
- Automatic image optimization
- Built-in transformations (resize, crop, filters)
- CDN delivery

## Setup Steps

### 1. Create Cloudinary Account
1. Go to https://cloudinary.com/users/register/free
2. Sign up for free account
3. Note your:
   - Cloud Name
   - API Key
   - API Secret

### 2. Add Dependency
```yaml
# pubspec.yaml
dependencies:
  cloudinary_public: ^0.21.0
```

Run: `flutter pub get`

### 3. Create Cloudinary Service

```dart
// lib/services/cloudinary_service.dart
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_UPLOAD_PRESET', cache: false);

  Future<String> uploadProfilePicture(String userId, XFile imageFile) async {
    try {
      print('Uploading to Cloudinary...');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_pictures/$userId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('Upload successful: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw 'Error uploading to Cloudinary: $e';
    }
  }

  // Get optimized URL (auto-resize to 200x200)
  String getOptimizedUrl(String publicId) {
    return cloudinary.getImage(publicId)
      .transform(Transformation()
        ..width(200)
        ..height(200)
        ..crop('fill')
        ..quality('auto')
        ..fetchFormat('auto'))
      .toString();
  }
}
```

### 4. Update Home Page

```dart
// Replace StorageService with CloudinaryService
final CloudinaryService _cloudinaryService = CloudinaryService();

Future<void> _updateProfilePicture() async {
  try {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId!;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading...')),
      );

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryService.uploadProfilePicture(userId, image);
      
      // Update Firestore
      await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'profilePictureURL': imageUrl});
      
      await authProvider.refreshUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
```

### 5. Configure Upload Preset in Cloudinary

1. Go to Cloudinary Dashboard → Settings → Upload
2. Scroll to "Upload presets"
3. Click "Add upload preset"
4. Set:
   - Preset name: `flutter_uploads`
   - Signing Mode: `Unsigned`
   - Folder: `profile_pictures`
5. Save

### 6. Update Your Code

Replace `YOUR_CLOUD_NAME` and `YOUR_UPLOAD_PRESET` in the CloudinaryService with your actual values.

## Benefits Over Firebase Storage

✅ More free storage (25 GB vs 5 GB)
✅ Automatic image optimization
✅ Built-in transformations
✅ Better for image-heavy apps
✅ Automatic format conversion (WebP, AVIF)

## Stick with Firebase If...

- You're already using Firebase (simpler)
- 5 GB is enough for your needs
- You want everything in one place
- You prefer Firebase's security model
