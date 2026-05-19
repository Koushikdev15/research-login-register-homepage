import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/researchid_work.dart';
import 'researchid_service.dart';

class ScopusService {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// -----------------------------------------------------------
  /// GET RESEARCHER ID FROM FIRESTORE
  /// -----------------------------------------------------------

  static Future<String?> getResearcherId(String facultyId) async {
    try {

      final doc = await _firestore
          .collection('users')
          .doc(facultyId)
          .collection('researchIDs')
          .doc('ids')
          .get();

      if (!doc.exists) return null;

      final data = doc.data();

      if (data == null) return null;

      final researcherId = data['researcherId'];

      if (researcherId == null || researcherId.toString().trim().isEmpty) {
        return null;
      }

      return researcherId;

    } catch (e) {
      print("ResearcherId fetch error: $e");
      return null;
    }
  }

  /// -----------------------------------------------------------
  /// GET CACHED WORKS FROM FIRESTORE
  /// -----------------------------------------------------------

  static Future<List<ResearchIdWork>> getCachedWorks(String facultyId) async {

    final worksSnapshot = await _firestore
        .collection('faculty_scopus_works')
        .doc(facultyId)
        .collection('works')
        .get();

    return worksSnapshot.docs.map((doc) {

      final data = doc.data();

      return ResearchIdWork(
        title: data['title'] ?? '',
        authors: data['authors'] ?? '',
        publisher: data['publisher'] ?? '',
        description: data['description'] ?? '',
        doiUrl: data['doiUrl'] ?? '',
      );

    }).toList();
  }

  /// -----------------------------------------------------------
  /// INITIAL LOAD (CACHE FIRST)
  /// -----------------------------------------------------------

  static Future<List<ResearchIdWork>> loadScopusWorks(String facultyId) async {

    /// Step 1: check cache

    final cached = await getCachedWorks(facultyId);

    if (cached.isNotEmpty) {
      return cached;
    }

    /// Step 2: get researcherId

    final researcherId = await getResearcherId(facultyId);

    if (researcherId == null) {
      throw Exception("ResearchID not linked yet.");
    }

    /// Step 3: fetch from render

    final works = await ResearchIdService.fetchWorks(researcherId);

    /// Step 4: store

    await _storeWorks(facultyId, researcherId, works);

    return works;
  }

  /// -----------------------------------------------------------
  /// SYNC NOW (ADMIN / FACULTY BUTTON)
  /// -----------------------------------------------------------

  static Future<int> syncNow(String facultyId) async {

    final researcherId = await getResearcherId(facultyId);

    if (researcherId == null) {
      throw Exception("ResearchID not linked.");
    }

    final latestWorks = await ResearchIdService.fetchWorks(researcherId);

    final worksRef = _firestore
        .collection('faculty_scopus_works')
        .doc(facultyId)
        .collection('works');

    int inserted = 0;

    for (final work in latestWorks) {

      final hash = "${work.title}${work.authors}";

      final existing = await worksRef
          .where('hash', isEqualTo: hash)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        continue;
      }

      await worksRef.add({
        'title': work.title,
        'authors': work.authors,
        'publisher': work.publisher,
        'description': work.description,
        'doiUrl': work.doiUrl,
        'hash': hash,
        'createdAt': FieldValue.serverTimestamp(),
      });

      inserted++;
    }

    await _firestore
        .collection('faculty_scopus_works')
        .doc(facultyId)
        .set({
      'researcherId': researcherId,
      'totalWorks': latestWorks.length,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return inserted;
  }

  /// -----------------------------------------------------------
  /// STORE WORKS FIRST TIME
  /// -----------------------------------------------------------

  static Future<void> _storeWorks(
      String facultyId,
      String researcherId,
      List<ResearchIdWork> works,
      ) async {

    final batch = _firestore.batch();

    final docRef = _firestore
        .collection('faculty_scopus_works')
        .doc(facultyId);

    batch.set(docRef, {
      'researcherId': researcherId,
      'totalWorks': works.length,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    });

    for (final work in works) {

      final hash = "${work.title}${work.authors}";

      final workRef = docRef
          .collection('works')
          .doc();

      batch.set(workRef, {
        'title': work.title,
        'authors': work.authors,
        'publisher': work.publisher,
        'description': work.description,
        'doiUrl': work.doiUrl,
        'hash': hash,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}