import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/faculty_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/login_selection_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with Platform Specifics
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD8fEe1VXm-R-8S2WRz5oVO0zZilkfq0KU",
        authDomain: "research-cse-a78bb.firebaseapp.com",
        databaseURL: "https://research-cse-a78bb-default-rtdb.firebaseio.com",
        projectId: "research-cse-a78bb",
        storageBucket: "research-cse-a78bb.firebasestorage.app",
        messagingSenderId: "419326217425",
        appId: "1:419326217425:web:ddb1aff36ea0a53bb1c9f0",
        measurementId: "G-6NL3Q7MS6H",
      ),
    );
  } else {
    // Android/iOS configuration (google-services.json / GoogleService-Info.plist)
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FacultyProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginSelectionScreen(),
      ),
    );
  }
}
