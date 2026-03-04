import 'user_model.dart';
import 'faculty_model.dart';

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

  // ===============================
  // Calculate CIT Experience
  // ===============================

  double get calculatedCITYears {
    if (personalInfo.dateOfJoining.isNotEmpty) {
      try {
        final parts = personalInfo.dateOfJoining.split('-');

        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final joiningDate = DateTime(year, month, day);
          final now = DateTime.now();

          final differenceDays = now.difference(joiningDate).inDays;

          // Use 365.25 for leap year accuracy
          return differenceDays / 365.25;
        }
      } catch (e) {
        return citExperience?.years.toDouble() ?? 0.0;
      }
    }

    return citExperience?.years.toDouble() ?? 0.0;
  }

  // ===============================
  // Calculate Total Experience
  // ===============================

  double get totalExperience {
    double total = 0;

    // External Work Experience
    for (var exp in workExperiences) {
      total += exp.yearsOfExperience;
    }

    // CIT Experience
    total += calculatedCITYears;

    return total;
  }
}