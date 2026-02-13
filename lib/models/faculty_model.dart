import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfo {
  final String name;
  final String designation;
  final String department;
  final int age;
  final String dateOfBirth;
  final String dateOfJoining;
  final String panNumber;
  final String aadharNumber;
  final String contactNo;
  final String whatsappNo;
  final String mailId;

  PersonalInfo({
    required this.name,
    required this.designation,
    required this.department,
    required this.age,
    required this.dateOfBirth,
    required this.dateOfJoining,
    required this.panNumber,
    required this.aadharNumber,
    required this.contactNo,
    required this.whatsappNo,
    required this.mailId,
  });

  factory PersonalInfo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PersonalInfo(
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      department: data['department'] ?? '',
      age: data['age'] ?? 0,
      dateOfBirth: data['dateOfBirth'] ?? '',
      dateOfJoining: data['dateOfJoining'] ?? '',
      panNumber: data['panNumber'] ?? '',
      aadharNumber: data['aadharNumber'] ?? '',
      contactNo: data['contactNo'] ?? '',
      whatsappNo: data['whatsappNo'] ?? '',
      mailId: data['mailId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'department': department,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'dateOfJoining': dateOfJoining,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
      'contactNo': contactNo,
      'whatsappNo': whatsappNo,
      'mailId': mailId,
    };
  }
}

class ResearchIDs {
  final String? vidwanId;
  final String? scopusId;
  final String? orcidId;
  final String? googleScholarId;

  ResearchIDs({
    this.vidwanId,
    this.scopusId,
    this.orcidId,
    this.googleScholarId,
  });

  factory ResearchIDs.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ResearchIDs(
      vidwanId: data['vidwanId'],
      scopusId: data['scopusId'],
      orcidId: data['orcidId'],
      googleScholarId: data['googleScholarId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vidwanId': vidwanId,
      'scopusId': scopusId,
      'orcidId': orcidId,
      'googleScholarId': googleScholarId,
    };
  }
}

class WorkExperience {
  final String id;
  final String institutionName;
  final int yearsOfExperience;
  final DateTime addedAt;

  WorkExperience({
    required this.id,
    required this.institutionName,
    required this.yearsOfExperience,
    required this.addedAt,
  });

  factory WorkExperience.fromMap(Map<String, dynamic> data, String id) {
    return WorkExperience(
      id: id,
      institutionName: data['institutionName'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institutionName': institutionName,
      'yearsOfExperience': yearsOfExperience,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}

class CITExperience {
  final int years;
  final int months;

  CITExperience({required this.years, required this.months});

  // Calculate experience from date of joining
  factory CITExperience.fromDateOfJoining(String dateOfJoining) {
    try {
      // Parse date in DD/MM/YYYY format
      final parts = dateOfJoining.split('/');
      if (parts.length != 3) {
        return CITExperience(years: 0, months: 0);
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final joiningDate = DateTime(year, month, day);
      final now = DateTime.now();
      
      int totalMonths = (now.year - joiningDate.year) * 12 + (now.month - joiningDate.month);
      
      // Adjust if current day is before joining day in the month
      if (now.day < joiningDate.day) {
        totalMonths--;
      }
      
      final years = totalMonths ~/ 12;
      final months = totalMonths % 12;
      
      return CITExperience(years: years, months: months);
    } catch (e) {
      return CITExperience(years: 0, months: 0);
    }
  }

  factory CITExperience.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CITExperience(
      years: data['years'] ?? data['yearsInCIT'] ?? 0, // Support old format
      months: data['months'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'years': years,
      'months': months,
    };
  }

  // Get formatted string like "2 years, 3 months"
  String get formatted {
    if (years == 0 && months == 0) return '0 months';
    if (years == 0) return '$months ${months == 1 ? 'month' : 'months'}';
    if (months == 0) return '$years ${years == 1 ? 'year' : 'years'}';
    return '$years ${years == 1 ? 'year' : 'years'}, $months ${months == 1 ? 'month' : 'months'}';
  }
}

class EducationQualification {
  final String id;
  final String institutionName;
  final String course;
  final int startYear;
  final int endYear;
  final int duration;
  final DateTime addedAt;

  EducationQualification({
    required this.id,
    required this.institutionName,
    required this.course,
    required this.startYear,
    required this.endYear,
    required this.duration,
    required this.addedAt,
  });

  factory EducationQualification.fromMap(Map<String, dynamic> data, String id) {
    return EducationQualification(
      id: id,
      institutionName: data['institutionName'] ?? '',
      course: data['course'] ?? '',
      startYear: data['startYear'] ?? 0,
      endYear: data['endYear'] ?? 0,
      duration: data['duration'] ?? 0,
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institutionName': institutionName,
      'course': course,
      'startYear': startYear,
      'endYear': endYear,
      'duration': duration,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
