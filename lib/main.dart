import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import Firebase options

// Importing utilities
import 'package:local_resource_sharing/utils/theme.dart';

// Importing screens
import 'package:local_resource_sharing/screens/auth_checker.dart';
import 'package:local_resource_sharing/screens/home_screen.dart';
import 'package:local_resource_sharing/screens/login_screen.dart';
import 'package:local_resource_sharing/screens/signup_screen.dart';
import 'package:local_resource_sharing/screens/add_item_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase initializes with correct platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  runApp(LocalResourceApp());
}

class LocalResourceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Resource Sharing',
      theme: AppTheme.themeData,
      home: AuthChecker(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/add_item': (context) => AddItemScreen(),
      },
    );
  }
}
