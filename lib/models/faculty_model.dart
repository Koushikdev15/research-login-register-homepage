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
  final String? photoUrl;

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
    this.photoUrl,
  });

  factory PersonalInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

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
      photoUrl: data['photoUrl'],
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
      'photoUrl': photoUrl,
    };
  }

  PersonalInfo copy() => copyWith();

  PersonalInfo copyWith({
    String? name,
    String? designation,
    String? department,
    int? age,
    String? dateOfBirth,
    String? dateOfJoining,
    String? panNumber,
    String? aadharNumber,
    String? contactNo,
    String? whatsappNo,
    String? mailId,
    String? photoUrl,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      contactNo: contactNo ?? this.contactNo,
      whatsappNo: whatsappNo ?? this.whatsappNo,
      mailId: mailId ?? this.mailId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class ResearchIDs {
  final String googleScholarId;
  final String orcidId;
  final String scopusId;
  final String vidwanId;
  final String researcherId;
  final String wosId;

  ResearchIDs({
    required this.googleScholarId,
    required this.orcidId,
    required this.scopusId,
    required this.vidwanId,
    required this.researcherId,
    required this.wosId,
  });

  factory ResearchIDs.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ResearchIDs(
      googleScholarId: data['googleScholarId'] ?? '',
      orcidId: data['orcidId'] ?? '',
      scopusId: data['scopusId'] ?? '',
      vidwanId: data['vidwanId'] ?? '',
      researcherId: data['researcherId'] ?? '',
      wosId: data['wosId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'googleScholarId': googleScholarId,
      'orcidId': orcidId,
      'scopusId': scopusId,
      'vidwanId': vidwanId,
      'researcherId': researcherId,
      'wosId': wosId,
    };
  }

  ResearchIDs copy() => copyWith();

  ResearchIDs copyWith({
    String? googleScholarId,
    String? orcidId,
    String? scopusId,
    String? vidwanId,
    String? researcherId,
    String? wosId,
  }) {
    return ResearchIDs(
      googleScholarId: googleScholarId ?? this.googleScholarId,
      orcidId: orcidId ?? this.orcidId,
      scopusId: scopusId ?? this.scopusId,
      vidwanId: vidwanId ?? this.vidwanId,
      researcherId: researcherId ?? this.researcherId,
      wosId: wosId ?? this.wosId,
    );
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

  WorkExperience copy() => copyWith();

  WorkExperience copyWith({
    String? id,
    String? institutionName,
    int? yearsOfExperience,
    DateTime? addedAt,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      institutionName: institutionName ?? this.institutionName,
      yearsOfExperience:
          yearsOfExperience ?? this.yearsOfExperience,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class CITExperience {
  final int years;
  final int months;

  CITExperience({
    required this.years,
    required this.months,
  });

  factory CITExperience.fromDateOfJoining(String dateOfJoining) {
    try {
      final parts = dateOfJoining.split('/');

      final joiningDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      final now = DateTime.now();

      int totalMonths =
          (now.year - joiningDate.year) * 12 +
          (now.month - joiningDate.month);

      if (now.day < joiningDate.day) {
        totalMonths--;
      }

      return CITExperience(
        years: totalMonths ~/ 12,
        months: totalMonths % 12,
      );
    } catch (e) {
      return CITExperience(years: 0, months: 0);
    }
  }

  factory CITExperience.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CITExperience(
      years: data['years'] ?? 0,
      months: data['months'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'years': years,
      'months': months,
    };
  }

  CITExperience copy() => copyWith();

  CITExperience copyWith({
    int? years,
    int? months,
  }) {
    return CITExperience(
      years: years ?? this.years,
      months: months ?? this.months,
    );
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

  factory EducationQualification.fromMap(
      Map<String, dynamic> data, String id) {
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

  EducationQualification copy() => copyWith();

  EducationQualification copyWith({
    String? id,
    String? institutionName,
    String? course,
    int? startYear,
    int? endYear,
    int? duration,
    DateTime? addedAt,
  }) {
    return EducationQualification(
      id: id ?? this.id,
      institutionName:
          institutionName ?? this.institutionName,
      course: course ?? this.course,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}