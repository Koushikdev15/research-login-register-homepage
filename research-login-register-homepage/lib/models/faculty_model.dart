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
  final int yearsInCIT;

  CITExperience({required this.yearsInCIT});

  factory CITExperience.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CITExperience(
      yearsInCIT: data['yearsInCIT'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'yearsInCIT': yearsInCIT,
    };
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
