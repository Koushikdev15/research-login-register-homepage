import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/orcid_service.dart';

class ResearchVerificationSeeder {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> seedCurrentYearIfNeeded() async {
    final int currentYear = DateTime.now().year;

    // 🔹 Get all faculty users
    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'faculty')
        .get();

    for (final userDoc in usersSnapshot.docs) {
      final String facultyId = userDoc.id;

      // 🔹 Get personalInfo
      final personalInfoDoc = await _firestore
          .collection('users')
          .doc(facultyId)
          .collection('personalInfo')
          .doc('info')
          .get();

      if (!personalInfoDoc.exists) continue;

      final personalData = personalInfoDoc.data()!;
      final String facultyName =
          personalData['name'] ?? 'Unknown Faculty';
      final String department =
          personalData['department'] ?? '';

      // 🔹 Get researchIDs
      final researchDoc = await _firestore
          .collection('users')
          .doc(facultyId)
          .collection('researchIDs')
          .doc('ids')
          .get();

      if (!researchDoc.exists) continue;

      final researchData = researchDoc.data()!;
      final String? orcidId = researchData['orcidId'];

      if (orcidId == null || orcidId.isEmpty) continue;

      // 🔹 Fetch ORCID works
      final grouped =
          await OrcidService.fetchGroupedWorks(orcidId);

      for (final entry in grouped.entries) {
        final String workType = entry.key;
        final List<WorkItem> works = entry.value;

        for (final work in works) {
          final int? year =
              int.tryParse(work.year ?? '');

          if (year != currentYear) continue;

          final String docId =
              '${facultyId}_${work.putCode}_$currentYear';

          final docRef = _firestore
              .collection('research_verifications')
              .doc(docId);

          final exists = await docRef.get();
          if (exists.exists) continue;

          await docRef.set({
            'facultyId': facultyId,
            'facultyName': facultyName,
            'department': department,
            'putCode': work.putCode,
            'workTitle': work.title,
            'workType': workType,
            'publicationYear': currentYear,
            'verificationStatus': 'PENDING',
            'verificationDecision': null,
            'isScopus': false,
            'isSci': false,
            'isIsbnVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }
}
