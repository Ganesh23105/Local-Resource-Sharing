import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_resource_sharing/screens/home_screen.dart';
import 'package:local_resource_sharing/screens/login_screen.dart';

/// **AuthChecker Class**
/// Determines whether the user is logged in using Firebase Authentication.
class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  /// **Checks if a user is logged in using Firebase Authentication**
  void checkLoginStatus() {
    User? user = _auth.currentUser;

    // Delay added for smooth transition effect
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });

      if (user != null) {
        // If user is logged in, navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // If user is not logged in, navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  /// **Signs out the user**
  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.teal)
            : const Text("Redirecting..."),
      ),
    );
  }
}
