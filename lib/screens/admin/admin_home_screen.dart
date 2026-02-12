import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import 'faculty_details_screen.dart';
import 'verification/verification_home_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = const [
      FacultyDetailsScreen(),
      VerificationHomeScreen(),
      _ReportsPlaceholder(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.universityNavy,
        unselectedItemColor: AppColors.mediumGray,
        backgroundColor: AppColors.pureWhite,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Faculty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   🔹 REPORTS PLACEHOLDER (UNCHANGED)
   ======================================================= */

class _ReportsPlaceholder extends StatelessWidget {
  const _ReportsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return _ComingSoonScreen(
      title: 'Reports & Exports',
      description:
          'Year-wise and faculty-wise research reports will be available here.',
      icon: Icons.picture_as_pdf,
    );
  }
}

/* =======================================================
   🔹 COMMON COMING-SOON UI
   ======================================================= */

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ComingSoonScreen({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.pureWhite,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.mediumGray),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                description,
                style: AppTextStyles.bodyRegular
                    .copyWith(color: AppColors.mediumGray),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
