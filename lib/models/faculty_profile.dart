import 'user_model.dart';
import 'faculty_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyProfile {
  final UserModel userModel;
  final PersonalInfo personalInfo;
  final ResearchIDs? researchIDs;
  final List<WorkExperience> workExperiences;
  final CITExperience? citExperience;
  final List<EducationQualification> educationQualifications;

  FacultyProfile({
    required this.userModel,
    required this.personalInfo,
    this.researchIDs,
    this.workExperiences = const [],
    this.citExperience,
    this.educationQualifications = const [],
  });

  // Calculate total experience
  // Calculate total experience
  int get totalExperience {
    int total = 0;
    
    // Add external work experience
    for (var exp in workExperiences) {
      total += exp.yearsOfExperience;
    }
    
    // Calculate CIT experience dynamically from Date of Joining
    if (personalInfo.dateOfJoining.isNotEmpty) {
      try {
        // Expected format: DD-MM-YYYY or similar. 
        // Trying to parse standard formats.
        // Assuming format is 'dd-MM-yyyy' based on typical input
        final parts = personalInfo.dateOfJoining.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final joiningDate = DateTime(year, month, day);
          final now = DateTime.now();
          
          final difference = now.difference(joiningDate).inDays;
          final yearsInCIT = (difference / 365).floor();
          
          if (yearsInCIT > 0) {
            total += yearsInCIT;
          }
        }
      } catch (e) {
        // Fallback to manually entered CIT Experience if date parsing fails
        if (citExperience != null) {
          total += citExperience!.yearsInCIT;
        }
      }
    } else if (citExperience != null) {
      // Fallback if no date is present
      total += citExperience!.yearsInCIT;
    }
    
    return total;
  }
  
  // Helper to get just CIT years
  int get calculatedCITYears {
    if (personalInfo.dateOfJoining.isNotEmpty) {
      try {
        final parts = personalInfo.dateOfJoining.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final joiningDate = DateTime(year, month, day);
          final now = DateTime.now();
          
          final difference = now.difference(joiningDate).inDays;
          return (difference / 365).floor();
        }
      } catch (e) {
        return citExperience?.yearsInCIT ?? 0;
      }
    }
    return citExperience?.yearsInCIT ?? 0;
  }
}
