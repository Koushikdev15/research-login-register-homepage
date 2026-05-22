import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/faculty_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../services/drive_service.dart';
import '../../services/orcid_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/education_card.dart';
import '../../widgets/profile_picture_widget.dart';
import '../../widgets/work_experience_card.dart';
import '../../widgets/scopus_home_summary.dart';



class HomePage extends StatefulWidget {

  final String? facultyId;

  const HomePage({
    super.key,
    this.facultyId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// Image picker
  final ImagePicker _picker = ImagePicker();

  /// Google Drive service
  final DriveService _driveService = DriveService();

  /// 🔢 Academic Counts
  int totalWorks = 0;
  int journalCount = 0;
  int conferenceCount = 0;
  int bookChapterCount = 0;
  int bookCount = 0;
  int patentCount = 0;
  int designCount = 0;

  /// 🔢 Indexing Counts
  int scopusCount = 0;
  int sciCount = 0;
  int isbnCount = 0;
  int patentIndexCount = 0;

  /// 🔢 Verification Counts
  int verifiedCount = 0;
  int notVerifiedCount = 0;
  int pendingCount = 0;

  bool _summaryTriggered = false;
  bool _summaryLoading = false;
    @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      final facultyProvider =
          Provider.of<FacultyProvider>(context, listen: false);

      final targetFacultyId =
    widget.facultyId ??
    authProvider.currentUser?.uid;

if (targetFacultyId != null) {

  await facultyProvider
      .loadFacultyProfile(targetFacultyId);

  if (!_summaryTriggered) {

    _summaryTriggered = true;

    await _calculateResearchSummary(
      targetFacultyId,
      facultyProvider.researchIDs?.orcidId,
    );
  }
}

    });
  }
  /// 🔎 Calculate ORCID research summary
  Future<void> _calculateResearchSummary(
      String facultyId, String? orcidId) async {

    if (orcidId == null || orcidId.isEmpty) return;

    setState(() => _summaryLoading = true);

    try {

      final grouped =
          await OrcidService.fetchGroupedWorks(orcidId);

      final counts =
          OrcidService.calculateCounts(grouped);

      if (!mounted) return;

      setState(() {
        totalWorks = counts['total'] ?? 0;
        journalCount = counts['journal'] ?? 0;
        conferenceCount = counts['conference'] ?? 0;
        bookChapterCount = counts['bookChapter'] ?? 0;
        bookCount = counts['book'] ?? 0;
        patentCount = counts['patent'] ?? 0;
        designCount = counts['design'] ?? 0;

        _summaryLoading = false;
      });

    } catch (_) {
      if (mounted) {
        setState(() => _summaryLoading = false);
      }
    }
  }

  /// 🖼 Avatar Options
  void _showAvatarOptions() {

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final photoUrl = authProvider.userModel?.profilePictureURL;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const SizedBox(height: 16),

              const Text(
                "Profile Picture",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// 👁 VIEW
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("View"),
                enabled: hasPhoto,
                onTap: hasPhoto
                    ? () {
                        Navigator.pop(context);
                        _viewProfilePicture();
                      }
                    : null,
              ),

              /// ✏ EDIT
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfilePicture();
                },
              ),

              /// 🗑 DELETE
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                enabled: hasPhoto,
                onTap: hasPhoto
                    ? () {
                        Navigator.pop(context);
                        _deleteProfilePicture();
                      }
                    : null,
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// 👁 View Profile Picture
  void _viewProfilePicture() {

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final photoUrl =
        authProvider.userModel?.profilePictureURL;

    if (photoUrl == null || photoUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {

        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://drive.google.com/uc?export=view&id=$photoUrl",
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🗑 Delete Profile Picture
  Future<void> _deleteProfilePicture() async {

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final userId = authProvider.currentUserId;
    if (userId == null) return;

    await authProvider.updateProfilePicture('');
    await authProvider.refreshUserData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture deleted successfully!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  /// 📤 Upload Profile Picture to Drive
  Future<void> _updateProfilePicture() async {

    try {

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      final file = File(image.path);

      final fileId = await _driveService.uploadFile(
        file: file,
        folderName: "profile_pictures",
      );

      if (fileId == null) return;

      await authProvider.updateProfilePicture(fileId);
      await authProvider.refreshUserData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Profile picture updated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
    
@override Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    final facultyProvider = Provider.of<FacultyProvider>(context);

    if (facultyProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (facultyProvider.personalInfo == null) {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

    final personalInfo = facultyProvider.personalInfo!;

   return Scaffold(
    backgroundColor: Colors.transparent,
    body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE8F1FF),
          Color(0xFFF5F9FF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: RefreshIndicator(

        onRefresh: () async {

          await facultyProvider.loadFacultyProfile(
  widget.facultyId ??
      authProvider.currentUserId!,
);

await _calculateResearchSummary(
  widget.facultyId ??
      authProvider.currentUserId!,
  facultyProvider.researchIDs?.orcidId,
);
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              /// 👤 PROFILE CARD
              Card(
              elevation: 6,
              color: const Color(0xFFF7FBFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    children: [

                      /// PROFILE PHOTO
                      FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(
        widget.facultyId ??
            authProvider.currentUserId,
      )
      .get(),

  builder: (context, snapshot) {

    String? profileUrl;

    if (snapshot.hasData && snapshot.data!.exists) {

      final data =
          snapshot.data!.data()
              as Map<String, dynamic>;

      profileUrl =
          data['profilePictureURL'];
    }

    return ProfilePictureWidget(
      imageUrl:
          profileUrl != null &&
                  profileUrl.isNotEmpty
              ? "https://drive.google.com/uc?export=view&id=$profileUrl"
              : null,

      size: 110,
      showEditIcon: true,
      onTap: _showAvatarOptions,
    );
  },
),

                      const SizedBox(height: 16),

                      /// NAME
                      Text(
                        personalInfo.name,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3,
                      ),

                      const SizedBox(height: 4),

                      /// DESIGNATION
                      Text(
                        personalInfo.designation,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.academicBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// DEPARTMENT
                      Text(
                        personalInfo.department,
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🏫 CIT EXPERIENCE
                      _buildCITExperienceCard(facultyProvider),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
                            /// PERSONAL INFORMATION
              Card(
              elevation: 4,
              color: const Color(0xFFF8FAFF),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: const [
                          Icon(Icons.person_outline),
                          SizedBox(width: 8),
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoRow("Age", "${personalInfo.age}"),
                      _buildInfoRow("Date of Birth", personalInfo.dateOfBirth),
                      _buildInfoRow("Date of Joining", personalInfo.dateOfJoining),
                      _buildInfoRow("Contact", personalInfo.contactNo),
                      _buildInfoRow("WhatsApp", personalInfo.whatsappNo),
                      _buildInfoRow("Email", personalInfo.mailId),
                      _buildInfoRow("PAN", personalInfo.panNumber),
                      _buildInfoRow("Aadhar", personalInfo.aadharNumber),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// RESEARCH IDs
              if (facultyProvider.researchIDs != null)
              Card(
              elevation: 4,
              color: const Color(0xFFF8FAFF),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: const [
                          Icon(Icons.science_outlined),
                          SizedBox(width: 8),
                          Text(
                            "Research IDs",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoRow(
  "Vidwan ID",
  facultyProvider.researchIDs?.vidwanId ?? "N/A",
),

_buildInfoRow(
  "Scopus ID",
  facultyProvider.researchIDs?.scopusId ?? "N/A",
),

_buildInfoRow(
  "ORCID",
  facultyProvider.researchIDs?.orcidId ?? "N/A",
),

_buildInfoRow(
  "Google Scholar",
  facultyProvider.researchIDs?.googleScholarId ?? "N/A",
),

_buildInfoRow(
  "Researcher ID",
  facultyProvider.researchIDs?.researcherId ?? "N/A",
),

_buildInfoRow(
  "WOS ID",
  facultyProvider.researchIDs?.wosId ?? "N/A",
),

                      const Divider(height: 32),

                     /// 🔵 SCOPUS SUMMARY BOX
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('faculty_scopus_works')
.doc(
  widget.facultyId ??
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUserId,
)
      .snapshots(),
  builder: (context, snapshot) {

    int scopusTotal = 0;

    if (snapshot.hasData && snapshot.data!.exists) {
      final data = snapshot.data!.data() as Map<String, dynamic>;
      scopusTotal = data['totalWorks'] ?? 0;
    }

    return ScopusHomeSummary(count: scopusTotal);
  },
),
                      /// Academic Summary
                      if (_summaryLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),

                      if (!_summaryLoading) ...[

                        const Text(
                          "Academic Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _chipWrap([
                          _chip("Total", totalWorks),
                          _chip("Journals", journalCount),
                          _chip("Conferences", conferenceCount),
                          _chip("Book Chapters", bookChapterCount),
                          _chip("Books", bookCount),
                          _chip("Utility Patents", patentCount),
                          _chip("Design Patents", designCount),
                        ]),

                        const SizedBox(height: 20),

                        /// FIRESTORE INDEXING + VERIFICATION
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup("works")
                              .where(
                                "facultyId",
                                isEqualTo: Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).currentUserId,
                              )
                              .where(
                                "publicationYear",
                                isEqualTo: DateTime.now().year,
                              )
                              .snapshots(),
                          builder: (context, snapshot) {

                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            int scopus = 0;
                            int sci = 0;
                            int isbn = 0;
                            int patentIndex = 0;

                            int verified = 0;
                            int notVerified = 0;
                            int pending = 0;

                            for (var doc in snapshot.data!.docs) {

                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final status =
                                  data["verificationStatus"] ?? "PENDING";

                              final type = data["verificationType"];

                              if (status == "VERIFIED") {

                                verified++;

                                if (type == "SCOPUS") scopus++;
                                if (type == "SCI") sci++;
                                if (type == "ISBN") isbn++;
                                if (type == "PATENT") patentIndex++;
                              }

                              if (status == "NOT_VERIFIED") notVerified++;
                              if (status == "PENDING") pending++;
                            }

                            final year = DateTime.now().year;

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                const SizedBox(height: 20),

                                Text(
                                  "Indexing ($year)",
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 10),

                                _chipWrap([
                                  _chip("Scopus", scopus),
                                  _chip("SCI", sci),
                                  _chip("ISBN", isbn),
                                  _chip("Patent", patentIndex),
                                ]),

                                const SizedBox(height: 20),

                                Text(
                                  "Verification ($year)",
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 10),

                                _chipWrap([
                                  _chip("Verified", verified),
                                  _chip("Not Verified", notVerified),
                                  _chip("Pending", pending),
                                ]),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
                            /// WORK EXPERIENCE
              if (facultyProvider.workExperiences.isNotEmpty)
              Card(
              elevation: 3,
              color: const Color(0xFFF8FAFF),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: const [
                          Icon(Icons.work_outline),
                          SizedBox(width: 8),
                          Text(
                            "Work Experience",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
  children: facultyProvider.workExperiences
      .map((exp) {
        return WorkExperienceCard(
          experience: exp,
          isReadOnly: false,

          onEdit: (experience) {
            _editWorkExperience(experience);
          },

          onDelete: (id) {
            _deleteWorkExperience(id);
          },
        );
      }).toList(),
),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// EDUCATION
              if (facultyProvider.educationQualifications.isNotEmpty)
              Card(
              elevation: 3,
              color: const Color(0xFFF8FAFF),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: const [
                          Icon(Icons.school_outlined),
                          SizedBox(width: 8),
                          Text(
                            "Education",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Column(
                        children: facultyProvider.educationQualifications
                            .map(
                              (edu) => EducationQualificationCard(
                                education: edu,
                                isReadOnly: true,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    ), 
    );
  }

  /// INFO ROW
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(String label, int count) {
    return Chip(
      label: Text("$label: $count"),
    );
  }

  /// CHIP WRAP
  Widget _chipWrap(List<Widget> chips) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
  void _editWorkExperience(WorkExperience exp) {

  final institutionController =
      TextEditingController(text: exp.institutionName);

  final yearsController =
      TextEditingController(text: exp.yearsOfExperience.toString());

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: const Text("Edit Work Experience"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Institution
            TextField(
              controller: institutionController,
              decoration: const InputDecoration(
                labelText: "Institution Name",
              ),
            ),

            const SizedBox(height: 16),

            /// Years
            TextField(
              controller: yearsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Years of Experience",
              ),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              final facultyProvider =
                  Provider.of<FacultyProvider>(context, listen: false);

              final updatedExperience = WorkExperience(
                id: exp.id,
                institutionName: institutionController.text.trim(),
                yearsOfExperience:
                    int.tryParse(yearsController.text) ?? 0,
                addedAt: exp.addedAt,
              );

              /// Update Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.facultyId ??authProvider.currentUserId,)
                  .collection('workExperience')
                  .doc(exp.id)
                  .update(updatedExperience.toMap());

              /// Reload experiences
              await facultyProvider.loadWorkExperiences(
                authProvider.currentUserId!,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Experience Updated Successfully"),
                ),
              );
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}
void _deleteWorkExperience(String id) {

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: const Text("Delete Experience"),

        content: const Text(
          "Are you sure you want to delete this experience?",
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {

              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              final facultyProvider =
                  Provider.of<FacultyProvider>(context, listen: false);

              await facultyProvider.deleteWorkExperience(
                 widget.facultyId ??
                 authProvider.currentUserId!,
                 id,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Experience Deleted Successfully"),
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}
  /// CIT EXPERIENCE CARD
  Widget _buildCITExperienceCard(FacultyProvider provider) {

    if (provider.personalInfo == null) {
      return const SizedBox();
    }

    final joiningDateStr = provider.personalInfo!.dateOfJoining;

    int years = 0;
    int months = 0;

    try {

      final parts = joiningDateStr.split("/");

      if (parts.length == 3) {

        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final joiningDate = DateTime(year, month, day);
        final today = DateTime.now();

        years = today.year - joiningDate.year;
        months = today.month - joiningDate.month;

        if (today.day < joiningDate.day) {
          months--;
        }

        if (months < 0) {
          years--;
          months += 12;
        }
      }

    } catch (_) {}

    String experienceText = "$years Years $months Months";

    String milestoneText = "";

    if (months == 11) {
      milestoneText =
          "🎉 ${years + 1}-Year Service Milestone Next Month";
    }

    return Card(
      color: AppColors.academicBlue,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Experience at CIT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              experienceText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (milestoneText.isNotEmpty)
              Text(
                milestoneText,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

}