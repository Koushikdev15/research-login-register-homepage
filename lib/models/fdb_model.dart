import 'package:cloud_firestore/cloud_firestore.dart';

class FdbModel {
  final String id;
  final String title;
  final String organization;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String email;
  final String name;
  final String photoUrl;
  final DateTime createdAt;

  FdbModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.createdAt,
  });

  factory FdbModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FdbModel(
      id: doc.id,
      title: data['title'] ?? '',
      organization: data['organization'] ?? '',
      duration: data['duration'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
