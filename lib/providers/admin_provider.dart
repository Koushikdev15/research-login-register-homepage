import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/faculty_model.dart';
import '../models/faculty_profile.dart'; // Make sure this file exists
import '../services/faculty_service.dart';

enum SortOption {
  nameAZ,
  nameZA,
  experienceHighToLow,
  experienceLowToHigh,
}

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FacultyService _facultyService = FacultyService();

  List<FacultyProfile> _allFaculty = [];
  List<FacultyProfile> _filteredFaculty = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  SortOption _currentSort = SortOption.nameAZ;

  List<FacultyProfile> get faculty => _filteredFaculty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SortOption get currentSort => _currentSort;

  // Fetch all faculty members
  Future<void> fetchAllFaculty() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Get all users with role 'faculty'
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .get();

      List<FacultyProfile> loadedFaculty = [];

      // 2. For each user, fetch their complete profile
      for (var doc in userSnapshot.docs) {
        UserModel user = UserModel.fromFirestore(doc);
        
        try {
          // Fetch subcollection data using FacultyService
          Map<String, dynamic> profileData = 
              await _facultyService.getCompleteFacultyProfile(user.uid);
          
          if (profileData['personalInfo'] != null) {
            loadedFaculty.add(FacultyProfile(
              userModel: user,
              personalInfo: profileData['personalInfo'],
              researchIDs: profileData['researchIDs'],
              workExperiences: profileData['workExperiences'] ?? [],
              citExperience: profileData['citExperience'],
              educationQualifications: profileData['educationQualifications'] ?? [],
            ));
          }
        } catch (e) {
          print('Error fetching profile for ${user.uid}: $e');
          // Skip users with incomplete/corrupted data
        }
      }

      _allFaculty = loadedFaculty;
      _applyFilterAndSort();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load faculty: $e';
      notifyListeners();
    }
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
    notifyListeners();
  }

  // Sort
  void setSortOption(SortOption option) {
    _currentSort = option;
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    List<FacultyProfile> temp = List.from(_allFaculty);

    // Filter
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((faculty) {
        final nameLower = faculty.personalInfo.name.toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
    }

    // Sort
    switch (_currentSort) {
      case SortOption.nameAZ:
        temp.sort((a, b) => a.personalInfo.name.compareTo(b.personalInfo.name));
        break;
      case SortOption.nameZA:
        temp.sort((a, b) => b.personalInfo.name.compareTo(a.personalInfo.name));
        break;
      case SortOption.experienceHighToLow:
        temp.sort((a, b) => b.totalExperience.compareTo(a.totalExperience));
        break;
      case SortOption.experienceLowToHigh:
        temp.sort((a, b) => a.totalExperience.compareTo(b.totalExperience));
        break;
    }

    _filteredFaculty = temp;
  }
}
