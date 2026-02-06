import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'faculty/faculty_login_screen.dart';
import 'admin/admin_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a Scaffold with a subtle off-white background
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Card
                Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  color: AppColors.pureWhite,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        // Header Section
                        const Icon(
                          Icons.account_balance, 
                          size: 64, 
                          color: AppColors.universityNavy
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'UNIVERSITY DEPARTMENT',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.mediumGray, 
                            letterSpacing: 2.0
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 32, indent: 40, endIndent: 40),
                        
                        Text(
                          'Research CSE',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.universityNavy,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faculty Management System',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.mediumGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Login Options
                        // Admin Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.security, size: 24),
                            label: const Text('Administrator Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.universityNavy,
                              foregroundColor: AppColors.pureWhite,
                              textStyle: AppTextStyles.h5,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminLoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Faculty Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_outline, size: 24),
                            label: const Text('Faculty Login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.academicBlue,
                              side: const BorderSide(color: AppColors.academicBlue, width: 2),
                              textStyle: AppTextStyles.h5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FacultyLoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Student Login (Disabled)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.school_outlined, size: 24),
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Student Login'),
                                SizedBox(width: 8),
                                Chip(
                                  label: Text('Coming Soon'),
                                  labelStyle: TextStyle(fontSize: 10, color: AppColors.mediumGray),
                                  backgroundColor: AppColors.lightGray,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                )
                              ],
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mediumGray,
                              side: const BorderSide(color: AppColors.inputBorder),
                              textStyle: AppTextStyles.h5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // Disabling interaction style manually without disabling the button functionality 
                              // unless we want it truly disabled. 
                              // User spec says "Disabled State", so let's disable it.
                            ),
                            onPressed: null, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer Section
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '© 2026 Research CSE',
                      style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'v1.0.0',
                      style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
