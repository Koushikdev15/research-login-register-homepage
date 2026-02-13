import 'package:cloud_firestore/cloud_firestore.dart';

class FdbModel {
  final String title;
  final String organization;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String email;
  final String name;
  final String? photoUrl;
  final Timestamp createdAt;

  FdbModel({
    required this.title,
    required this.organization,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
  });

  // 🔹 Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organization': organization,
      'duration': duration,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'type': type,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }

  // 🔹 Convert Firestore → Model
  factory FdbModel.fromMap(Map<String, dynamic> map) {
    return FdbModel(
      title: map['title'] ?? '',
      organization: map['organization'] ?? '',
      duration: map['duration'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      type: map['type'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
