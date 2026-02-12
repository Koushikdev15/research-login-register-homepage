import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'home_page.dart';
import 'research_page.dart';
import 'fdb_selection_page.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  int _currentIndex = 0;

  // ✅ ONLY CHANGE IS HERE
  final List<Widget> _pages = const [
    HomePage(),
    ResearchPage(),
    FdbSelectionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research CSE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.academicBlue,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            // Desktop Layout with Side Navigation
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
                  indicatorColor: AppColors.academicBlue.withOpacity(0.1),
                  selectedLabelTextStyle:
                      AppTextStyles.label.copyWith(color: AppColors.academicBlue),
                  unselectedLabelTextStyle:
                      AppTextStyles.label.copyWith(color: AppColors.mediumGray),
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.academicBlue),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.mediumGray),
                  elevation: 1,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_filled),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.science_outlined),
                      selectedIcon: Icon(Icons.science),
                      label: Text('Research'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.storage_outlined),
                      selectedIcon: Icon(Icons.storage),
                      label: Text('FDB'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Container(
                    color: AppColors.offWhite,
                    child: _pages[_currentIndex],
                  ),
                ),
              ],
            );
          } else {
            // Mobile/Tablet Layout
            return Container(
              color: AppColors.offWhite,
              child: _pages[_currentIndex],
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: AppColors.pureWhite,
              indicatorColor: AppColors.academicBlue.withOpacity(0.1),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.science_outlined),
                  selectedIcon: Icon(Icons.science),
                  label: 'Research',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storage_outlined),
                  selectedIcon: Icon(Icons.storage),
                  label: 'FDB',
                ),
              ],
            )
          : null,
    );
  }
}
