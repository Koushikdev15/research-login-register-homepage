import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/faculty_profile.dart';
import '../../utils/constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'admin_general_info_screen.dart';
import '../../services/pdf_service.dart';

class FacultyDetailsScreen extends StatefulWidget {
  const FacultyDetailsScreen({super.key});

  @override
  State<FacultyDetailsScreen> createState() => _FacultyDetailsScreenState();
}

class _FacultyDetailsScreenState extends State<FacultyDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        centerTitle: false,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faculty Directory', style: AppTextStyles.h4.copyWith(color: AppColors.universityNavy)),
            Text('Department of CSE', style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.errorRed),
            onPressed: () {
              // Confirm Logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit admin screen
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.universityNavy));
          }

          if (adminProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    adminProvider.errorMessage!,
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.errorRed),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.fetchAllFaculty(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Toolbar Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 3,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by Faculty Name',
                            prefixIcon: const Icon(Icons.search, color: AppColors.mediumGray),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: AppColors.inputBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(4),
                               borderSide: const BorderSide(color: AppColors.inputBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: AppColors.pureWhite,
                          ),
                          onChanged: adminProvider.setSearchQuery,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Filters
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Text('Sort by: ', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<SortOption>(
                                  value: adminProvider.currentSort,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.mediumGray),
                                  style: AppTextStyles.bodyRegular,
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAZ,
                                      child: Text('Name (A-Z)'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameZA,
                                      child: Text('Name (Z-A)'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.experienceHighToLow,
                                      child: Text('Experience (High-Low)'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.experienceLowToHigh,
                                      child: Text('Experience (Low-High)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      adminProvider.setSortOption(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Faculty List
              Expanded(
                child: adminProvider.faculty.isEmpty
                    ? Center(child: Text('No faculty found matching your search.', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: adminProvider.faculty.length,
                        itemBuilder: (context, index) {
                          return _FacultyCard(
                            faculty: adminProvider.faculty[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final FacultyProfile faculty;

  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightGray,
              backgroundImage: faculty.userModel.profilePictureURL != null
                  ? NetworkImage(faculty.userModel.profilePictureURL!)
                  : null,
              child: faculty.userModel.profilePictureURL == null
                  ? Text(
                      faculty.personalInfo.name.isNotEmpty
                          ? faculty.personalInfo.name[0]
                          : '?',
                      style: const TextStyle(fontSize: 32, color: AppColors.mediumGray),
                    )
                  : null,
            ),
            const SizedBox(width: 24),

            // Middle: Info
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        faculty.personalInfo.name,
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          faculty.personalInfo.department,
                          style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    faculty.personalInfo.designation,
                     style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dynamic CIT Experience Badge
                  if (faculty.calculatedCITYears > 0)
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.academicBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${faculty.calculatedCITYears} years in CIT',
                         style: AppTextStyles.label.copyWith(
                          color: AppColors.academicBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right: Actions
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionButton(
                    label: 'View General Info',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminGeneralInfoScreen(faculty: faculty),
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    label: 'Research/Patent',
                    onPressed: () => _showComingSoon(context, 'Research/Patent'),
                  ),
                  _ActionButton(
                    label: 'FDB/Certifications',
                    onPressed: () => _showComingSoon(context, 'FDB/Certifications'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        PDFService.generateFacultyPDF(faculty);
                      }, 
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Export PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.goldAccent,
                        side: const BorderSide(color: AppColors.goldAccent),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$title information will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.academicBlue),
        ),
      ),
    );
  }
}
