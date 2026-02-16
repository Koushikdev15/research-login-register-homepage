import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/faculty_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/orcid_service.dart';


class PDFService {



  
static Future<void> generateFacultyPDF(
    FacultyProfile faculty) async {

  try {
    final pdf = pw.Document();

    final researchData =
        await _prepareResearchData(faculty);

    final fdbData =
        await _prepareFdbData(faculty);

    pw.ImageProvider? profileImage;

    if (faculty.userModel.profilePictureURL != null) {
      try {
        final response = await http.get(
            Uri.parse(faculty.userModel.profilePictureURL!));
        if (response.statusCode == 200) {
          profileImage =
              pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {}
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 200,
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          _buildHeader(faculty, profileImage),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Personal Information'),
          _buildPersonalInfoTable(faculty),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Research IDs'),
          _buildResearchIDsTable(faculty),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Work Experience'),
          _buildWorkExperienceList(faculty),
          pw.SizedBox(height: 10),
          _buildCITExperience(faculty),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Educational Qualification'),
          _buildEducationTable(faculty),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Research Publications'),
..._buildResearchSection(researchData),
          pw.SizedBox(height: 20),
          _buildSectionHeader('FDP & Certifications'),
          _buildFdbSection(fdbData),
        ],
      ),
    );

    await Printing.layoutPdf(
      name:
          '${faculty.personalInfo.name.replaceAll(' ', '_')}_Profile.pdf',
      onLayout: (format) async => pdf.save(),
    );

  } catch (e, stack) {
    print('PDF ERROR: $e');
    print(stack);
    rethrow;
  }
}


  // Generate General Info PDF (Subset)
  static Future<void> generateGeneralInfoPDF(FacultyProfile faculty) async {
    // For now, this can be the same as the complete PDF
    // or customized to show ONLY the general info parts.
    // Given the structure, likely similar.
    await generateFacultyPDF(faculty);
  }

  static pw.Widget _buildHeader(FacultyProfile faculty, pw.ImageProvider? profileImage) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (profileImage != null)
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
            ),
          )
        else
          pw.Container(
            width: 80,
            height: 80,
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey200,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(child: pw.Text(faculty.personalInfo.name[0], style: const pw.TextStyle(fontSize: 32))),
          ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                faculty.personalInfo.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                '${faculty.personalInfo.designation} - ${faculty.personalInfo.department}',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                faculty.personalInfo.mailId,
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: PdfColors.blue100,
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildPersonalInfoTable(FacultyProfile faculty) {
    final info = faculty.personalInfo;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('Name', info.name),
        _buildTableRow('Designation', info.designation),
         _buildTableRow('Department', info.department),
        _buildTableRow('Age', '${info.age}'),
        _buildTableRow('Date of Birth', info.dateOfBirth),
        _buildTableRow('Date of Joining', info.dateOfJoining),
        _buildTableRow('Contact', info.contactNo),
        _buildTableRow('Email', info.mailId),
         _buildTableRow('PAN', info.panNumber),
          _buildTableRow('Aadhar', info.aadharNumber),
      ],
    );
  }
  
    static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static pw.Widget _buildResearchIDsTable(FacultyProfile faculty) {
    final ids = faculty.researchIDs;
    if (ids == null) return pw.Text('No Research IDs available.');

    return pw.Table(
       border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        if (ids.vidwanId != null) _buildTableRow('Vidwan ID', ids.vidwanId!),
        if (ids.scopusId != null) _buildTableRow('Scopus ID', ids.scopusId!),
        if (ids.orcidId != null) _buildTableRow('ORCID ID', ids.orcidId!),
        if (ids.googleScholarId != null) _buildTableRow('Google Scholar ID', ids.googleScholarId!),
      ],
    );
  }

  static pw.Widget _buildWorkExperienceList(FacultyProfile faculty) {
    if (faculty.workExperiences.isEmpty) return pw.Text('No work experience listed.');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: faculty.workExperiences.map((exp) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Bullet(
             text: '${exp.institutionName}: ${exp.yearsOfExperience} years',
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildCITExperience(FacultyProfile faculty) {
    if (faculty.calculatedCITYears <= 0) return pw.SizedBox();
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange),
        borderRadius: pw.BorderRadius.circular(5),
        color: PdfColors.orange50,
      ),
      child: pw.Row(
        children: [
           pw.Text('Experience in CIT: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
           pw.Text('${faculty.calculatedCITYears} years'),
        ]
      )
    );
  }

  static pw.Widget _buildEducationTable(FacultyProfile faculty) {
    if (faculty.educationQualifications.isEmpty) return pw.Text('No education details available.');

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      headers: ['Institution', 'Course', 'Duration'],
      data: faculty.educationQualifications.map((edu) => [
        edu.institutionName,
        edu.course,
        '${edu.startYear} - ${edu.endYear} (${edu.duration} years)',
      ]).toList(),
    );
  }


