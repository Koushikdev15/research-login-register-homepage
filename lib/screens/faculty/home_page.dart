import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../services/orcid_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/profile_picture_widget.dart';
import '../../widgets/info_display_card.dart';
import '../../widgets/work_experience_card.dart';
import '../../widgets/education_card.dart';
import '../login_selection_screen.dart';
import 'profile_edit_page.dart';
import '../../services/drive_service.dart';
import 'dart:io';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 // final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
final DriveService _driveService = DriveService();


  // 🔢 Academic Counts
  int totalWorks = 0;
  int journalCount = 0;
  int conferenceCount = 0;
  int bookChapterCount = 0;
  int bookCount = 0;
  int patentCount = 0;
  int designCount = 0;

  // 🔢 Indexing Counts
  int scopusCount = 0;
  int sciCount = 0;
  int isbnCount = 0;
  int patentIndexCount = 0;


  // 🔢 Verification Counts
  int verifiedCount = 0;
  int notVerifiedCount = 0;
  int pendingCount = 0;
  bool _summaryTriggered = false; 
  bool _summaryLoading = false;




Widget _buildEditStatusBanner(FacultyProvider provider) {
  final status = provider.editRequestStatus;

  if (status == null) return const SizedBox.shrink();

  Color bgColor;
  IconData icon;
  String message;

  if (status == 'PENDING') {
    bgColor = Colors.orange.shade100;
    icon = Icons.hourglass_top;
    message = 'Your profile edit request is under review.';
  } else if (status == 'APPROVED') {
    bgColor = Colors.green.shade100;
    icon = Icons.check_circle;
    message = 'Your profile edit request was approved.';
  } else {
    bgColor = Colors.red.shade100;
    icon = Icons.cancel;
    message = 'Your profile edit request was rejected.';
  }

  String? reviewedDate;
  if (provider.editRequestReviewedAt != null) {
    final date = provider.editRequestReviewedAt!;
    reviewedDate = '${date.day}/${date.month}/${date.year}';
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (reviewedDate != null)
                Text(
                  'Reviewed on: $reviewedDate',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}


 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final facultyProvider =
        Provider.of<FacultyProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await facultyProvider
          .loadFacultyProfile(authProvider.currentUser!.uid);

      // 🔥 SAFE TRIGGER
      if (!_summaryTriggered) {
        _summaryTriggered = true;
        await _calculateResearchSummary(
          authProvider.currentUser!.uid,
          facultyProvider.researchIDs?.orcidId,
        );
      }
    }
  });
}


 Future<void> _calculateResearchSummary(
    String facultyId, String? orcidId) async {
  if (orcidId == null || orcidId.isEmpty) return;

  setState(() => _summaryLoading = true);

  try {
    // 🟢 Academic Counts (ORCID ONLY)
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

 void _showAvatarOptions() {
  final authProvider =
      Provider.of<AuthProvider>(context, listen: false);

  final photoUrl = authProvider.userModel?.profilePictureURL;
  final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              leading: const Icon(Icons.delete, color: Colors.red),
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
Future<void> _deleteProfilePicture() async {
  try {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final userId = authProvider.currentUserId;
    if (userId == null) return;

    /// 🔴 Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Profile Picture"),
        content: const Text(
            "Are you sure you want to remove your profile picture?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔥 Remove from Firestore
    await authProvider.updateProfilePicture('');

    await authProvider.refreshUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture deleted successfully!'),
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
   void _viewProfilePicture() {
  final authProvider =
      Provider.of<AuthProvider>(context, listen: false);

  final photoUrl = authProvider.userModel?.profilePictureURL;

  if (photoUrl == null || photoUrl.isEmpty) return;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(photoUrl),
          ),
        ),
      );
    },
  );
}

 // ✅ GOOGLE DRIVE PROFILE PICTURE UPLOAD
  Future<void> _updateProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId;

      if (userId == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading profile picture...')),
      );

      final file = File(image.path);

      final fileId = await _driveService.uploadFile(
        file: file,
        folderName: "profile_pictures",
      );

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed')),
        );
        return;
      }

      // Save Drive file ID in Firestore
      await authProvider.updateProfilePicture(fileId);

      await authProvider.refreshUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
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

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context);
    final facultyProvider =
        Provider.of<FacultyProvider>(context);
    final user = authProvider.userModel;

    if (facultyProvider.isLoading) {
      return const Center(
          child: CircularProgressIndicator());
    }

    if (facultyProvider.personalInfo == null &&
        !facultyProvider.isLoading) {
      return Center(
        child: ElevatedButton(
          onPressed: () => facultyProvider
              .loadFacultyProfile(
                  authProvider.currentUserId!),
          child: const Text('Retry Loading Profile'),
        ),
      );
    }

    final personalInfo =
        facultyProvider.personalInfo!;

    // 🔥 Trigger summary once profile loads


