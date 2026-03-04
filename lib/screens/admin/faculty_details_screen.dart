import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/faculty_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'admin_general_info_screen.dart';
import 'admin_research_screen.dart';
import '../../services/pdf_service.dart';
import '../faculty/fdb_view_page.dart';

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
            Text('Faculty Directory',
                style: AppTextStyles.h4
                    .copyWith(color: AppColors.universityNavy)),
            Text('Department of CSE',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mediumGray)),
          ],
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.universityNavy));
          }

          if (adminProvider.errorMessage != null) {
            return Center(
              child: Text(adminProvider.errorMessage!,
                  style: AppTextStyles.bodyRegular
                      .copyWith(color: AppColors.errorRed)),
            );
          }

          return Column(
            children: [
              // ================= TOOLBAR =================
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border(
                      bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by Faculty Name',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: adminProvider.setSearchQuery,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FACULTY LIST =================
              Expanded(
                child: adminProvider.faculty.isEmpty
                    ? Center(
                        child: Text(
                          'No faculty found matching your search.',
                          style: AppTextStyles.bodyRegular
                              .copyWith(color: AppColors.mediumGray),
                        ),
                      )
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          color: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ),
        );
      },
    );
  }

  // ================= MOBILE LAYOUT =================

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(height: 16),
        _buildInfoSection(),
        const SizedBox(height: 16),
        _buildActionButtons(context),
      ],
    );
  }

  // ================= DESKTOP LAYOUT =================

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 24),
        Expanded(flex: 5, child: _buildInfoSection()),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: _buildActionButtons(context)),
      ],
    );
  }

  // ================= AVATAR =================

 Widget _buildAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.lightGray,
      backgroundImage: faculty.userModel.profilePictureURL != null
          ? NetworkImage(
              "https://drive.google.com/uc?export=view&id=${faculty.userModel.profilePictureURL!}")
          : null,
      child: faculty.userModel.profilePictureURL == null
          ? Text(
              faculty.personalInfo.name.isNotEmpty
                  ? faculty.personalInfo.name[0]
                  : '?',
              style: const TextStyle(
                  fontSize: 32, color: AppColors.mediumGray),
            )
          : null,
    );
  }

  // ================= INFO SECTION =================

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              faculty.personalInfo.name,
              style: AppTextStyles.h4,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                faculty.personalInfo.department,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mediumGray),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          faculty.personalInfo.designation,
          style: AppTextStyles.bodyRegular.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        if (faculty.calculatedCITYears > 0)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.academicBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${faculty.calculatedCITYears} years in CIT',
              style: AppTextStyles.label.copyWith(
                color: AppColors.academicBlue,
              ),
            ),
          ),
      ],
    );
  }

  // ================= ACTION BUTTONS =================

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminGeneralInfoScreen(faculty: faculty),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.universityNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('View General Info'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminResearchScreen(faculty: faculty),
              ),
            );
          },
          child: const Text('Research'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FdbViewPage(
                  overrideEmail: faculty.userModel.email,
                ),
              ),
            );
          },
          child: const Text('FDB / Certifications'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
         onPressed: () async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    await PDFService.generateFacultyPDF(faculty);

    Navigator.pop(context); // close loader

  } catch (e) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
},

          icon: const Icon(Icons.print, size: 18),
          label: const Text('Export PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.goldAccent,
            side: const BorderSide(color: AppColors.goldAccent),
          ),
        ),
      ],
    );
  }
}
