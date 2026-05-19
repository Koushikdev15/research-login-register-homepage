import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_model.dart';
import '../models/user_model.dart';

class FacultyService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  /* ============================================================
     🔵 USER BASIC INFO
  ============================================================ */

  Future<void> updateProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {

    await _firestore.collection('users').doc(userId).update({
      'profilePictureURL': photoUrl,
    });

  }

  /* ============================================================
     🔵 PERSONAL INFO
  ============================================================ */

  Future<void> savePersonalInfo(
      String userId, PersonalInfo personalInfo) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('personalInfo')
        .doc('info')
        .set(personalInfo.toMap());

  }

  Future<PersonalInfo?> getPersonalInfo(String userId) async {

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('personalInfo')
        .doc('info')
        .get();

    if (!doc.exists) return null;

    return PersonalInfo.fromFirestore(doc);

  }

  /* ============================================================
     🔵 RESEARCH IDS
  ============================================================ */

  Future<void> saveResearchIDs(
      String userId, ResearchIDs researchIDs) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('researchIDs')
        .doc('ids')
        .set(researchIDs.toMap());

  }

  Future<ResearchIDs?> getResearchIDs(String userId) async {

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('researchIDs')
        .doc('ids')
        .get();

    if (!doc.exists) return null;

    return ResearchIDs.fromFirestore(doc);

  }

  /* ============================================================
     🔵 WORK EXPERIENCE
  ============================================================ */

  Future<void> addWorkExperience(
      String userId, WorkExperience workExperience) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workExperience')
        .add(workExperience.toMap());

  }

  Future<List<WorkExperience>> getWorkExperiences(
      String userId) async {

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workExperience')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            WorkExperience.fromMap(doc.data(), doc.id))
        .toList();

  }

  Future<void> deleteWorkExperience(
      String userId, String experienceId) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workExperience')
        .doc(experienceId)
        .delete();

  }

  /* ============================================================
     🔵 CIT EXPERIENCE
  ============================================================ */

  Future<void> saveCITExperience(
      String userId, CITExperience citExperience) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('citExperience')
        .doc('experience')
        .set(citExperience.toMap());

  }

  Future<CITExperience?> getCITExperience(
      String userId) async {

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('citExperience')
        .doc('experience')
        .get();

    if (!doc.exists) return null;

    return CITExperience.fromFirestore(doc);

  }

  /* ============================================================
     🔵 EDUCATION
  ============================================================ */

  Future<void> addEducation(
      String userId,
      EducationQualification education) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('educationQualification')
        .add(education.toMap());

  }

  Future<List<EducationQualification>>
      getEducationQualifications(String userId) async {

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('educationQualification')
        .orderBy('startYear', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            EducationQualification.fromMap(doc.data(), doc.id))
        .toList();

  }

  Future<void> deleteEducation(
      String userId, String educationId) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('educationQualification')
        .doc(educationId)
        .delete();

  }

  /* ============================================================
     🔵 COMPLETE PROFILE FETCH
  ============================================================ */

  Future<Map<String, dynamic>> getCompleteFacultyProfile(
      String userId) async {

    final userDoc =
        await _firestore.collection('users').doc(userId).get();

    final userModel = UserModel.fromFirestore(userDoc);

    final personalInfo = await getPersonalInfo(userId);
    final researchIDs = await getResearchIDs(userId);
    final workExperiences = await getWorkExperiences(userId);
    final citExperience = await getCITExperience(userId);
    final educationQualifications =
        await getEducationQualifications(userId);

    return {

      'userModel': userModel,
      'personalInfo': personalInfo,
      'researchIDs': researchIDs,
      'workExperiences': workExperiences,
      'citExperience': citExperience,
      'educationQualifications': educationQualifications,

    };

  }

  /* ============================================================
     🔵 PROFILE EDIT REQUEST SYSTEM
  ============================================================ */

  Future<bool> hasPendingProfileEditRequest(
      String userId) async {

    final snapshot = await _firestore
        .collection('profile_edit_requests')
        .where('facultyId', isEqualTo: userId)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;

  }

  Future<void> submitProfileEditRequest({

    required String userId,
    required String facultyName,
    required PersonalInfo updatedPersonalInfo,
    required ResearchIDs updatedResearchIDs,
    required CITExperience updatedCITExperience,
    required List<WorkExperience> updatedWorkExperiences,
    required List<EducationQualification>
        updatedEducationQualifications,

  }) async {

    bool hasPending =
        await hasPendingProfileEditRequest(userId);

    if (hasPending) {
      throw 'You already have a pending profile edit request.';
    }

    final originalProfile =
        await getCompleteFacultyProfile(userId);

    final originalDataSnapshot = {

      'personalInfo':
          (originalProfile['personalInfo'] as PersonalInfo?)
              ?.toMap(),

      'researchIDs':
          (originalProfile['researchIDs'] as ResearchIDs?)
              ?.toMap(),

      'citExperience':
          (originalProfile['citExperience'] as CITExperience?)
              ?.toMap(),

      'workExperiences':
          (originalProfile['workExperiences']
                  as List<WorkExperience>)
              .map((e) => e.toMap())
              .toList(),

      'educationQualifications':
          (originalProfile['educationQualifications']
                  as List<EducationQualification>)
              .map((e) => e.toMap())
              .toList(),

    };

    final updatedDataSnapshot = {

      'personalInfo': updatedPersonalInfo.toMap(),
      'researchIDs': updatedResearchIDs.toMap(),
      'citExperience': updatedCITExperience.toMap(),

      'workExperiences':
          updatedWorkExperiences
              .map((e) => e.toMap())
              .toList(),

      'educationQualifications':
          updatedEducationQualifications
              .map((e) => e.toMap())
              .toList(),

    };

    await _firestore.collection('profile_edit_requests').add({

      'facultyId': userId,
      'facultyName': facultyName,

      'requestedAt': FieldValue.serverTimestamp(),

      'status': 'PENDING',

      'reviewedAt': null,
      'reviewedBy': null,

      'originalDataSnapshot': originalDataSnapshot,
      'updatedDataSnapshot': updatedDataSnapshot,

    });

  }

  /* ============================================================
     🔵 SAVE COMPLETE FACULTY DATA (REGISTRATION)
  ============================================================ */

  Future<void> saveFacultyData({

  required String userId,
  required PersonalInfo personalInfo,
  required ResearchIDs researchIDs,
  required List<WorkExperience> workExperiences,
  required CITExperience citExperience,
  required List<EducationQualification>
      educationQualifications,

}) async {

  WriteBatch batch = _firestore.batch();

  batch.set(
    _firestore
        .collection('users')
        .doc(userId)
        .collection('personalInfo')
        .doc('info'),
    personalInfo.toMap(),
  );

  batch.set(
    _firestore
        .collection('users')
        .doc(userId)
        .collection('researchIDs')
        .doc('ids'),
    researchIDs.toMap(),
  );

  batch.set(
    _firestore
        .collection('users')
        .doc(userId)
        .collection('citExperience')
        .doc('experience'),
    citExperience.toMap(),
  );

  await batch.commit();

  /* ===============================
     DELETE OLD WORK EXPERIENCE
  =============================== */

  final workRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('workExperience');

  final oldWorkDocs = await workRef.get();

  for (var doc in oldWorkDocs.docs) {
    await doc.reference.delete();
  }

  /* ===============================
     DELETE OLD EDUCATION
  =============================== */

  final eduRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('educationQualification');

  final oldEduDocs = await eduRef.get();

  for (var doc in oldEduDocs.docs) {
    await doc.reference.delete();
  }

  /* ===============================
     ADD UPDATED WORK EXPERIENCE
  =============================== */

  for (var workExp in workExperiences) {
    await addWorkExperience(userId, workExp);
  }

  /* ===============================
     ADD UPDATED EDUCATION
  =============================== */

  for (var edu in educationQualifications) {
    await addEducation(userId, edu);
  }

}
}