static pw.Widget _buildGreenHeader(
    String text) {
  return pw.Container(
    width: double.infinity,
    padding:
        const pw.EdgeInsets.all(6),
    color: PdfColors.green100,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.green800,
      ),
    ),
  );
}

static pw.Widget _buildRedHeader(
    String text) {
  return pw.Container(
    width: double.infinity,
    padding:
        const pw.EdgeInsets.all(6),
    color: PdfColors.red100,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.red800,
      ),
    ),
  );
}

static pw.Widget _buildResearchTypeBlock(
  String type,
  List<WorkItem> works,
  bool isVerifiedSection,
) {

  if (works.isEmpty)
    return pw.SizedBox();

  return pw.Column(
    crossAxisAlignment:
        pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 10),

      pw.Text(
        _typeLabel(type),
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),

      pw.SizedBox(height: 6),

      _buildResearchTable(
        type,
        works,
        isVerifiedSection,
      ),
    ],
  );
}

static String _identifierColumnName(String type) {
  switch (type) {
    case 'journal-article':
    case 'conference-paper':
      return 'DOI';

    case 'book':
    case 'book-chapter':
      return 'ISBN / DOI';

    case 'patent':
      return 'Application No';

    case 'design':
      return 'Design No';

    default:
      return 'Identifier';
  }
}


static String _typeLabel(
    String type) {
  switch (type) {
    case 'journal-article':
      return 'Journals';
    case 'conference-paper':
      return 'Conferences';
    case 'book':
      return 'Books';
    case 'book-chapter':
      return 'Book Chapters';
    case 'patent':
      return 'Utility Patents';
    case 'design':
      return 'Design Patents';
    default:
      return 'Research';
  }
}



static List<String> _buildRowData({
  required int index,
  required WorkItem work,
  required String type,
  required bool isVerified,
}) {

  final identifier =
      _extractIdentifier(work, type);

  final year =
      work.year ?? '-';

  return [
    index.toString(),
    work.title,
    work.source ?? '-',
    year,
    identifier,
    isVerified ? 'VERIFIED' : 'PENDING',
  ];
}


static String _extractIdentifier(
    WorkItem work,
    String type) {

  final ids = work.identifiers;

  switch (type) {
    case 'journal-article':
    case 'conference-paper':
      return ids['doi'] ?? '-';

    case 'book':
    case 'book-chapter':
      final isbn = ids['isbn'];
      final doi = ids['doi'];
      if (isbn != null && doi != null) {
        return '$isbn, $doi';
      }
      return isbn ?? doi ?? '-';

    case 'patent':
      return ids['pat'] ?? '-';

    case 'design':
      return ids['pat'] ?? '-';

    default:
      return '-';
  }
}


  static List<pw.Widget> _buildResearchSection(
    Map<String, dynamic> researchData) {

  final verified =
      researchData['verified']
          as Map<String, List<WorkItem>>;

  final nonVerified =
      researchData['nonVerified']
          as Map<String, List<WorkItem>>;

 final List<pw.Widget> widgets = [];

if (verified.isNotEmpty) {
  widgets.add(_buildGreenHeader('Verified Works'));
  widgets.add(pw.SizedBox(height: 8));

  for (var entry in verified.entries) {
    widgets.add(
      _buildResearchTypeBlock(
        entry.key,
        entry.value,
        true,
      ),
    );
  }
}

if (nonVerified.isNotEmpty) {
  widgets.add(pw.SizedBox(height: 15));
  widgets.add(_buildRedHeader('Non Verified / Pending Works'));
  widgets.add(pw.SizedBox(height: 8));

  for (var entry in nonVerified.entries) {
    widgets.add(
      _buildResearchTypeBlock(
        entry.key,
        entry.value,
        false,
      ),
    );
  }
}

return widgets;

}


  static Future<Map<String, dynamic>> _prepareResearchData(
    FacultyProfile faculty) async {

  final researchIDs = faculty.researchIDs;
  if (researchIDs?.orcidId == null ||
      researchIDs!.orcidId!.isEmpty) {
    return {
      'verified': <String, List<WorkItem>>{},
      'nonVerified': <String, List<WorkItem>>{},
    };
  }

  // 🔹 1. Fetch ORCID Works
  final groupedWorks =
      await OrcidService.fetchGroupedWorks(
          researchIDs.orcidId!);

  final List<WorkItem> allWorks = [];

  groupedWorks.forEach((type, works) {
    allWorks.addAll(works);
  });

  // 🔹 2. Fetch Verification Tree (ALL YEARS)
  final verificationSnapshot =
      await FirebaseFirestore.instance
          .collectionGroup('works')
          .where('facultyId',
              isEqualTo: faculty.userModel.uid)
          .get();

  final Map<String, Map<String, dynamic>>
      verificationMap = {};

  for (var doc in verificationSnapshot.docs) {
    final data = doc.data();
    verificationMap[data['putCode']] = data;
  }

  // 🔹 3. Attach verification
  final Map<String, List<WorkItem>> verified =
      {};
  final Map<String, List<WorkItem>>
      nonVerified = {};

  for (var work in allWorks) {
    final verification =
        verificationMap[work.putCode];

    final status =
        verification?['verificationStatus'];

    if (status == 'VERIFIED') {
      verified
          .putIfAbsent(work.type, () => [])
          .add(work);
    } else {
      nonVerified
          .putIfAbsent(work.type, () => [])
          .add(work);
    }
  }

  // 🔹 4. Sort All Lists
  int sortComparator(
      WorkItem a, WorkItem b) {
    final ay = int.tryParse(a.year ?? '');
    final by = int.tryParse(b.year ?? '');

    if (ay == null && by == null) return 0;
    if (ay == null) return 1;
    if (by == null) return -1;

    return by.compareTo(ay);
  }

  verified.forEach((_, list) {
    list.sort(sortComparator);
  });

  nonVerified.forEach((_, list) {
    list.sort(sortComparator);
  });

  return {
    'verified': verified,
    'nonVerified': nonVerified,
  };
}


