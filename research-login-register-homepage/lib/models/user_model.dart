import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String role; // 'admin', 'faculty', 'student'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? profilePictureURL;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.profilePictureURL,
  });

  // Factory constructor for creating a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'faculty',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      profilePictureURL: data['profilePictureURL'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'profilePictureURL': profilePictureURL,
    };
  }

  // CopyWith method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? profilePictureURL,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
    );
  }
}
