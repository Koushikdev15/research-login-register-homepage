import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import '../../theme/app_colors.dart';

import '../login_selection_screen.dart';
import 'faculty_dashboard.dart';
import 'faculty_registration_screen.dart';

class FacultyLoginScreen extends StatefulWidget {

  const FacultyLoginScreen({super.key});

  @override
  State<FacultyLoginScreen> createState() =>
      _FacultyLoginScreenState();
}

class _FacultyLoginScreenState
    extends State<FacultyLoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _emailController =
          TextEditingController();

  final TextEditingController
      _passwordController =
          TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success =
        await authProvider
            .signInWithEmailPassword(
      email: _emailController.text.trim(),
      password:
          _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const FacultyDashboard(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                "Login failed",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F5F7),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
            ),

            child: Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 22,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(24),

                boxShadow: [

                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.05,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Form(

                key: _formKey,

                child: Column(

                  children: [

                    // =====================================
                    // ICON
                    // =====================================

                    Container(

                      height: 90,
                      width: 90,

                      decoration: const BoxDecoration(

                        color: Color(
                          0xFFE9EEF5,
                        ),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.school,
                        size: 42,
                        color:
                            AppColors.academicBlue,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =====================================
                    // TITLE
                    // =====================================

                    const Text(

                      "Faculty Portal",

                      style: TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.academicBlue,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(

                      "Please login to continue",

                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =====================================
                    // EMAIL
                    // =====================================

                    TextFormField(

                      controller:
                          _emailController,

                      keyboardType:
                          TextInputType
                              .emailAddress,

                      decoration: InputDecoration(

                        hintText: "Email",

                        prefixIcon: const Icon(
                          Icons.email,
                        ),

                        filled: true,

                        fillColor:
                            Colors.white,

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 18,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),

                          borderSide:
                              BorderSide(
                            color: Colors
                                .grey.shade300,
                          ),
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Enter email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // =====================================
                    // PASSWORD
                    // =====================================

                    TextFormField(

                      controller:
                          _passwordController,

                      obscureText:
                          _obscurePassword,

                      decoration: InputDecoration(

                        hintText: "Password",

                        prefixIcon: const Icon(
                          Icons.lock,
                        ),

                        suffixIcon:
                            IconButton(

                          icon: Icon(

                            _obscurePassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),

                          onPressed: () {

                            setState(() {

                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),

                        filled: true,

                        fillColor:
                            Colors.white,

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 18,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),

                          borderSide:
                              BorderSide(
                            color: Colors
                                .grey.shade300,
                          ),
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Enter password";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // =====================================
                    // LOGIN BUTTON
                    // =====================================

                    SizedBox(

                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton(

                        onPressed:
                            _isLoading
                                ? null
                                : _login,

                        style:
                            ElevatedButton
                                .styleFrom(

                          backgroundColor:
                              AppColors
                                  .academicBlue,

                          elevation: 4,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),

                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                  )
                                : const Text(

                                    "Login Access",

                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          Colors
                                              .white,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // REGISTER
                    // =====================================

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        const Text(
                          "New Faculty?",
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
                            "Register",
                          ),
                        ),
                      ],
                    ),

                    // =====================================
                    // BACK
                    // =====================================

                    TextButton.icon(

                      onPressed: () {

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginSelectionScreen(),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),

                      label: const Text(
                        "Back",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}