import 'package:flutter/material.dart';
import '../../models/faculty_profile.dart'; // Ensure this model exists and is exported
import '../../utils/constants.dart'; // Ensure constants are available
import '../../services/pdf_service.dart';

class AdminGeneralInfoScreen extends StatelessWidget {
  final FacultyProfile faculty;

  const AdminGeneralInfoScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(faculty.personalInfo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
               PDFService.generateGeneralInfoPDF(faculty);
            },
            tooltip: 'Print General Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            _buildPersonalInformationCard(context),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildResearchIDsCard(context),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildWorkExperienceCard(context),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildEducationCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformationCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        initiallyExpanded: true,
        children: [
          _buildInfoRow('Name', faculty.personalInfo.name),
          _buildInfoRow('Designation', faculty.personalInfo.designation),
          _buildInfoRow('Department', faculty.personalInfo.department),
          _buildInfoRow('Age', '${faculty.personalInfo.age}'),
          _buildInfoRow('Date of Birth', faculty.personalInfo.dateOfBirth),
          _buildInfoRow('Date of Joining', faculty.personalInfo.dateOfJoining),
           _buildInfoRow('PAN Number', faculty.personalInfo.panNumber),
          _buildInfoRow('Aadhar Number', faculty.personalInfo.aadharNumber),
          _buildInfoRow('Contact', faculty.personalInfo.contactNo),
           _buildInfoRow('WhatsApp', faculty.personalInfo.whatsappNo),
          _buildInfoRow('Email', faculty.personalInfo.mailId),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResearchIDsCard(BuildContext context) {
    final ids = faculty.researchIDs;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.card_membership, color: Colors.green),
            SizedBox(width: 8),
            Text('Research IDs', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          if (ids != null) ...[
            _buildInfoRow('Vidwan ID', ids.vidwanId ?? 'N/A'),
            _buildInfoRow('Scopus ID', ids.scopusId ?? 'N/A'),
             _buildInfoRow('ORCID ID', ids.orcidId ?? 'N/A'),
            _buildInfoRow('Google Scholar ID', ids.googleScholarId ?? 'N/A'),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No Research IDs available'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWorkExperienceCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.work, color: Colors.orange),
            SizedBox(width: 8),
            Text('Work Experience', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          if (faculty.workExperiences.isEmpty)
             const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No work experience listed'),
            )
          else
            ...faculty.workExperiences.map((exp) => ListTile(
                  title: Text(exp.institutionName),
                  subtitle: Text('${exp.yearsOfExperience} years'),
                  leading: const Icon(Icons.business),
                )),
           const Divider(),
           if (faculty.calculatedCITYears > 0)
             ListTile(
              title: const Text('CIT Experience', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Chip(
                label: Text('${faculty.calculatedCITYears} years'),
                backgroundColor: Colors.orange[100],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.purple),
            SizedBox(width: 8),
            Text('Educational Qualification',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          if (faculty.educationQualifications.isEmpty)
             const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No education listed'),
            )
          else
            ...faculty.educationQualifications.map((edu) => ListTile(
                  title: Text(edu.course),
                  subtitle: Text(edu.institutionName),
                  trailing: Text(
                      '${edu.startYear} - ${edu.endYear}\n(${edu.duration} years)'),
                  isThreeLine: true,
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
