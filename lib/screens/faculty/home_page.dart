import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
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
      final XFile? image = await _storageService.pickImageFromGallery();
      if (image != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUserId!;
        
        // Show loading via snackbar or local state if desired
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile picture...')),
        );

        await _storageService.uploadProfilePicture(userId, image);
        await authProvider.refreshUserData(); // Refresh to get new URL

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!'), backgroundColor: AppConstants.successColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppConstants.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final facultyProvider = Provider.of<FacultyProvider>(context);
    final user = authProvider.userModel;

    if (facultyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Refresh if data is missing but user is logged in
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ProfilePictureWidget(
                        imageUrl: user?.profilePictureURL,
                        size: 80,
                        showEditIcon: true,
                        onTap: _updateProfilePicture,
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personalInfo.name,
                              style: AppConstants.subheadingStyle.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              personalInfo.designation,
                              style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              personalInfo.department,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
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
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Personal Info Card
            InfoDisplayCard(
               title: 'Personal Information',
               icon: Icons.person_outline,
               initiallyExpanded: true,
               child: Column(
                 children: [
                   _buildInfoRow('Age', '${personalInfo.age}'),
                   _buildInfoRow('Date of Birth', personalInfo.dateOfBirth),
                   _buildInfoRow('Date of Joining', personalInfo.dateOfJoining),
                   _buildInfoRow('Contact', personalInfo.contactNo),
                   _buildInfoRow('Email', personalInfo.mailId),
                   _buildInfoRow('PAN', personalInfo.panNumber),
                   _buildInfoRow('Aadhar', personalInfo.aadharNumber),
                 ],
               ),
            ),

            // Research IDs Card
            if (facultyProvider.researchIDs != null)
              InfoDisplayCard(
                title: 'Research IDs',
                icon: Icons.science_outlined,
                child: Column(
                  children: [
                    _buildInfoRow('Vidwan ID', facultyProvider.researchIDs!.vidwanId ?? 'N/A'),
                    _buildInfoRow('Scopus ID', facultyProvider.researchIDs!.scopusId ?? 'N/A'),
                    _buildInfoRow('ORCID', facultyProvider.researchIDs!.orcidId ?? 'N/A'),
                    _buildInfoRow('Google Scholar', facultyProvider.researchIDs!.googleScholarId ?? 'N/A'),
                  ],
                ),
              ),

             // CIT Experience
             if (facultyProvider.citExperience != null)
               Container(
                 width: double.infinity,
                 margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                 padding: const EdgeInsets.all(AppConstants.paddingMedium),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
                   ),
                   borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text(
                       'Experience at CIT',
                       style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: Text(
                         '${facultyProvider.citExperience!.yearsInCIT} Years',
                         style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ],
                 ),
               ),

            // Work Experience
            if (facultyProvider.workExperiences.isNotEmpty)
              InfoDisplayCard(
                title: 'Work Experience',
                icon: Icons.work_outline,
                child: Column(
                  children: facultyProvider.workExperiences.map((exp) => WorkExperienceCard(experience: exp, isReadOnly: true)).toList(),
                ),
              ),

            // Education
            if (facultyProvider.educationQualifications.isNotEmpty)
              InfoDisplayCard(
                title: 'Education',
                icon: Icons.school_outlined,
                child: Column(
                  children: facultyProvider.educationQualifications.map((edu) => EducationQualificationCard(education: edu, isReadOnly: true)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
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
