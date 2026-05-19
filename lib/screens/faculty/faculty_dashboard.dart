import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';

import '../../services/pdf_service.dart';
import '../../services/faculty_service.dart';

import '../../models/faculty_profile.dart';

import 'home_page.dart';
import 'research_page.dart';
import 'fdb_selection_page.dart';
import 'faculty_registration_screen.dart';
import 'scopus_page.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {

  int _currentIndex = 0;
  bool _isGeneratingPDF = false;

  /// ✅ FIXED PAGE ORDER
  final List<Widget> _pages = const [
    HomePage(),
    ResearchPage(),
    ScopusPage(),
    FdbSelectionPage(),
  ];

  /// ===============================
  /// GENERATE FACULTY PDF
  /// ===============================
  Future<void> _generatePDF() async {

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    try {

      setState(() {
        _isGeneratingPDF = true;
      });

      final facultyService = FacultyService();

      final profileData =
          await facultyService.getCompleteFacultyProfile(
        authProvider.currentUserId!,
      );

      final facultyProfile =
          FacultyProfile.fromMap(profileData);

      await PDFService.generateFacultyPDF(facultyProfile);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF generation failed: $e"),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final facultyProvider =
        Provider.of<FacultyProvider>(context, listen: false);

    return Scaffold(

      /// =========================
      /// APP BAR
      /// =========================
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColors.academicBlue,

        title: Row(
          children: const [
            Icon(Icons.school, color: Colors.white),
            SizedBox(width: 8),
            Text("Research CSE"),
          ],
        ),

        actions: [

          /// EDIT PROFILE
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: "Edit Profile",
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FacultyRegistrationScreen(
                    personalInfo: facultyProvider.personalInfo!,
                    researchIDs: facultyProvider.researchIDs!,
                    workExperiences: facultyProvider.workExperiences,
                    educationQualifications:
                        facultyProvider.educationQualifications,
                  ),
                ),
              );
            },
          ),

          /// PRINT PROFILE PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.white),
            tooltip: "Download Profile PDF",
            onPressed: _isGeneratingPDF ? null : _generatePDF,
          ),

          const SizedBox(width: 12),
        ],
      ),

      /// =========================
      /// BODY
      /// =========================
      body: Stack(
        children: [

          LayoutBuilder(
            builder: (context, constraints) {

              /// DESKTOP / WEB
              if (constraints.maxWidth > 900) {

                return Row(
                  children: [

                    NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },

                      labelType: NavigationRailLabelType.all,
                      backgroundColor: AppColors.pureWhite,
                      indicatorColor:
                          AppColors.academicBlue.withOpacity(0.15),

                      selectedIconTheme: const IconThemeData(
                        color: AppColors.academicBlue,
                      ),

                      unselectedIconTheme: const IconThemeData(
                        color: AppColors.mediumGray,
                      ),

                      selectedLabelTextStyle:
                          AppTextStyles.label.copyWith(
                        color: AppColors.academicBlue,
                        fontWeight: FontWeight.bold,
                      ),

                      destinations: const [

                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text("Home"),
                        ),

                        NavigationRailDestination(
                          icon: Icon(Icons.science_outlined),
                          selectedIcon: Icon(Icons.science),
                          label: Text("Research"),
                        ),

                        NavigationRailDestination(
                          icon: Icon(Icons.public_outlined),
                          selectedIcon: Icon(Icons.public),
                          label: Text('Scopus'),
                        ),

                        NavigationRailDestination(
                          icon: Icon(Icons.storage_outlined),
                          selectedIcon: Icon(Icons.storage),
                          label: Text("FDB"),
                        ),
                      ],
                    ),

                    const VerticalDivider(width: 1),

                    Expanded(
                      child: Container(
                        color: AppColors.offWhite,
                        child: _pages[_currentIndex],
                      ),
                    ),
                  ],
                );
              }

              /// MOBILE
              return Container(
                color: AppColors.offWhite,
                child: _pages[_currentIndex],
              );
            },
          ),

          /// =========================
          /// PDF LOADING
          /// =========================
          if (_isGeneratingPDF)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    CircularProgressIndicator(
                      color: Colors.white,
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Generating PDF...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      /// =========================
      /// MOBILE BOTTOM NAV
      /// =========================
      bottomNavigationBar:
          MediaQuery.of(context).size.width <= 900
              ? NavigationBarTheme(
                  data: NavigationBarThemeData(

                    indicatorColor:
                        AppColors.academicBlue.withOpacity(0.25),

                    labelTextStyle:
                        MaterialStateProperty.resolveWith<TextStyle>(
                      (states) {

                        if (states.contains(MaterialState.selected)) {

                          return const TextStyle(
                            color: AppColors.academicBlue,
                            fontWeight: FontWeight.bold,
                          );
                        }

                        return const TextStyle(
                          color: Colors.grey,
                        );
                      },
                    ),

                    iconTheme:
                        MaterialStateProperty.resolveWith<
                            IconThemeData>(
                      (states) {

                        if (states.contains(MaterialState.selected)) {

                          return const IconThemeData(
                            color: AppColors.academicBlue,
                          );
                        }

                        return const IconThemeData(
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  child: NavigationBar(

                    height: 65,

                    selectedIndex: _currentIndex,

                    onDestinationSelected: (index) {

                      setState(() {
                        _currentIndex = index;
                      });
                    },

                    backgroundColor: Colors.white,

                    destinations: const [

                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: "Home",
                      ),

                      NavigationDestination(
                        icon: Icon(Icons.science_outlined),
                        selectedIcon: Icon(Icons.science),
                        label: "Research",
                      ),

                      NavigationDestination(
                        icon: Icon(Icons.public),
                        selectedIcon: Icon(Icons.public),
                        label: 'Scopus',
                      ),

                      NavigationDestination(
                        icon: Icon(Icons.storage_outlined),
                        selectedIcon: Icon(Icons.storage),
                        label: "Certificate",
                      ),
                    ],
                  ),
                )
              : null,
    );
  }
}