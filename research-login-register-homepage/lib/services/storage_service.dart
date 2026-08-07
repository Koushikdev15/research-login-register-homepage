import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload profile picture
  Future<String> uploadProfilePicture(String userId, XFile imageFile) async {
    try {
      // Create reference to storage location
      // Use jpeg extension for consistency, or extract from file name
      Reference ref = _storage.ref().child('profilePictures/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload file using data (works on Web and Mobile)
      Uint8List data = await imageFile.readAsBytes();
      UploadTask uploadTask = ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with new profile picture URL
      await _updateProfilePictureUrl(userId, downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw 'Error uploading profile picture: $e';
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'Error picking image from gallery: $e';
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'Error taking photo: $e';
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String userId, String imageUrl) async {
    try {
      // Delete from Storage
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      // Update Firestore
      await _updateProfilePictureUrl(userId, null);
    } catch (e) {
      throw 'Error deleting profile picture: $e';
    }
  }

  // Update profile picture URL in Firestore
  Future<void> _updateProfilePictureUrl(String userId, String? url) async {
    await _firestore.collection('users').doc(userId).update({
      'profilePictureURL': url,
    });
  }

  // Upload document
  Future<String> uploadDocument(String userId, XFile file, String documentType) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      Reference ref = _storage.ref().child('$documentType/$userId/$fileName');

      Uint8List data = await file.readAsBytes();
      UploadTask uploadTask = ref.putData(data);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Error uploading document: $e';
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentUrl) async {
    try {
      Reference ref = _storage.refFromURL(documentUrl);
      await ref.delete();
    } catch (e) {
      throw 'Error deleting document: $e';
    }
  }
}