return RefreshIndicator(
  onRefresh: () async {
    await facultyProvider
        .loadFacultyProfile(authProvider.currentUserId!);

    await _calculateResearchSummary(
      authProvider.currentUserId!,
      facultyProvider.researchIDs?.orcidId,
      
    );
  },

      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildEditStatusBanner(facultyProvider),
Card(
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Profile Picture

// 🔥 Convert Drive File ID to real image URL
ProfilePictureWidget(
  imageUrl: user?.profilePictureURL,
  size: 80,
  showEditIcon: true,
  onTap: _showAvatarOptions,
),

        const SizedBox(width: 24),

        // 🔹 Name + Designation + Department
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personalInfo.name,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 4),
              Text(
                personalInfo.designation,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.academicBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                personalInfo.department,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),

        // 🔹 Edit + Logout Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           IconButton(
  icon: const Icon(
    Icons.edit,
    color: AppColors.academicBlue,
  ),
  tooltip: 'Edit Profile',
  onPressed: facultyProvider.hasPendingEditRequest
      ? null
      : () {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => ProfileEditPage(
                userId: authProvider.currentUserId!,
                facultyName: personalInfo.name,
                personalInfo: facultyProvider.personalInfo!,
                researchIDs: facultyProvider.researchIDs!,
                citExperience: facultyProvider.citExperience!,
                workExperiences:
                    facultyProvider.workExperiences,
                educationQualifications:
                    facultyProvider.educationQualifications,
              ),
            ),
          );
        },
),

            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.errorRed,
              ),
              onPressed: () async {
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginSelectionScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ],
    ),
  ),
),

                const SizedBox(height: 24),

                isWide
                    ? Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildPersonalInfoCard(
                                    personalInfo),
                                const SizedBox(
                                    height: 24),
                                _buildResearchIDsCard(
                                    facultyProvider),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildCITExperienceCard(
                                    facultyProvider),
                                const SizedBox(
                                    height: 24),
                                _buildExperienceCard(
                                    facultyProvider),
                                const SizedBox(
                                    height: 24),
                                _buildEducationCard(
                                    facultyProvider),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPersonalInfoCard(
                              personalInfo),
                          const SizedBox(
                              height: 24),
                          _buildResearchIDsCard(
                              facultyProvider),
                          const SizedBox(
                              height: 24),
                          _buildCITExperienceCard(
                              facultyProvider),
                          const SizedBox(
                              height: 24),
                          _buildExperienceCard(
                              facultyProvider),
                          const SizedBox(
                              height: 24),
                          _buildEducationCard(
                              facultyProvider),
                        ],
                      ),



              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(
      dynamic personalInfo) {
    return InfoDisplayCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      initiallyExpanded: true,
      child: Column(
        children: [
          _buildInfoRow(
              'Age', '${personalInfo.age}'),
          _buildInfoRow('Date of Birth',
              personalInfo.dateOfBirth),
          _buildInfoRow('Date of Joining',
              personalInfo.dateOfJoining),
          _buildInfoRow(
              'Contact',
              personalInfo.contactNo),
          _buildInfoRow(
              'WhatsApp',
              personalInfo.whatsappNo),
          _buildInfoRow(
              'Email', personalInfo.mailId),
          _buildInfoRow(
              'PAN', personalInfo.panNumber),
          _buildInfoRow(
              'Aadhar',
              personalInfo.aadharNumber),
        ],
      ),
    );
  }

  Widget _buildResearchIDsCard(
      FacultyProvider provider) {
    if (provider.researchIDs == null)
      return const SizedBox.shrink();

    return InfoDisplayCard(
      title: 'Research IDs',
      icon: Icons.science_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Vidwan ID',
              provider.researchIDs!.vidwanId ??
                  'N/A'),
          _buildInfoRow('Scopus ID',
              provider.researchIDs!.scopusId ??
                  'N/A'),
          _buildInfoRow('ORCID',
              provider.researchIDs!.orcidId ??
                  'N/A'),
          _buildInfoRow(
              'Google Scholar',
              provider.researchIDs!
                      .googleScholarId ??
                  'N/A'),

const Divider(height: 32),

if (_summaryLoading)
  const Center(child: CircularProgressIndicator()),

if (!_summaryLoading) ...[
  _sectionTitle('Academic Summary'),
  _chipWrap([
    _chip('Total', totalWorks),
    _chip('Journals', journalCount),
    _chip('Conferences', conferenceCount),
    _chip('Book Chapters', bookChapterCount),
    _chip('Books', bookCount),
    _chip('Utility Patents', patentCount),
    _chip('Design Patents', designCount),
  ]),

  const SizedBox(height: 20),

  /// 🔴 LIVE FIRESTORE SUMMARY
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collectionGroup('works')
      .where('facultyId',
          isEqualTo:
              Provider.of<AuthProvider>(context,
                      listen: false)
                  .currentUserId)
      .where('publicationYear',
          isEqualTo: DateTime.now().year)
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
          data['verificationStatus'] ?? 'PENDING';
      final type =
          data['verificationType'];

      if (status == 'VERIFIED') {
        verified++;

        if (type == 'SCOPUS') scopus++;
        if (type == 'SCI') sci++;
        if (type == 'ISBN') isbn++;
        if (type == 'PATENT') patentIndex++;
      }

      if (status == 'NOT_VERIFIED') notVerified++;
      if (status == 'PENDING') pending++;
    }

    final year = DateTime.now().year;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle('Indexing ($year)'),
        _chipWrap([
          _chip('Scopus', scopus),
          _chip('SCI', sci),
          _chip('ISBN', isbn),
          _chip('Patent', patentIndex),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Verification ($year)'),
        _chipWrap([
          _chip('Verified', verified),
          _chip('Not Verified', notVerified),
          _chip('Pending', pending),
        ]),
      ],
    );
  },
),



]
        ]
),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge
            .copyWith(
                fontWeight:
                    FontWeight.bold),
      ),
    );
  }

  Widget _chip(String label, int count) {
    return Chip(
      label: Text('$label: $count'),
    );
  }

  Widget _chipWrap(
      List<Widget> chips) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildInfoRow(
      String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles
                  .bodyRegular
                  .copyWith(
                      color: AppColors
                          .mediumGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles
                  .bodyRegular
                  .copyWith(
                      color:
                          AppColors.charcoal,
                      fontWeight:
                          FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCITExperienceCard(
      FacultyProvider provider) {
    if (provider.citExperience == null)
      return const SizedBox.shrink();

    return Card(
      color: AppColors.academicBlue,
      child: Padding(
        padding:
            const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            const Text(
              'Experience at CIT',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets
                  .symmetric(
                      horizontal: 16,
                      vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        20),
              ),
              child: Text(
                '${provider.citExperience!.years} Years',
                style: const TextStyle(
                    color: AppColors
                        .academicBlue,
                    fontWeight:
                        FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(
      FacultyProvider provider) {
    if (provider.workExperiences
        .isEmpty)
      return const SizedBox.shrink();

    return InfoDisplayCard(
      title: 'Work Experience',
      icon: Icons.work_outline,
      child: Column(
        children: provider
            .workExperiences
            .map((exp) =>
                WorkExperienceCard(
                    experience: exp,
                    isReadOnly: true))
            .toList(),
      ),
    );
  }

  Widget _buildEducationCard(
      FacultyProvider provider) {
    if (provider
        .educationQualifications
        .isEmpty)
      return const SizedBox.shrink();

    return InfoDisplayCard(
      title: 'Education',
      icon: Icons.school_outlined,
      child: Column(
        children: provider
            .educationQualifications
            .map((edu) =>
                EducationQualificationCard(
                    education: edu,
                    isReadOnly: true))
            .toList(),
      ),
    );
  }
}