static pw.Widget _buildResearchTable(
  String type,
  List<WorkItem> works,
  bool isVerifiedSection,
) {

  final headers =
      _getHeaders(type, isVerifiedSection);

  final data = <List<String>>[];

  for (int i = 0; i < works.length; i++) {
    final w = works[i];

    data.add(
      _buildRowData(
        index: i + 1,
        work: w,
        type: type,
        isVerified: isVerifiedSection,
      ),
    );
  }

  return pw.TableHelper.fromTextArray(
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    ),
    headerDecoration:
        const pw.BoxDecoration(
            color: PdfColors.blue800),
    cellStyle:
        const pw.TextStyle(fontSize: 9),
    headers: headers,
    data: data,
  );
}


static List<String> _getHeaders(
    String type,
    bool isVerifiedSection) {

  final List<String> base = [
    'S.No',
    'Title',
    'Source',
    'Year',
    _identifierColumnName(type),
  ];

  base.add(isVerifiedSection
      ? 'Indexed As'
      : 'Status');

  return base;
}


static Future<
    Map<int, Map<String,
        List<Map<String, dynamic>>>>>
    _prepareFdbData(
        FacultyProfile faculty) async {

  final snapshot =
      await FirebaseFirestore.instance
          .collection('fdb_datum')
          .where('email',
              isEqualTo:
                  faculty.userModel.email)
          .get();

  final Map<int,
          Map<String,
              List<Map<String, dynamic>>>>
      groupedData = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();

    final startDate =
        (data['startDate'] as Timestamp?)
            ?.toDate();

    if (startDate == null) continue;

    final year = startDate.year;
    final type =
        data['type'] ?? 'Unknown';

    groupedData
        .putIfAbsent(year, () => {});
    groupedData[year]!
        .putIfAbsent(type, () => []);
    groupedData[year]![type]!
        .add(data);
  }

  // 🔹 Sort Years Descending
  final sortedYears =
      groupedData.keys.toList()
        ..sort((a, b) => b.compareTo(a));

  final sortedMap = {
    for (var year in sortedYears)
      year: groupedData[year]!
  };

  return sortedMap;
}


static pw.Widget _buildFdbSection(
    Map<int, Map<String,
        List<Map<String, dynamic>>>> fdbData) {

  if (fdbData.isEmpty) {
    return pw.Text(
        'No FDP / Certification records available.');
  }

  final List<Map<String, dynamic>> flatList = [];

  // Flatten year → type → records
  fdbData.forEach((year, typeMap) {
    typeMap.forEach((type, records) {
      for (var record in records) {
        flatList.add({
          ...record,
          'year': year,
          'type': type,
        });
      }
    });
  });

  // Sort by year DESC
  flatList.sort((a, b) =>
      (b['year'] as int)
          .compareTo(a['year'] as int));

  final List<List<String>> tableData =
      [];

  for (int i = 0;
      i < flatList.length;
      i++) {
    final data = flatList[i];

    tableData.add([
      (i + 1).toString(),
      data['year'].toString(),
      data['type'] ?? '-',
      data['title'] ?? '-',
      data['organization'] ?? '-',
      data['duration'] ?? '-',
    ]);
  }

  return pw.TableHelper.fromTextArray(
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    ),
    headerDecoration:
        const pw.BoxDecoration(
            color: PdfColors.indigo800),
    cellStyle:
        const pw.TextStyle(fontSize: 9),
    headers: [
      'S.No',
      'Year',
      'Type',
      'Title',
      'Organization',
      'Duration',
    ],
    data: tableData,
  );
}


}
