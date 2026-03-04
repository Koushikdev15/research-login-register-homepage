import 'package:flutter/material.dart';
import '../../models/faculty_profile.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AdminGeneralInfoScreen extends StatelessWidget {
  final FacultyProfile faculty;

  const AdminGeneralInfoScreen({
    super.key,
    required this.faculty,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final containerWidth = isWide ? 1000.0 : double.infinity;

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            title: Text(faculty.personalInfo.name),
            backgroundColor: AppColors.pureWhite,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print General Info',
                onPressed: () {
                  PDFService.generateGeneralInfoPDF(faculty);
                },
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: containerWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildPersonalInformationCard(context),
                                const SizedBox(height: 24),
                                _buildResearchIDsCard(context),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildWorkExperienceCard(context),
                                const SizedBox(height: 24),
                                _buildEducationCard(context),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPersonalInformationCard(context),
                          const SizedBox(height: 24),
                          _buildResearchIDsCard(context),
                          const SizedBox(height: 24),
                          _buildWorkExperienceCard(context),
                          const SizedBox(height: 24),
                          _buildEducationCard(context),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =======================================================
  // CARDS
  // =======================================================

  Widget _buildPersonalInformationCard(BuildContext context) {
    return _styledCard(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildInfoRow(context, 'Name', faculty.personalInfo.name),
        _buildInfoRow(context, 'Designation', faculty.personalInfo.designation),
        _buildInfoRow(context, 'Department', faculty.personalInfo.department),
        _buildInfoRow(context, 'Age', '${faculty.personalInfo.age}'),
        _buildInfoRow(context, 'Date of Birth', faculty.personalInfo.dateOfBirth),
        _buildInfoRow(context, 'Date of Joining', faculty.personalInfo.dateOfJoining),
        _buildInfoRow(context, 'PAN Number', faculty.personalInfo.panNumber),
        _buildInfoRow(context, 'Aadhar Number', faculty.personalInfo.aadharNumber),
        _buildInfoRow(context, 'Contact', faculty.personalInfo.contactNo),
        _buildInfoRow(context, 'WhatsApp', faculty.personalInfo.whatsappNo),
        _buildInfoRow(context, 'Email', faculty.personalInfo.mailId),
      ],
    );
  }

  Widget _buildResearchIDsCard(BuildContext context) {
    final ids = faculty.researchIDs;

    return _styledCard(
      title: 'Research IDs',
      icon: Icons.card_membership,
      children: ids != null
          ? [
              _buildInfoRow(context, 'Vidwan ID', ids.vidwanId ?? 'N/A'),
              _buildInfoRow(context, 'Scopus ID', ids.scopusId ?? 'N/A'),
              _buildInfoRow(context, 'ORCID ID', ids.orcidId ?? 'N/A'),
              _buildInfoRow(context, 'Google Scholar ID', ids.googleScholarId ?? 'N/A'),
            ]
          : [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No Research IDs available'),
              )
            ],
    );
  }

  Widget _buildWorkExperienceCard(BuildContext context) {
    return _styledCard(
      title: 'Work Experience',
      icon: Icons.work,
      children: faculty.workExperiences.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No work experience listed'),
              )
            ]
          : [
              ...faculty.workExperiences.map(
                (exp) => ListTile(
                  title: Text(exp.institutionName),
                  subtitle: Text('${exp.yearsOfExperience} years'),
                  leading: const Icon(Icons.business),
                ),
              ),
              const Divider(),
              if (faculty.calculatedCITYears > 0)
                ListTile(
                  title: const Text(
                    'CIT Experience',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Chip(
                    label: Text('${faculty.calculatedCITYears} years'),
                    backgroundColor:
                        AppColors.academicBlue.withOpacity(0.1),
                  ),
                ),
            ],
    );
  }

  Widget _buildEducationCard(BuildContext context) {
    return _styledCard(
      title: 'Educational Qualification',
      icon: Icons.school,
      children: faculty.educationQualifications.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No education listed'),
              )
            ]
          : faculty.educationQualifications
              .map(
                (edu) => ListTile(
                  title: Text(edu.course),
                  subtitle: Text(edu.institutionName),
                  trailing: Text(
                    '${edu.startYear} - ${edu.endYear}\n(${edu.duration} years)',
                    textAlign: TextAlign.right,
                  ),
                  isThreeLine: true,
                ),
              )
              .toList(),
    );
  }

  // =======================================================
  // REUSABLE CARD STYLE
  // =======================================================

  Widget _styledCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Icon(icon, color: AppColors.universityNavy),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          ...children,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // =======================================================
  // RESPONSIVE INFO ROW
  // =======================================================

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelWidth = screenWidth > 900 ? 180.0 : 120.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
