import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/faculty_profile.dart';

class PDFService {
  // Generate Complete Faculty Profile PDF
  static Future<void> generateFacultyPDF(FacultyProfile faculty) async {
    final pdf = pw.Document();
    
    // Load profile image if available
    pw.ImageProvider? profileImage;
    if (faculty.userModel.profilePictureURL != null) {
      try {
        final response = await http.get(Uri.parse(faculty.userModel.profilePictureURL!));
        if (response.statusCode == 200) {
          profileImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // Fallback to placeholder if network image fails
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(faculty, profileImage),
            pw.SizedBox(height: 20),
            
            // Personal Information
            _buildSectionHeader('Personal Information'),
            _buildPersonalInfoTable(faculty),
            pw.SizedBox(height: 20),
            
            // Research IDs
            _buildSectionHeader('Research IDs'),
            _buildResearchIDsTable(faculty),
            pw.SizedBox(height: 20),
            
            // Work Experience
            _buildSectionHeader('Work Experience'),
            _buildWorkExperienceList(faculty),
            pw.SizedBox(height: 10),
            _buildCITExperience(faculty),
            pw.SizedBox(height: 20),
            
            // Educational Qualification
            _buildSectionHeader('Educational Qualification'),
            _buildEducationTable(faculty),
            pw.SizedBox(height: 20),
            
             // Placeholders for future sections
            _buildSectionHeader('Research & Patents'),
            pw.Text('[Research data will be displayed here]'),
            pw.SizedBox(height: 20),
            
            _buildSectionHeader('FDB & Certifications'),
            pw.Text('[FDB data will be displayed here]'),

            // Footer
            pw.SizedBox(height: 40),
             pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),
                pw.Text(
                  'Research CSE Admin Portal',
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${faculty.personalInfo.name.replaceAll(' ', '_')}_Profile.pdf',
    );
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
}
