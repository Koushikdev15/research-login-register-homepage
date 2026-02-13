import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/profile_picture_widget.dart';
import '../../widgets/info_display_card.dart';
import '../../widgets/work_experience_card.dart';
import '../../widgets/education_card.dart';
import '../login_selection_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final facultyProvider = Provider.of<FacultyProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        facultyProvider.loadFacultyProfile(authProvider.currentUser!.uid);
      }
    });
  }

  Future<void> _updateProfilePicture() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening image picker...'), duration: Duration(seconds: 1)),
        );
      }

      final XFile? image = await _storageService.pickImageFromGallery();
      
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected'), backgroundColor: AppColors.mediumGray),
          );
        }
        return;
      }

      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUserId;
        
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in'), backgroundColor: AppColors.errorRed),
          );
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile picture...'), duration: Duration(seconds: 2)),
        );

        final downloadUrl = await _storageService.uploadProfilePicture(userId, image);
        
        print('Profile picture uploaded successfully: $downloadUrl');
        
        await authProvider.refreshUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'), 
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'), 
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final facultyProvider = Provider.of<FacultyProvider>(context);
    final user = authProvider.userModel;

    // Debug: Print user profile picture URL
    print('User profile picture URL: ${user?.profilePictureURL}');
    print('User ID: ${authProvider.currentUserId}');

    if (facultyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (facultyProvider.personalInfo == null && !facultyProvider.isLoading) {
       return Center(
         child: ElevatedButton(
           onPressed: () => facultyProvider.loadFacultyProfile(authProvider.currentUserId!),
           child: const Text('Retry Loading Profile'),
         ),
       );
    }

    final personalInfo = facultyProvider.personalInfo!;
    
    return RefreshIndicator(
      onRefresh: () => facultyProvider.loadFacultyProfile(authProvider.currentUserId!),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfilePictureWidget(
                          imageUrl: user?.profilePictureURL,
                          size: 80,
                          showEditIcon: true,
                          onTap: _updateProfilePicture,
                        ),
                        const SizedBox(width: 24),
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
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.academicBlue, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                personalInfo.department,
                                style: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons could go here
                        IconButton(
                          icon: const Icon(Icons.logout, color: AppColors.errorRed),
                          tooltip: 'Logout',
                          onPressed: () async {
                             await authProvider.signOut();
                             if (mounted) {
                               Navigator.of(context).pushAndRemoveUntil(
                                 MaterialPageRoute(builder: (context) => const LoginSelectionScreen()),
                                 (route) => false,
                               );
                             }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Grid or Column Content
                 isWide 
                 ? Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Expanded(
                         child: Column(
                           children: [
                             _buildPersonalInfoCard(personalInfo),
                             const SizedBox(height: 24),
                             _buildResearchIDsCard(facultyProvider),
                           ],
                         ),
                       ),
                       const SizedBox(width: 24),
                       Expanded(
                         child: Column(
                           children: [
                             _buildCITExperienceCard(facultyProvider),
                             const SizedBox(height: 24),
                             _buildExperienceCard(facultyProvider),
                             const SizedBox(height: 24),
                             _buildEducationCard(facultyProvider),
                           ],
                         ),
                       ),
                     ],
                   )
                 : Column(
                     children: [
                       _buildPersonalInfoCard(personalInfo),
                       const SizedBox(height: 24),
                       _buildResearchIDsCard(facultyProvider),
                       const SizedBox(height: 24),
                       _buildCITExperienceCard(facultyProvider),
                       const SizedBox(height: 24),
                       _buildExperienceCard(facultyProvider),
                       const SizedBox(height: 24),
                       _buildEducationCard(facultyProvider),
                     ],
                   ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(dynamic personalInfo) {
    return InfoDisplayCard(
       title: 'Personal Information',
       icon: Icons.person_outline,
       initiallyExpanded: true,
       child: Column(
         children: [
           _buildInfoRow('Age', '${personalInfo.age}'),
           _buildInfoRow('Date of Birth', personalInfo.dateOfBirth),
           _buildInfoRow('Date of Joining', personalInfo.dateOfJoining),
           _buildInfoRow('Contact', personalInfo.contactNo),
           _buildInfoRow('WhatsApp', personalInfo.whatsappNo),
           _buildInfoRow('Email', personalInfo.mailId),
           _buildInfoRow('PAN', personalInfo.panNumber),
           _buildInfoRow('Aadhar', personalInfo.aadharNumber),
         ],
       ),
    );
  }

  Widget _buildResearchIDsCard(FacultyProvider provider) {
    if (provider.researchIDs == null) return const SizedBox.shrink();
    return InfoDisplayCard(
      title: 'Research IDs',
      icon: Icons.science_outlined,
      child: Column(
        children: [
          _buildInfoRow('Vidwan ID', provider.researchIDs!.vidwanId ?? 'N/A'),
          _buildInfoRow('Scopus ID', provider.researchIDs!.scopusId ?? 'N/A'),
          _buildInfoRow('ORCID', provider.researchIDs!.orcidId ?? 'N/A'),
          _buildInfoRow('Google Scholar', provider.researchIDs!.googleScholarId ?? 'N/A'),
        ],
      ),
    );
  }
  
  Widget _buildCITExperienceCard(FacultyProvider provider) {
    if (provider.citExperience == null) return const SizedBox.shrink();
    return Card(
      color: AppColors.academicBlue,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Experience at CIT',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                provider.citExperience!.formatted,
                style: const TextStyle(color: AppColors.academicBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(FacultyProvider provider) {
    if (provider.workExperiences.isEmpty) return const SizedBox.shrink();
    return InfoDisplayCard(
      title: 'Work Experience',
      icon: Icons.work_outline,
      child: Column(
        children: provider.workExperiences.map((exp) => WorkExperienceCard(experience: exp, isReadOnly: true)).toList(),
      ),
    );
  }

  Widget _buildEducationCard(FacultyProvider provider) {
    if (provider.educationQualifications.isEmpty) return const SizedBox.shrink();
    return InfoDisplayCard(
      title: 'Education',
      icon: Icons.school_outlined,
      child: Column(
        children: provider.educationQualifications.map((edu) => EducationQualificationCard(education: edu, isReadOnly: true)).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
