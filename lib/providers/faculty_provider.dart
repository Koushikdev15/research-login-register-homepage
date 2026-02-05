import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../services/faculty_service.dart';

class FacultyProvider with ChangeNotifier {
  final FacultyService _facultyService = FacultyService();

  PersonalInfo? _personalInfo;
  ResearchIDs? _researchIDs;
  List<WorkExperience> _workExperiences = [];
  CITExperience? _citExperience;
  List<EducationQualification> _educationQualifications = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PersonalInfo? get personalInfo => _personalInfo;
  ResearchIDs? get researchIDs => _researchIDs;
  List<WorkExperience> get workExperiences => _workExperiences;
  CITExperience? get citExperience => _citExperience;
  List<EducationQualification> get educationQualifications =>
      _educationQualifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load complete faculty profile
  Future<void> loadFacultyProfile(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final profile = await _facultyService.getCompleteFacultyProfile(userId);

      _personalInfo = profile['personalInfo'];
      _researchIDs = profile['researchIDs'];
      _workExperiences = profile['workExperiences'] ?? [];
      _citExperience = profile['citExperience'];
      _educationQualifications = profile['educationQualifications'] ?? [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Save complete faculty data (for registration)
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

  // Update personal info
  Future<bool> updatePersonalInfo(String userId, PersonalInfo personalInfo) async {
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

  // Update research IDs
  Future<bool> updateResearchIDs(String userId, ResearchIDs researchIDs) async {
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

  // Add work experience
  Future<bool> addWorkExperience(
      String userId, WorkExperience workExperience) async {
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

  // Delete work experience
  Future<bool> deleteWorkExperience(String userId, String experienceId) async {
    try {
      await _facultyService.deleteWorkExperience(userId, experienceId);
      _workExperiences.removeWhere((exp) => exp.id == experienceId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update CIT experience
  Future<bool> updateCITExperience(
      String userId, CITExperience citExperience) async {
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

  // Add education qualification
  Future<bool> addEducation(
      String userId, EducationQualification education) async {
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

  // Delete education qualification
  Future<bool> deleteEducation(String userId, String educationId) async {
    try {
      await _facultyService.deleteEducation(userId, educationId);
      _educationQualifications.removeWhere((edu) => edu.id == educationId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _personalInfo = null;
    _researchIDs = null;
    _workExperiences = [];
    _citExperience = null;
    _educationQualifications = [];
    notifyListeners();
  }
}
