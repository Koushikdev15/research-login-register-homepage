import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FdbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔒 FINAL COLLECTION NAME
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
    String? photoUrl,
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

  /// =========================================================
  /// UPDATE FDB (ADMIN USE)
  /// =========================================================
  Future<void> updateFdb({
    required String docId,
    required Map<String, dynamic> updatedData,
  }) async {

    await _firestore
        .collection(_collection)
        .doc(docId)
        .update(updatedData);
  }

  /// =========================================================
  /// DELETE FDB (ADMIN USE)
  /// =========================================================
  Future<void> deleteFdb(String docId) async {

    await _firestore
        .collection(_collection)
        .doc(docId)
        .delete();
  }

  /// =========================================================
  /// FETCH ALL FDB (ADMIN DASHBOARD)
  /// =========================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllFdbRecords() {

    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
