
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

  // =====================================
  // 🔹 Convert Map → FacultyProfile
  // =====================================

  factory FacultyProfile.fromMap(Map<String, dynamic> data) {

    return FacultyProfile(

      userModel: data['userModel'] as UserModel,

      personalInfo: data['personalInfo'] as PersonalInfo,

      researchIDs: data['researchIDs'] as ResearchIDs?,

      citExperience: data['citExperience'] as CITExperience?,

      workExperiences:
          (data['workExperiences'] as List<WorkExperience>? ?? []),

      educationQualifications:
          (data['educationQualifications']
                  as List<EducationQualification>? ??
              []),
    );
  }

  // =====================================
  // 🔹 Numeric CIT Experience (for sorting)
  // =====================================

  double get calculatedCITYears {

    if (personalInfo.dateOfJoining.isEmpty) return 0;

    try {

      final parts = personalInfo.dateOfJoining.split('-');

      if (parts.length != 3) return 0;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final joiningDate = DateTime(year, month, day);
      final today = DateTime.now();

      final differenceDays =
          today.difference(joiningDate).inDays;

      return differenceDays / 365.25;

    } catch (e) {
      return 0;
    }
  }

  // =====================================
  // 🔹 Formatted CIT Experience (UI)
  // =====================================

  String get calculatedCITExperience {

    if (personalInfo.dateOfJoining.isEmpty) {
      return "0 Years 0 Months";
    }

    try {

      final parts = personalInfo.dateOfJoining.split('-');

      if (parts.length != 3) {
        return "0 Years 0 Months";
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final joiningDate = DateTime(year, month, day);
      final today = DateTime.now();

      int years = today.year - joiningDate.year;
      int months = today.month - joiningDate.month;

      if (today.day < joiningDate.day) {
        months--;
      }

      if (months < 0) {
        years--;
        months += 12;
      }

      if (years < 0) years = 0;
      if (months < 0) months = 0;

      return "$years Years $months Months";

    } catch (e) {
      return "0 Years";
    }
  }

  // =====================================
  // 🔹 Total Experience (Sorting)
  // =====================================

  double get totalExperience {

    double total = 0;

    for (var exp in workExperiences) {
      total += exp.yearsOfExperience;
    }

    total += calculatedCITYears;

    return total;
  }
}

