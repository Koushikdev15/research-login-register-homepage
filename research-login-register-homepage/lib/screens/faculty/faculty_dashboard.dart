import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'home_page.dart';
import 'research_page.dart';
import 'fdb_page.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    HomePage(),
    ResearchPage(),
    FDBPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research CSE'),
        automaticallyImplyLeading: false, // Hide back button
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
      ),
    );
  }
}
