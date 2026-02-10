import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FdbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔒 FINAL COLLECTION NAME (AS IN FIREBASE)
  static const String _collection = 'fdb_datum';

  /// =========================================================
  /// ADD FDB / FDP RECORD
  /// =========================================================
  Future<void> addFdb({
    required String title,
    required String organization,
    required String duration,
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    required String name,
    String? photoUrl, // OPTIONAL
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection(_collection).add({
      'title': title,
      'organization': organization,
      'duration': duration,
      'type': type,
      'email': user.email,
      'name': name,
      'photoUrl': photoUrl ?? '',
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// =========================================================
  /// FETCH LOGGED-IN FACULTY FDB RECORDS
  /// =========================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyFdbRecords() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection(_collection)
        .where('email', isEqualTo: user.email)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
