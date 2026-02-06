import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/faculty_profile.dart';
import '../../utils/constants.dart';
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
      appBar: AppBar(
        title: const Text('Faculty Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    adminProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
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
              // Search and Sort Header
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by Faculty Name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          adminProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sort Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            value: adminProvider.currentSort,
                            isExpanded: true,
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
              
              // Faculty List
              Expanded(
                child: adminProvider.faculty.isEmpty
                    ? const Center(child: Text('No faculty found matching your search.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Profile Picture (20% approx)
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: faculty.userModel.profilePictureURL != null
                  ? NetworkImage(faculty.userModel.profilePictureURL!)
                  : null,
              child: faculty.userModel.profilePictureURL == null
                  ? Text(
                      faculty.personalInfo.name.isNotEmpty
                          ? faculty.personalInfo.name[0]
                          : '?',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Middle: Info (50% approx)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faculty.personalInfo.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    faculty.personalInfo.designation,
                     style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    faculty.personalInfo.department,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  // Dynamic CIT Experience Badge
                  if (faculty.calculatedCITYears > 0)
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${faculty.calculatedCITYears} years in CIT',
                         style: TextStyle(
                          fontSize: 12, 
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right: Actions (30% approx)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminGeneralInfoScreen(faculty: faculty),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                       alignment: Alignment.centerLeft,
                    ),
                    child: const Text('General Info'),
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton(
                    onPressed: () => _showComingSoon(context, 'Research/Patent'),
                     style: OutlinedButton.styleFrom(
                       alignment: Alignment.centerLeft,
                    ),
                    child: const Text('Research/Patent'),
                  ),
                   const SizedBox(height: 4),
                  OutlinedButton(
                    onPressed: () => _showComingSoon(context, 'FDB/Certifications'),
                     style: OutlinedButton.styleFrom(
                       alignment: Alignment.centerLeft,
                    ),
                    child: const Text('FDB/Certifications'),
                  ),
                   const SizedBox(height: 8),
                   ElevatedButton.icon(
                     onPressed: () {
                       // Generate PDF
                       PDFService.generateFacultyPDF(faculty);
                     }, 
                     icon: const Icon(Icons.print, size: 18),
                     label: const Text('Print'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.teal,
                       foregroundColor: Colors.white,
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
