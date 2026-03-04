import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import 'faculty_dashboard.dart';
import 'faculty_registration_screen.dart';

class FacultyLoginScreen extends StatefulWidget {
  const FacultyLoginScreen({super.key});

  @override
  State<FacultyLoginScreen> createState() => _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* =======================================================
     🔹 EMAIL LOGIN
     ======================================================= */

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FacultyDashboard()),
      );
    } else {
      _showErrorSnackBar(
        authProvider.errorMessage ??
            'This faculty account may use Google Sign-In.',
      );
    }
  }

  /* =======================================================
     🔹 GOOGLE LOGIN (WITH PROFILE CHECK)
     ======================================================= */

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle(
      role: AppConstants.roleFaculty,
    );

    if (!mounted) return;

    if (!success) {
      _showErrorSnackBar(
          authProvider.errorMessage ?? AppConstants.genericError);
      return;
    }

    final String? uid = authProvider.currentUserId;

    if (uid == null) {
      _showErrorSnackBar('Authentication failed. Try again.');
      return;
    }

    try {
      // 🔎 Check if profile exists
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('personalInfo')
          .doc('info')
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        // 🆕 First time Google login → complete profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const FacultyRegistrationScreen()),
        );
      } else {
        // ✅ Profile exists → go to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacultyDashboard()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error verifying profile. Please try again.');
    }
  }

  /* =======================================================
     🔹 ERROR SNACKBAR
     ======================================================= */

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /* =======================================================
     🔹 UI
     ======================================================= */

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;

  return Scaffold(
    backgroundColor: AppColors.offWhite,
    body: LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 480,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /* ================= ICON ================= */
                      Center(
                        child: Icon(
                          Icons.school,
                          size: isMobile ? 48 : 56,
                          color: AppColors.academicBlue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Faculty Login',
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.academicBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'You can register or login using Google or Email.',
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /* ================= GOOGLE ================= */

                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _handleGoogleSignIn,
                          icon: const Icon(Icons.public),
                          label: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.academicBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /* ================= EMAIL LOGIN ================= */

                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(top: 12),
                        title: const Text('Login with Email'),
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  validator: Validators.validateEmail,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: _handleEmailLogin,
                                    child:
                                        const Text('Login with Email'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Divider(),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              "Don't have an account? ",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FacultyRegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register Here',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

}