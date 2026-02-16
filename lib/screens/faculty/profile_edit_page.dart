import 'package:flutter/material.dart';
import '../../models/faculty_model.dart';
import '../../services/faculty_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/info_display_card.dart';

class ProfileEditPage extends StatefulWidget {
  final String userId;
  final String facultyName;
  final PersonalInfo personalInfo;
  final ResearchIDs researchIDs;
  final CITExperience citExperience;
  final List<WorkExperience> workExperiences;
  final List<EducationQualification> educationQualifications;

  const ProfileEditPage({
    super.key,
    required this.userId,
    required this.facultyName,
    required this.personalInfo,
    required this.researchIDs,
    required this.citExperience,
    required this.workExperiences,
    required this.educationQualifications,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late PersonalInfo _editedPersonalInfo;
  late ResearchIDs _editedResearchIDs;
  late CITExperience _editedCITExperience;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _editedPersonalInfo = widget.personalInfo.copy();
    _editedResearchIDs = widget.researchIDs.copy();
    _editedCITExperience = widget.citExperience.copy();
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);

    try {
      await FacultyService().submitProfileEditRequest(
        userId: widget.userId,
        facultyName: widget.facultyName,
        updatedPersonalInfo: _editedPersonalInfo,
        updatedResearchIDs: _editedResearchIDs,
        updatedCITExperience: _editedCITExperience,
        updatedWorkExperiences: widget.workExperiences,
        updatedEducationQualifications:
            widget.educationQualifications,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Edit request submitted successfully"),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.pureWhite,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPersonalInfoCard(),
            const SizedBox(height: 24),
            _buildResearchIDsCard(),
            const SizedBox(height: 24),
            _buildCITCard(),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSubmitting
                    ? "Submitting..."
                    : "Submit Edit Request",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.academicBlue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
              onPressed:
                  _isSubmitting ? null : _submitRequest,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // PERSONAL INFO CARD
  // ===============================

  Widget _buildPersonalInfoCard() {
    return InfoDisplayCard(
      title: "Personal Information",
      icon: Icons.person_outline,
      initiallyExpanded: true,
      child: Column(
        children: [
          _editableField(
            "Age",
            _editedPersonalInfo.age.toString(),
            (val) {
              setState(() {
                _editedPersonalInfo =
                    _editedPersonalInfo.copyWith(
                  age: int.tryParse(val) ?? 0,
                );
              });
            },
          ),
          _editableField(
            "Contact",
            _editedPersonalInfo.contactNo,
            (val) {
              setState(() {
                _editedPersonalInfo =
                    _editedPersonalInfo.copyWith(
                  contactNo: val,
                );
              });
            },
          ),
          _editableField(
            "Email",
            _editedPersonalInfo.mailId,
            (val) {
              setState(() {
                _editedPersonalInfo =
                    _editedPersonalInfo.copyWith(
                  mailId: val,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // ===============================
  // RESEARCH IDS CARD
  // ===============================

  Widget _buildResearchIDsCard() {
    return InfoDisplayCard(
      title: "Research IDs",
      icon: Icons.science_outlined,
      child: Column(
        children: [
          _editableField(
            "ORCID",
            _editedResearchIDs.orcidId ?? "",
            (val) {
              setState(() {
                _editedResearchIDs =
                    _editedResearchIDs.copyWith(
                  orcidId: val,
                );
              });
            },
          ),
          _editableField(
            "Scopus ID",
            _editedResearchIDs.scopusId ?? "",
            (val) {
              setState(() {
                _editedResearchIDs =
                    _editedResearchIDs.copyWith(
                  scopusId: val,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // ===============================
  // CIT EXPERIENCE CARD
  // ===============================

  Widget _buildCITCard() {
    return InfoDisplayCard(
      title: "Experience at CIT",
      icon: Icons.work_outline,
      child: _editableField(
        "Years",
        _editedCITExperience.years.toString(),
        (val) {
          setState(() {
            _editedCITExperience =
                _editedCITExperience.copyWith(
              years: int.tryParse(val) ?? 0,
            );
          });
        },
      ),
    );
  }

  // ===============================
  // REUSABLE FIELD
  // ===============================

  Widget _editableField(
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
