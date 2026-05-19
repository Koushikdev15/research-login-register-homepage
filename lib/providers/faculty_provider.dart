import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_model.dart';
import '../services/faculty_service.dart';

class FacultyProvider with ChangeNotifier {

  final FacultyService _facultyService = FacultyService();

  FacultyService get facultyService => _facultyService;

  PersonalInfo? _personalInfo;
  ResearchIDs? _researchIDs;
  List<WorkExperience> _workExperiences = [];
  CITExperience? _citExperience;
  List<EducationQualification> _educationQualifications = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ==============================
  // PROFILE EDIT REQUEST STATE
  // ==============================

  String? _editRequestStatus; // PENDING | APPROVED | REJECTED
  DateTime? _editRequestReviewedAt;
  bool _hasPendingEditRequest = false;

  // ==============================
  // GETTERS
  // ==============================

  PersonalInfo? get personalInfo => _personalInfo;
  ResearchIDs? get researchIDs => _researchIDs;
  List<WorkExperience> get workExperiences => _workExperiences;
  CITExperience? get citExperience => _citExperience;
  List<EducationQualification> get educationQualifications => _educationQualifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get editRequestStatus => _editRequestStatus;
  DateTime? get editRequestReviewedAt => _editRequestReviewedAt;
  bool get hasPendingEditRequest => _hasPendingEditRequest;

  // ==============================
  // LOAD FULL PROFILE
  // ==============================

  Future<void> loadFacultyProfile(String userId) async {

    try {

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final profile =
          await _facultyService.getCompleteFacultyProfile(userId);

      _personalInfo = profile['personalInfo'];
      _researchIDs = profile['researchIDs'];
      _workExperiences = profile['workExperiences'] ?? [];
      _citExperience = profile['citExperience'];
      _educationQualifications =
          profile['educationQualifications'] ?? [];

      listenToProfileEditRequest(userId);

      _isLoading = false;
      notifyListeners();

    } catch (e) {

      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ==============================
  // LISTEN PROFILE EDIT REQUEST
  // ==============================

  void listenToProfileEditRequest(String userId) {

    _facultyService.firestore
        .collection('profile_edit_requests')
        .where('facultyId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.isEmpty) {

        _editRequestStatus = null;
        _editRequestReviewedAt = null;
        _hasPendingEditRequest = false;

      } else {

        final data = snapshot.docs.first.data();

        _editRequestStatus = data['status'];

        final reviewedAtTimestamp = data['reviewedAt'];

        if (reviewedAtTimestamp != null) {
          _editRequestReviewedAt =
              (reviewedAtTimestamp as Timestamp).toDate();
        } else {
          _editRequestReviewedAt = null;
        }

        _hasPendingEditRequest =
            _editRequestStatus == 'PENDING';
      }

      notifyListeners();
    });
  }

  // ==============================
  // SAVE COMPLETE FACULTY DATA
  // ==============================

  Future<bool> saveFacultyData({
    required String userId,
    required PersonalInfo personalInfo,
    required ResearchIDs researchIDs,
    required List<WorkExperience> workExperiences,
    required CITExperience citExperience,
    required List<EducationQualification> educationQualifications,
  }) async {

    try {

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _facultyService.saveFacultyData(
        userId: userId,
        personalInfo: personalInfo,
        researchIDs: researchIDs,
        workExperiences: workExperiences,
        citExperience: citExperience,
        educationQualifications: educationQualifications,
      );

      _personalInfo = personalInfo;
      _researchIDs = researchIDs;
      _workExperiences = workExperiences;
      _citExperience = citExperience;
      _educationQualifications = educationQualifications;

      _isLoading = false;
      notifyListeners();

      return true;

    } catch (e) {

      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // UPDATE PERSONAL INFO
  // ==============================

  Future<bool> updatePersonalInfo(
      String userId,
      PersonalInfo personalInfo,
  ) async {

    try {

      _isLoading = true;
      notifyListeners();

      await _facultyService.savePersonalInfo(userId, personalInfo);

      _personalInfo = personalInfo;

      _isLoading = false;
      notifyListeners();

      return true;

    } catch (e) {

      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // UPDATE RESEARCH IDs
  // ==============================

  Future<bool> updateResearchIDs(
      String userId,
      ResearchIDs researchIDs,
  ) async {

    try {

      _isLoading = true;
      notifyListeners();

      await _facultyService.saveResearchIDs(userId, researchIDs);

      _researchIDs = researchIDs;

      _isLoading = false;
      notifyListeners();

      return true;

    } catch (e) {

      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // ADD WORK EXPERIENCE
  // ==============================

  Future<bool> addWorkExperience(
      String userId,
      WorkExperience workExperience,
  ) async {

    try {

      await _facultyService.addWorkExperience(userId, workExperience);

      _workExperiences.insert(0, workExperience);

      notifyListeners();

      return true;

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // DELETE WORK EXPERIENCE
  // ==============================

  Future<bool> deleteWorkExperience(
      String userId,
      String experienceId,
  ) async {

    try {

      await _facultyService.deleteWorkExperience(userId, experienceId);

      await loadWorkExperiences(userId);

      return true;

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // LOAD WORK EXPERIENCES
  // ==============================

  Future<void> loadWorkExperiences(String userId) async {

    try {

      final snapshot = await _facultyService.firestore
          .collection('users')
          .doc(userId)
          .collection('workExperience')
          .orderBy('addedAt', descending: true)
          .get();

      _workExperiences = snapshot.docs
          .map((doc) => WorkExperience.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ==============================
  // UPDATE CIT EXPERIENCE
  // ==============================

  Future<bool> updateCITExperience(
      String userId,
      CITExperience citExperience,
  ) async {

    try {

      await _facultyService.saveCITExperience(userId, citExperience);

      _citExperience = citExperience;

      notifyListeners();

      return true;

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // ADD EDUCATION
  // ==============================

  Future<bool> addEducation(
      String userId,
      EducationQualification education,
  ) async {

    try {

      await _facultyService.addEducation(userId, education);

      _educationQualifications.insert(0, education);

      notifyListeners();

      return true;

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // DELETE EDUCATION
  // ==============================

  Future<bool> deleteEducation(
      String userId,
      String educationId,
  ) async {

    try {

      await _facultyService.deleteEducation(userId, educationId);

      _educationQualifications.removeWhere(
        (edu) => edu.id == educationId,
      );

      notifyListeners();

      return true;

    } catch (e) {

      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ==============================
  // CLEAR ERROR
  // ==============================

  void clearError() {

    _errorMessage = null;
    notifyListeners();
  }

  // ==============================
  // CLEAR DATA
  // ==============================

  void clearData() {

    _personalInfo = null;
    _researchIDs = null;
    _workExperiences = [];
    _citExperience = null;
    _educationQualifications = [];

    notifyListeners();
  }
}