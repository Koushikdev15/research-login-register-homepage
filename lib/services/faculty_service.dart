import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_model.dart';

class FacultyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save personal information
  Future<void> savePersonalInfo(String userId, PersonalInfo personalInfo) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('personalInfo')
          .doc('info')
          .set(personalInfo.toMap());
    } catch (e) {
      throw 'Error saving personal information: $e';
    }
  }

  // Get personal information
  Future<PersonalInfo?> getPersonalInfo(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('personalInfo')
          .doc('info')
          .get();

      if (doc.exists) {
        return PersonalInfo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching personal information: $e';
    }
  }

  // Save research IDs
  Future<void> saveResearchIDs(String userId, ResearchIDs researchIDs) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('researchIDs')
          .doc('ids')
          .set(researchIDs.toMap());
    } catch (e) {
      throw 'Error saving research IDs: $e';
    }
  }

  // Get research IDs
  Future<ResearchIDs?> getResearchIDs(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('researchIDs')
          .doc('ids')
          .get();

      if (doc.exists) {
        return ResearchIDs.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching research IDs: $e';
    }
  }

  // Add work experience
  Future<void> addWorkExperience(
      String userId, WorkExperience workExperience) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workExperience')
          .add(workExperience.toMap());
    } catch (e) {
      throw 'Error adding work experience: $e';
    }
  }

  // Get all work experiences
  Future<List<WorkExperience>> getWorkExperiences(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workExperience')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkExperience.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Error fetching work experiences: $e';
    }
  }

  // Delete work experience
  Future<void> deleteWorkExperience(String userId, String experienceId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workExperience')
          .doc(experienceId)
          .delete();
    } catch (e) {
      throw 'Error deleting work experience: $e';
    }
  }

  // Save CIT experience
  Future<void> saveCITExperience(
      String userId, CITExperience citExperience) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('citExperience')
          .doc('experience')
          .set(citExperience.toMap());
    } catch (e) {
      throw 'Error saving CIT experience: $e';
    }
  }

  // Get CIT experience
  Future<CITExperience?> getCITExperience(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('citExperience')
          .doc('experience')
          .get();

      if (doc.exists) {
        return CITExperience.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching CIT experience: $e';
    }
  }

  // Add education qualification
  Future<void> addEducation(
      String userId, EducationQualification education) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('educationQualification')
          .add(education.toMap());
    } catch (e) {
      throw 'Error adding education: $e';
    }
  }

  // Get all education qualifications
  Future<List<EducationQualification>> getEducationQualifications(
      String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('educationQualification')
          .orderBy('startYear', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EducationQualification.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Error fetching education qualifications: $e';
    }
  }

  // Delete education qualification
  Future<void> deleteEducation(String userId, String educationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('educationQualification')
          .doc(educationId)
          .delete();
    } catch (e) {
      throw 'Error deleting education: $e';
    }
  }

  // Save all faculty data at once (for registration)
  Future<void> saveFacultyData({
    required String userId,
    required PersonalInfo personalInfo,
    required ResearchIDs researchIDs,
    required List<WorkExperience> workExperiences,
    required CITExperience citExperience,
    required List<EducationQualification> educationQualifications,
  }) async {
    try {
      // Use batch write for atomic operation
      WriteBatch batch = _firestore.batch();

      // Personal Info
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('personalInfo')
            .doc('info'),
        personalInfo.toMap(),
      );

      // Research IDs
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('researchIDs')
            .doc('ids'),
        researchIDs.toMap(),
      );

      // CIT Experience
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('citExperience')
            .doc('experience'),
        citExperience.toMap(),
      );

      await batch.commit();

      // Work Experiences (separate loop as we need auto-generated IDs)
      for (var workExp in workExperiences) {
        await addWorkExperience(userId, workExp);
      }

      // Education Qualifications
      for (var education in educationQualifications) {
        await addEducation(userId, education);
      }
    } catch (e) {
      throw 'Error saving faculty data: $e';
    }
  }

  // Get complete faculty profile
  Future<Map<String, dynamic>> getCompleteFacultyProfile(String userId) async {
    try {
      final personalInfo = await getPersonalInfo(userId);
      final researchIDs = await getResearchIDs(userId);
      final workExperiences = await getWorkExperiences(userId);
      final citExperience = await getCITExperience(userId);
      final educationQualifications = await getEducationQualifications(userId);

      return {
        'personalInfo': personalInfo,
        'researchIDs': researchIDs,
        'workExperiences': workExperiences,
        'citExperience': citExperience,
        'educationQualifications': educationQualifications,
      };
    } catch (e) {
      throw 'Error fetching faculty profile: $e';
    }
  }
}
