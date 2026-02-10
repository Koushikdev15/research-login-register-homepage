import 'package:flutter/material.dart';
import 'fdb_add_page.dart';
import 'fdb_view_page.dart';

class FdbSelectionPage extends StatelessWidget {
  const FdbSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added a more professional background color
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text(
          'Faculty Development Portal',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo[900], // Professional academic blue
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Subtle gradient for a modern feel
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[900]!.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Logo Placeholder for decoration
              Icon(Icons.school_rounded, size: 80, color: Colors.indigo[900]),
              const SizedBox(height: 10),
              Text(
                "Welcome back, Faculty",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // --- ADD BUTTON ---
              _buildMenuButton(
                context: context,
                label: 'Add FDP',
                icon: Icons.add_circle_outline,
                color: Colors.indigo[700]!,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FdbAddPage()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- VIEW BUTTON ---
              _buildMenuButton(
                context: context,
                label: 'View FDP',
                icon: Icons.list_alt_rounded,
                color: Colors.teal[700]!,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FdbViewPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent button decoration
  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
