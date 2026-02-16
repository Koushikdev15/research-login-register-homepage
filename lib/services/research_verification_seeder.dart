import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/orcid_service.dart';

class ResearchVerificationSeeder {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> seedCurrentYearIfNeeded() async {
    final int currentYear = DateTime.now().year;

    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'faculty')
        .get();

    for (final userDoc in usersSnapshot.docs) {
      final String facultyId = userDoc.id;

      // 🔹 Personal Info
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

      // 🔹 Root Reference
      final facultyRootRef = _firestore
          .collection('research_verifications_tree')
          .doc(facultyId);

      final rootDoc = await facultyRootRef.get();

      if (!rootDoc.exists) {
        await facultyRootRef.set({
          'facultyName': facultyName,
          'department': department,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 🔹 ORCID
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

      final grouped =
          await OrcidService.fetchGroupedWorks(orcidId);

      for (final entry in grouped.entries) {
        final String workType = entry.key;
        final List<WorkItem> works = entry.value;

        for (final work in works) {
          final int? year =
              int.tryParse(work.year ?? '');

          if (year != currentYear) continue;

          final workRef = facultyRootRef
              .collection('years')
              .doc(currentYear.toString())
              .collection('workTypes')
              .doc(workType)
              .collection('works')
              .doc(work.putCode);

          final existing = await workRef.get();
          if (existing.exists) continue;

          final String? doi = work.identifiers['doi'];
          final String? pat = work.identifiers['pat'];

          await workRef.set({
            // 🔹 LOCKED v2 REQUIRED FIELDS
            'putCode': work.putCode,
            'facultyName': facultyName, // ✅ ADDED
            'facultyId': facultyId, // ✅ ADD THIS LINE
            'workTitle': work.title,
            'author': null,
            'doi': doi,
            'applicationNumber': pat,
            'designNumber': null,
            'workType': workType,
            'publicationYear': currentYear,

            'verificationStatus': 'PENDING',
            'verificationType': null,

            'createdAt': FieldValue.serverTimestamp(),
            'verifiedAt': null,
            'verifiedBy': null,
          });
        }
      }
    }
  }
}
