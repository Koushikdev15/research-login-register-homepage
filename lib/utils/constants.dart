import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = 'Research CSE';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleFaculty = 'faculty';
  static const String roleStudent = 'student';

  // Designations
  static const List<String> designations = [
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Senior Lecturer',
    'Lecturer',
    'Research Fellow',
    'Teaching Assistant',
    'Lab Instructor',
  ];

  // Departments
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication Engineering',
    'Electrical & Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Artificial Intelligence & Machine Learning',
    'Data Science',
    'Cyber Security',
    'Internet of Things',
  ];

  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );

  // Padding and Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String personalInfoCollection = 'personalInfo';
  static const String researchIDsCollection = 'researchIDs';
  static const String workExperienceCollection = 'workExperience';
  static const String citExperienceCollection = 'citExperience';
  static const String educationQualificationCollection = 'educationQualification';
  static const String profileCollection = 'profile';

  // SharedPreferences Keys
  static const String keyUserId = 'userId';
  static const String keyUserRole = 'userRole';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyRememberMe = 'rememberMe';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String permissionError = 'You don\'t have permission to perform this action.';

  // Success Messages
  static const String registrationSuccess = 'Registration successful! Please login.';
  static const String loginSuccess = 'Login successful!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';

  // Image Assets (if you add any)
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
}
